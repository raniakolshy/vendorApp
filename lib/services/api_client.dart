import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  final Dio _dio;
  final _secureStorage = const FlutterSecureStorage();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() : _dio = Dio(
    BaseOptions(
      baseUrl: "https://kolshy.ae/rest/V1/",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: 'authToken');
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
    ));
  }

  Dio get dio => _dio;

  // Method to save the token after successful login
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: 'authToken', value: token);
  }

  // Method to remove the token on logout
  Future<void> clearAuthToken() async {
    await _secureStorage.delete(key: 'authToken');
  }
}