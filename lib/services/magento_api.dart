import 'package:dio/dio.dart';

class MagentoApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://kolshy.ae/rest/V1/",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // -------- Login (must be anonymous) --------
  Future<String> login(String username, String password) async {
    try {
      final res = await _dio.post(
        "integration/customer/token",
        options: Options(headers: {"Authorization": null}), // force NO auth
        data: {
          "username": username.trim(),
          "password": password,
        },
      );

      // Normalize (Magento may return a quoted string)
      final raw = res.data?.toString() ?? "";
      final token = raw.replaceAll('"', '').trim();
      if (token.isEmpty) throw Exception("Empty token from server");
      return token;
    } on DioException catch (e) {
      throw Exception(_magentoErr(e, "Magento login failed"));
    }
  }

  // -------- Register new customer (anonymous by default) --------
  Future<void> registerCustomer({
    required String email,
    required String firstname,
    required String lastname,
    required String password,
    int? websiteId,             // set if your Magento needs it (multi-site)
    int? storeId,               // optional
    String? phone,              // if provided, we save it on a default address
  }) async {
    try {
      final customer = <String, dynamic>{
        "email": email.trim().toLowerCase(),
        "firstname": firstname.trim(),
        "lastname": lastname.trim(),
        if (websiteId != null) "website_id": websiteId,
        if (storeId != null) "store_id": storeId,
        if (phone != null && phone.trim().isNotEmpty)
          "addresses": [
            {
              "defaultBilling": true,
              "defaultShipping": true,
              "firstname": firstname.trim(),
              "lastname": lastname.trim(),
              "telephone": phone.trim(),
              "countryId": "AE",
              "postcode": "00000",
              "city": "Dubai",
              "region": "Dubai",
              "street": ["Address line"],
            }
          ],
      };

      await _dio.post(
        "customers",
        options: Options(headers: {"Authorization": null}), // force NO auth
        data: {
          "customer": customer,
          "password": password,
        },
      );
    } on DioException catch (e) {
      throw Exception(_magentoErr(e, "Magento registration failed"));
    }
  }

  // -------- Register vendor (needs admin token) --------
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
      final customer = <String, dynamic>{
        "email": email.trim().toLowerCase(),
        "firstname": firstname.trim(),
        "lastname": lastname.trim(),
        if (websiteId != null) "website_id": websiteId,
        if (storeId != null) "store_id": storeId,
        "custom_attributes": [
          {"attribute_code": "is_vendor", "value": "1"}
        ],
      };

      await _dio.post(
        "customers",
        options: Options(headers: {"Authorization": "Bearer $adminToken"}),
        data: {
          "customer": customer,
          "password": password,
        },
      );
    } on DioException catch (e) {
      throw Exception(_magentoErr(e, "Magento vendor registration failed"));
    }
  }

  // -------- Get customer profile (requires customer token) --------
  Future<Map<String, dynamic>> getCustomer(String token) async {
    try {
      final res = await _dio.get(
        "customers/me",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw Exception(_magentoErr(e, "Magento get customer failed"));
    }
  }

  // -------- Social login passthrough --------
  Future<String> socialLogin(String provider, Map<String, dynamic> payload) async {
    try {
      final res = await Dio().post(
        "https://kolshy.ae/sociallogin/social/callback/",
        data: {"provider": provider, ...payload},
        options: Options(headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        }),
      );

      final data = res.data;
      if (data is Map && data["token"] is String) {
        final token = (data["token"] as String).trim();
        if (token.isEmpty) throw Exception("Empty social token");
        return token;
      }
      throw Exception("Social login failed: $data");
    } on DioException catch (e) {
      throw Exception(_magentoErr(e, "Magento social login failed"));
    }
  }

  // -------- Unified Magento error parser --------
  String _magentoErr(DioException e, String fallback) {
    final data = e.response?.data;
    // Standard Magento error shape
    if (data is Map) {
      if (data["message"] is String) {
        final base = data["message"] as String;
        if (data["parameters"] is List && (data["parameters"] as List).isNotEmpty) {
          return "$base (${(data["parameters"] as List).join(", ")})";
        }
        return base;
      }
    }
    if (data is String && data.isNotEmpty) return data;
    return "$fallback: ${e.message ?? 'Unknown error'}";
  }
}
