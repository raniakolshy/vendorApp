import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'magento_api.dart';

class AuthService {
  // Singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Storage + API
  static const _tokenKey = "customer_token";
  final _storage = const FlutterSecureStorage();
  final MagentoApi _api = MagentoApi();

  // In-memory cache
  String? _customerToken;

  // -------------------- Token helpers --------------------
  Future<void> _saveToken(String token) async {
    _customerToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> _clearToken() async {
    _customerToken = null;
    await _storage.delete(key: _tokenKey);
  }

  /// Get token from memory or secure storage
  Future<String?> getToken() async {
    if (_customerToken != null) return _customerToken;
    _customerToken = await _storage.read(key: _tokenKey);
    return _customerToken;
  }

  // -------------------- Auth flows --------------------
  /// Normal email/password login
  Future<String> login(String email, String password) async {
    try {
      final token = await _api.login(email, password);
      await _saveToken(token);
      return token;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  /// Social login (Google, Facebook, Instagram)
  Future<String> loginWithSocial(String provider, Map<String, dynamic> payload) async {
    try {
      final token = await _api.socialLogin(provider, payload);
      await _saveToken(token);
      return token;
    } catch (e) {
      throw Exception("Social login failed: $e");
    }
  }

  /// Customer registration (self-service)
  /// If you want to persist phone, websiteId/storeId, pass them here.
  Future<void> registerCustomer({
    required String email,
    required String firstname,
    required String lastname,
    required String password,
    String? phone,        // optional: saved as default address if MagentoApi is set that way
    int? websiteId,       // optional: needed on multi-site
    int? storeId,         // optional
  }) async {
    try {
      await _api.registerCustomer(
        email: email,
        firstname: firstname,
        lastname: lastname,
        password: password,
        phone: phone,
        websiteId: websiteId,
        storeId: storeId,
      );

      // Auto login after registration
      await login(email, password);
    } catch (e) {
      throw Exception("Customer registration failed: $e");
    }
  }

  /// Vendor registration (requires admin token)
  Future<void> registerVendor({
    required String email,
    required String firstname,
    required String lastname,
    required String password,
    required String adminToken,
    int? websiteId,
    int? storeId,
  }) async {
    try {
      await _api.registerVendor(
        email: email,
        firstname: firstname,
        lastname: lastname,
        password: password,
        adminToken: adminToken,
        websiteId: websiteId,
        storeId: storeId,
      );
    } catch (e) {
      throw Exception("Vendor registration failed: $e");
    }
  }

  /// Fetch current customer profile
  Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    if (token == null) throw Exception("Not logged in");
    return await _api.getCustomer(token);
  }

  /// Logout (local). If you also want to revoke on server, call the revoke endpoint via ApiClient separately.
  Future<void> logout() async {
    await _clearToken();
  }
}
