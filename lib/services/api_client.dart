import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  final Dio _dio;
  final _secureStorage = const FlutterSecureStorage();

  factory ApiClient() => _instance;

  ApiClient._internal()
      : _dio = Dio(BaseOptions(
    baseUrl: "https://kolshy.ae/rest/V1/",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: 'authToken');
        if (token != null && token.isNotEmpty) {
          options.headers["Authorization"] = "Bearer $token";
        } else {
          options.headers.remove("Authorization");
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          await clearAuthToken();
        }
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  Future<void> saveAuthToken(String token) async =>
      _secureStorage.write(key: 'authToken', value: token);

  Future<void> clearAuthToken() async =>
      _secureStorage.delete(key: 'authToken');

  Future<String?> getAuthToken() async =>
      _secureStorage.read(key: 'authToken');

  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getCustomerInfo() async {
    try {
      final response = await _dio.get('customers/me');
      return response.data;
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        await clearAuthToken();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String parseMagentoError(dynamic error) {
    if (error is DioError) {
      if (error.response != null) {
        final data = error.response!.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return data['message'] as String;
        } else if (data is String) {
          return data;
        }
      }
      return error.message ?? 'An unknown error occurred';
    }
    return error.toString();
  }

  Future<void> logout() async {
    try {
      await _dio.post('integration/customer/revoke');
    } catch (_) {
    } finally {
      await clearAuthToken();
    }
  }
}
