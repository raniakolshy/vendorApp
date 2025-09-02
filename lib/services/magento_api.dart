import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MagentoApi {
  // Same admin token/header style as the boss code
  static const String _adminToken = "87igct1wbbphdok6dk1roju4i83kyub9";

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://kolshy.ae/rest/V1/",
      headers: {
        "Authorization": "Bearer $_adminToken",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // ---------- Session helpers (same keys your boss uses) ----------
  static const _authKey = "auth_token";
  static const _guestKey = "is_guest";

  static Future<void> saveToken(String token, {bool isGuest = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authKey, token);
    await prefs.setBool(_guestKey, isGuest);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authKey);
  }

  static Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestKey) ?? true;
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
    await prefs.remove(_guestKey);
  }

  // ---------- Customer ----------
  /// Email/Password login – returns the **customer token** (plain string)
  Future<String> loginCustomer(String email, String password) async {
    try {
      final res = await _dio.post(
        "integration/customer/token",
        data: {"username": email, "password": password},
        options: Options(headers: {
          // Ensure request is clean (Magento returns a plain string token)
          "Content-Type": "application/json",
          "Accept": "application/json",
        }),
      );
      final token = (res.data is String) ? res.data as String : res.data?.toString() ?? "";
      if (token.isEmpty) {
        throw Exception("Empty token returned from Magento.");
      }
      await saveToken(token, isGuest: false);
      return token;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Magento login failed: ${e.message}");
    }
  }

  /// Create customer (admin header already on _dio)
  Future<Map<String, dynamic>> createCustomer({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
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
      throw Exception(e.response?.data ?? "Magento registration failed: ${e.message}");
    }
  }

  /// Get current customer profile (needs **customer** token)
  Future<Map<String, dynamic>> getCustomerProfile(String customerToken) async {
    final res = await _dio.get(
      "customers/me",
      options: Options(headers: {"Authorization": "Bearer $customerToken"}),
    );
    return Map<String, dynamic>.from(res.data);
  }

  /// Revoke customer token (logout)
  Future<void> revokeCustomerToken(String customerToken) async {
    try {
      await _dio.post(
        "integration/customer/revoke",
        options: Options(headers: {
          "Authorization": "Bearer $customerToken",
          "Content-Type": "application/json",
          "Accept": "application/json",
        }),
      );
    } catch (_) {
      // Ignore errors on revoke
    }
  }

  // ---------- Social login (your backend endpoint) ----------
  /// Calls your backend social callback and expects { token: "<customerToken>" }
  Future<String> socialLogin(String provider, Map<String, dynamic> payload) async {
    try {
      final res = await Dio().post(
        "https://kolshy.ae/sociallogin/social/callback/",
        data: {
          "provider": provider,
          ...payload,
        },
        options: Options(headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        }),
      );

      final data = res.data;
      if (data is Map && data["token"] is String) {
        final token = data["token"] as String;
        await saveToken(token, isGuest: false);
        return token;
      }
      throw Exception("Invalid social login response: $data");
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Social login failed: ${e.message}");
    }
  }

  // ---------- Carts (optional, kept for parity with boss code) ----------
  Future<String> getGuestCartToken() async {
    try {
      final res = await _dio.post("guest-carts");
      final token = res.data?.toString() ?? "";
      await saveToken(token, isGuest: true);
      return token;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Create guest cart failed: ${e.message}");
    }
  }

  Future<void> addToCart(String sku, int qty) async {
    final token = await getToken();
    final guest = await isGuest();
    try {
      if (guest) {
        final cartId = token ?? await getGuestCartToken();
        await _dio.post(
          "guest-carts/$cartId/items",
          data: {
            "cartItem": {"quote_id": cartId, "sku": sku, "qty": qty}
          },
        );
      } else {
        await _dio.post(
          "carts/mine/items",
          options: Options(headers: {"Authorization": "Bearer $token"}),
          data: {
            "cartItem": {"sku": sku, "qty": qty}
          },
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Add to cart failed: ${e.message}");
    }
  }

  Future<List<dynamic>> getCartItems() async {
    final token = await getToken();
    final guest = await isGuest();
    try {
      if (guest) {
        final cartId = token ?? await getGuestCartToken();
        final res = await _dio.get("guest-carts/$cartId/items");
        return (res.data as List?) ?? [];
      } else {
        final res = await _dio.get(
          "carts/mine/items",
          options: Options(headers: {"Authorization": "Bearer $token"}),
        );
        return (res.data as List?) ?? [];
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Fetch cart failed: ${e.message}");
    }
  }

  // Expose Dio if needed
  Dio get dio => _dio;
}
