// lib/services/auth_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _api = ApiClient();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String?> getToken() => _secureStorage.read(key: 'authToken');

  Future<void> clearToken() async {
    await _secureStorage.delete(key: 'authToken');
    await _secureStorage.delete(key: 'is_guest');
  }

  /// Login restricted to SELLERS (Webkul)
  Future<String> loginVendor(String email, String password) async {
    final token = await _api.loginVendor(email: email, password: password);
    await _secureStorage.write(key: 'authToken', value: token);
    await _secureStorage.write(key: 'is_guest', value: 'false');
    return token;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() => _api.logout();
}
