
// services/auth_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'magento_api.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal();

  final MagentoApi _api = MagentoApi();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'authToken');
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: 'authToken');
    await _secureStorage.delete(key: 'isGuest');
  }

  /// Email / password login
  Future<String> login(String email, String password) async {
    return await _api.loginCustomer(email, password);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}