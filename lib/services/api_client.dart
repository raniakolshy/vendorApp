// services/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // ---- singleton
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiClient._internal()
      : _dio = Dio(
    BaseOptions(
      baseUrl: "https://kolshy.ae/rest/V1/",
      headers: {
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
          final path = options.path.toLowerCase();

          final isAuthEndpoint =
              (path.contains("integration/customer/token")) ||
                  (path.endsWith("/customers") && options.method.toUpperCase() == "POST");

          if (!isAuthEndpoint && !options.headers.containsKey("Authorization")) {
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
          if (error.response?.statusCode == 401) {
            await _clearCustomerToken();
          }
          return handler.next(error);
        },
      ),
    );

  }

  Dio get dio => _dio;

  static const _guestKey = "is_guest";

  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: 'authToken', value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestKey, false);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: 'authToken');
  }

  Future<void> clearAuthToken() async {
    await _secureStorage.delete(key: 'authToken');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_guestKey);
  }

  Future<String?> _readCustomerToken() => getAuthToken();
  Future<void> _clearCustomerToken() => clearAuthToken();

  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  Future<String> loginCustomer(String email, String password) async {
    try {
      final response = await _dio.post(
        "integration/customer/token",
        data: {"username": email, "password": password},
        options: Options(headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": null, // Explicitly remove admin token for login
        }),
      );

      final token = (response.data is String) ? response.data as String : response.data?.toString() ?? "";
      if (token.isEmpty) {
        throw Exception("Empty token returned from Magento.");
      }
      await saveAuthToken(token);
      return token;
    } on DioException catch (e) {
      throw Exception(parseMagentoError(e));
    }
  }

  Future<Map<String, dynamic>> createCustomer({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
  }) async {
    try {
      // Use admin token for customer creation
      final response = await _dio.post(
        "customers",
        data: {
          "customer": {
            "email": email,
            "firstname": firstname,
            "lastname": lastname,
          },
          "password": password,
        },
        options: Options(headers: {"Authorization": null}),
      );
      return Map<String, dynamic>.from(response.data ?? {});
    } on DioException catch (e) {
      throw Exception(parseMagentoError(e));
    }
  }

  Options unauthenticated() => Options(headers: {"Authorization": null});

  Options withBearer(String token) =>
      Options(headers: {"Authorization": "Bearer $token"});

  Future<Map<String, dynamic>?> getCustomerInfo() async {
    try {
      final response = await _dio.get('customers/me');
      return Map<String, dynamic>.from(response.data);
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

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
      // Ignore errors during logout
    } finally {
      await clearAuthToken();
    }
  }

  String parseMagentoError(
      Object error, {
        String fallback = 'An unknown error occurred',
      }) {
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