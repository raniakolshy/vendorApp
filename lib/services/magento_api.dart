// services/magento_api.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MagentoApi {
  static const String _adminToken = "87igct1wbbphdok6dk1roju4i83kyub9";
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final Dio _adminDio = Dio(
    BaseOptions(
      baseUrl: "https://kolshy.ae/rest/V1/",
      headers: {
        "Authorization": "Bearer $_adminToken",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );

  final Dio _customerDio = Dio(
    BaseOptions(
      baseUrl: "https://kolshy.ae/rest/V1/",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );

  // Token management
  static Future<void> saveToken(String token, {bool isGuest = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
    await prefs.setBool("is_guest", isGuest);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  static Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("is_guest") ?? true;
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    await prefs.remove("is_guest");
  }

  Future<String> loginCustomer(String email, String password) async {
    try {
      final res = await _customerDio.post(
        "integration/customer/token",
        data: {"username": email, "password": password},
      );

      final token = res.data;
      await MagentoApi.saveToken(token, isGuest: false);
      return token;
    } on DioException catch (e) {
      final errorMessage = _parseMagentoError(e);
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> createCustomer({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _adminDio.post(
        "customers",
        data: {
          "customer": {
            "email": email,
            "firstname": firstname,
            "lastname": lastname,
          },
          "password": password,
        },
      );
      return Map<String, dynamic>.from(res.data ?? {});
    } on DioException catch (e) {
      final errorMessage = _parseMagentoError(e);
      throw Exception(errorMessage);
    }
  }

  String _parseMagentoError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data['message'] is String) return data['message'] as String;
      if (data['parameters'] is List && (data['parameters'] as List).isNotEmpty) {
        return '${data['message']} (${(data['parameters'] as List).join(", ")})';
      }
    }
    if (data is String && data.isNotEmpty) return data;
    return e.message ?? "An unknown error occurred";
  }
}