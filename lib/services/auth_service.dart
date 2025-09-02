import 'package:shared_preferences/shared_preferences.dart';
import 'magento_api.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal();

  final MagentoApi _api = MagentoApi();

  static const _authKey = "auth_token";
  static const _guestKey = "is_guest";

  Future<void> _saveToken(String token, {bool isGuest = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authKey, token);
    await prefs.setBool(_guestKey, isGuest);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
    await prefs.remove(_guestKey);
  }

  /// Email / password
  Future<String> login(String email, String password) async {
    final token = await _api.loginCustomer(email, password);
    await _saveToken(token, isGuest: false);
    return token;
  }

  /// Google/Facebook/Instagram
  Future<String> loginWithSocial(String provider, Map<String, dynamic> payload) async {
    final token = await _api.socialLogin(provider, payload);
    await _saveToken(token, isGuest: false);
    return token;
  }

  Future<void> logout() async {
    try {
      final t = await getToken();
      if (t != null && t.isNotEmpty) {
        await _api.revokeCustomerToken(t);
      }
    } catch (_) {
      // ignore
    } finally {
      await clearToken();
    }
  }
}
