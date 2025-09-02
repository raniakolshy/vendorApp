import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // ---- singleton
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final Dio _dio;

  ApiClient._internal()
      : _dio = Dio(
    BaseOptions(
      baseUrl: "https://kolshy.ae/rest/V1/",
      headers: {
        // Do NOT set Authorization here globally
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
          // If a call explicitly sets Authorization, don't override it.
          if (!options.headers.containsKey("Authorization")) {
            final token = await _readCustomerToken();
            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
            } else {
              options.headers.remove("Authorization");
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // If token is invalid, clear it so UI can react
          if (error.response?.statusCode == 401) {
            await _clearCustomerToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // ---- public dio accessor
  Dio get dio => _dio;

  // ---- SharedPreferences (same keys as boss)
  static const _authKey = "auth_token";
  static const _guestKey = "is_guest";

  // Write customer token (and mark not guest)
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authKey, token);
    await prefs.setBool(_guestKey, false);
  }

  // Read customer token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authKey);
  }

  // Clear token (logout)
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
    await prefs.remove(_guestKey);
  }

  // Internal read/clear used by interceptor
  Future<String?> _readCustomerToken() => getAuthToken();
  Future<void> _clearCustomerToken() => clearAuthToken();

  Future<bool> isLoggedIn() async =>
      ((await getAuthToken())?.isNotEmpty ?? false);

  // ---- convenience Options helpers

  /// Force no Authorization (e.g. login/self-register calls)
  Options unauthenticated() => Options(headers: {"Authorization": null});

  /// Force a specific Bearer (e.g. admin token on privileged calls)
  Options withBearer(String token) =>
      Options(headers: {"Authorization": "Bearer $token"});

  // ---- example API methods using the attached customer token

  Future<Map<String, dynamic>?> getCustomerInfo() async {
    try {
      final response = await _dio.get('customers/me'); // token added by interceptor
      return Map<String, dynamic>.from(response.data);
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Revoke the current customer token on Magento (if any) and clear it locally.
  Future<void> logout() async {
    try {
      final token = await getAuthToken();
      if (token != null && token.isNotEmpty) {
        await _dio.post(
          'integration/customer/revoke',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (_) {
      // Ignore API errors during logout
    } finally {
      await clearAuthToken();
    }
  }

  // ---- generic Magento error parser (Dio v5)
  String parseMagentoError(
      Object error, {
        String fallback = 'An unknown error occurred',
      }) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) return data['message'] as String;
      if (data is Map &&
          data['parameters'] is List &&
          (data['parameters'] as List).isNotEmpty) {
        return '${data['message']} (${(data['parameters'] as List).join(", ")})';
      }
      if (data is String && data.isNotEmpty) return data;
      return error.message ?? fallback;
    }
    return error.toString();
  }
}
