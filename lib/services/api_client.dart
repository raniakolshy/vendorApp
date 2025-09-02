import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // ---- singleton
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final Dio _dio;
  final _secureStorage = const FlutterSecureStorage();
  static const _tokenKey = 'customer_token'; // unified key used across the app

  ApiClient._internal()
      : _dio = Dio(
    BaseOptions(
      baseUrl: "https://kolshy.ae/rest/V1/",
      headers: {
        // Do NOT set Authorization here.
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Only attach customer token if the request didn't explicitly override Authorization.
          if (!(options.headers.containsKey("Authorization"))) {
            final token = await _secureStorage.read(key: _tokenKey);
            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
            } else {
              options.headers.remove("Authorization");
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await clearAuthToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ---- public dio accessor
  Dio get dio => _dio;

  // ---- token helpers (customer token)
  Future<void> saveAuthToken(String token) async =>
      _secureStorage.write(key: _tokenKey, value: token);

  Future<String?> getAuthToken() async =>
      _secureStorage.read(key: _tokenKey);

  Future<void> clearAuthToken() async =>
      _secureStorage.delete(key: _tokenKey);

  Future<bool> isLoggedIn() async =>
      ((await getAuthToken())?.isNotEmpty ?? false);

  // ---- common per-call header helpers

  /// Use this to FORCE no Authorization header (e.g., login, self-register).
  Options unauthenticated() =>
      Options(headers: {"Authorization": null});

  /// Use this to FORCE an admin token on a specific call.
  Options withAdmin(String adminToken) =>
      Options(headers: {"Authorization": "Bearer $adminToken"});

  // ---- example API methods

  Future<Map<String, dynamic>?> getCustomerInfo() async {
    try {
      final response = await _dio.get('customers/me'); // interceptor adds customer token
      return Map<String, dynamic>.from(response.data);
    } on DioException {
      // 401s already clear token in interceptor
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('integration/customer/revoke'); // uses customer token
    } catch (_) {
      // ignore
    } finally {
      await clearAuthToken();
    }
  }

  // ---- generic Magento error parser (Dio v5)
  String parseMagentoError(Object error, {String fallback = 'An unknown error occurred'}) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) return data['message'] as String;
      if (data is Map && data['parameters'] is List && (data['parameters'] as List).isNotEmpty) {
        return '${data['message']} (${(data['parameters'] as List).join(", ")})';
      }
      if (data is String && data.isNotEmpty) return data;
      return error.message ?? fallback;
    }
    return error.toString();
  }
}
