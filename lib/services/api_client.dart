// lib/services/api_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/auth/login/welcome_screen.dart';
import 'order_model.dart'; // Must define MagentoOrder in here

/// Make sure your MaterialApp uses this navigatorKey:
/// MaterialApp(navigatorKey: navigatorKey, ...)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// =================== PUBLIC MODELS (keep top-level) ===================

class ReviewPage {
  ReviewPage({required this.items, required this.totalCount});
  final List<MagentoReview> items;
  final int totalCount;
}

class MagentoReview {
  MagentoReview({
    this.id,
    this.title,
    this.detail,
    this.nickname,
    this.productId,
    this.productSku,
    this.status,
    this.createdAt,
    this.ratings,
  });

  final int? id;
  final String? title;
  final String? detail;
  final String? nickname;
  final int? productId;
  final String? productSku;
  final int? status; // 1 Approved, 2 Pending, 3 Not Approved
  final String? createdAt;
  final List<dynamic>? ratings;

  factory MagentoReview.fromJson(Map json) {
    return MagentoReview(
      id: (json['id'] is int) ? json['id'] as int : int.tryParse('${json['id'] ?? ''}'),
      title: (json['title'] ?? '').toString(),
      detail: (json['detail'] ?? '').toString(),
      nickname: (json['nickname'] ?? '').toString(),
      productId: (json['entity_pk_value'] is int)
          ? json['entity_pk_value'] as int
          : int.tryParse('${json['entity_pk_value'] ?? ''}'),
      productSku: (json['sku'] ?? json['product_sku'] ?? '').toString(),
      status: (json['status'] is int)
          ? json['status'] as int
          : int.tryParse('${json['status'] ?? ''}'),
      createdAt: (json['created_at'] ?? '').toString(),
      ratings: (json['ratings'] is List)
          ? (json['ratings'] as List)
          : (json['rating_votes'] as List?),
    );
  }
}

class ProductLite {
  const ProductLite({
    required this.name,
    required this.typeId,
    required this.image,
  });

  final String name;
  final String typeId;
  final String image;
}

/// Data carrier for vendor profile (must be top-level in Dart)
class VendorProfile {
  VendorProfile({
    required this.customerId,
    this.companyName,
    this.bio,
    this.country,
    this.phone,
    this.lowStockQty,
    this.vatNumber,
    this.paymentDetails,
    this.logoUrl,
    this.bannerUrl,
    this.logoBase64,
    this.bannerBase64,
    this.twitter,
    this.facebook,
    this.instagram,
    this.youtube,
    this.vimeo,
    this.pinterest,
    this.moleskine,
    this.tiktok,
    this.returnPolicy,
    this.shippingPolicy,
    this.privacyPolicy,
    this.metaKeywords,
    this.metaDescription,
    this.googleAnalyticsId,
    this.profilePathReq,
    this.collectionPathReq,
    this.reviewPathReq,
    this.locationPathReq,
    this.privacyPathReq,
  });

  final int customerId;

  String? companyName;
  String? bio;
  String? country;
  String? phone;
  String? lowStockQty;
  String? vatNumber;
  String? paymentDetails;

  String? logoUrl;
  String? bannerUrl;
  String? logoBase64;
  String? bannerBase64;

  String? twitter;
  String? facebook;
  String? instagram;
  String? youtube;
  String? vimeo;
  String? pinterest;
  String? moleskine;
  String? tiktok;

  String? returnPolicy;
  String? shippingPolicy;
  String? privacyPolicy;

  String? metaKeywords;
  String? metaDescription;
  String? googleAnalyticsId;

  String? profilePathReq;
  String? collectionPathReq;
  String? reviewPathReq;
  String? locationPathReq;
  String? privacyPathReq;
}

// =================== API CLIENT ===================

class ApiClient {
  // ---------------- Singleton ----------------
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal();

  // ---------------- Config ----------------
  static const String _adminToken = "87igct1wbbphdok6dk1roju4i83kyub9";
  static const String _base = "https://kolshy.ae/rest/V1/";
  static const Duration _timeout = Duration(seconds: 30);

  /// Dio always carries the ADMIN token by default.
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _base,
      headers: {
        "Authorization": "Bearer $_adminToken",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
    ),
  );

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Dio get dio => _dio;

  // ---------------- Storage Keys ----------------
  static const _kAuthToken = 'authToken';
  static const _kIsGuest = 'is_guest';

  // Small helper for auth header
  Options _auth(String token) => Options(headers: {"Authorization": "Bearer $token"});

  // ---------------- Auth helpers (token persistence) ----------------

  Future<void> _saveTokenInternal(String token, {bool isGuest = false}) async {
    await _secureStorage.write(key: _kAuthToken, value: token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsGuest, isGuest);
  }

  Future<String?> getAuthToken() => _secureStorage.read(key: _kAuthToken);

  Future<void> clearAuthToken() async {
    await _secureStorage.delete(key: _kAuthToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kIsGuest);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // ---------------- Login (Vendor-first) ----------------

  Future<String> loginVendor({
    required String email,
    required String password,
  }) async {
    final token = await _loginCustomerRaw(email: email, password: password);
    final vendor = await _isVendor(token);
    if (!vendor) {
      throw Exception('This account is not a vendor. Please use a vendor account.');
    }
    await _saveTokenInternal(token, isGuest: false);
    return token;
  }

  Future<String> _loginCustomerRaw({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        "integration/customer/token",
        data: {"username": email, "password": password},
        // Remove admin header for this call (Magento expects no bearer here)
        options: Options(headers: {
          "Authorization": null,
          "Content-Type": "application/json",
          "Accept": "application/json",
        }),
      );

      final token = (res.data is String) ? (res.data as String) : '${res.data ?? ''}';
      if (token.isEmpty) {
        throw Exception("Empty token returned from Magento.");
      }
      return token;
    } on DioException catch (e) {
      throw Exception(parseMagentoError(e));
    }
  }

  Future<bool> _isVendor(String token) async {
    try {
      final res = await _dio.get('customers/me', options: _auth(token));

      final data = (res.data is Map)
          ? (res.data as Map<String, dynamic>)
          : const <String, dynamic>{};

      // extension_attributes checks
      final ext = (data['extension_attributes'] ?? {}) as Map<String, dynamic>;
      final hasExtVendor = ext['is_vendor'] == true ||
          ext['is_seller'] == true ||
          (ext['seller_id'] != null && ext['seller_id'] != 0) ||
          (ext['vendor_id'] != null && ext['vendor_id'] != 0);
      if (hasExtVendor) return true;

      // custom_attributes checks
      if (data['custom_attributes'] is List) {
        for (final ca in (data['custom_attributes'] as List)) {
          if (ca is Map) {
            final code = (ca['attribute_code'] ?? '').toString();
            final val = (ca['value'] ?? '').toString().trim().toLowerCase();
            if ((code == 'is_vendor' || code == 'is_seller') && (val == '1' || val == 'true')) {
              return true;
            }
            if ((code == 'seller_id' || code == 'vendor_id') && val.isNotEmpty && val != '0') {
              return true;
            }
          }
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ---------------- Vendor Registration (Auto Vendor + Auto Login) ----------------

  Future<Map<String, dynamic>> registerVendorAndLogin({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    String? phone,
    String? businessName,
  }) async {
    final created = await createVendorAccountAdmin(
      firstname: firstname,
      lastname: lastname,
      email: email,
      password: password,
      phone: phone,
      businessName: businessName,
    );

    final token = await _loginCustomerRaw(email: email, password: password);
    await _saveTokenInternal(token, isGuest: false);

    final isVendorAccount = await _isVendor(token);
    if (!isVendorAccount) {
      throw Exception(
        'Account created but not flagged as vendor by backend. '
            'Please verify your marketplace module accepts vendor attributes.',
      );
    }

    return created;
  }

  Future<Map<String, dynamic>> createVendorAccount({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    String? phone,
    String? businessName,
  }) {
    return registerVendorAndLogin(
      firstname: firstname,
      lastname: lastname,
      email: email,
      password: password,
      phone: phone,
      businessName: businessName,
    );
  }

  Future<Map<String, dynamic>> createVendorAccountAdmin({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    String? phone,
    String? businessName,
  }) async {
    try {
      final payload = {
        "customer": {
          "email": email,
          "firstname": firstname,
          "lastname": lastname,
          "custom_attributes": [
            {"attribute_code": "is_vendor", "value": "1"},
            {"attribute_code": "vendor_status", "value": "1"},
            if (phone != null && phone.trim().isNotEmpty)
              {"attribute_code": "vendor_phone", "value": phone.trim()},
            if (businessName != null && businessName.trim().isNotEmpty)
              {"attribute_code": "business_name", "value": businessName.trim()},
          ]
        },
        "password": password,
      };

      final res = await _dio.post("customers", data: payload);
      return Map<String, dynamic>.from(res.data ?? {});
    } on DioException catch (e) {
      throw Exception(parseMagentoError(e));
    }
  }

  // ---------------- Password / Account Recovery ----------------

  Future<bool> requestPasswordReset({
    required String email,
    int websiteId = 1,
    String template = "email_reset",
  }) async {
    try {
      await _dio.put(
        "customers/password",
        data: {
          "email": email,
          "template": template,
          "websiteId": websiteId,
        },
        options: Options(headers: {"Authorization": null}),
      );
      return true;
    } on DioException catch (e) {
      throw Exception("Failed to request password reset: ${parseMagentoError(e)}");
    }
  }

  Future<bool> resetPasswordWithToken({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        "customers/resetPassword",
        data: {
          "email": email,
          "resetToken": resetToken,
          "newPassword": newPassword,
        },
        options: Options(headers: {"Authorization": null}),
      );
      return true;
    } on DioException catch (e) {
      throw Exception("Failed to reset password: ${parseMagentoError(e)}");
    }
  }

  Future<bool> changePasswordAuthenticated({
    required String currentPassword,
    required String newPassword,
    String? overrideToken,
  }) async {
    final token = overrideToken ?? (await getAuthToken());
    if (token == null || token.isEmpty) {
      throw Exception("Not logged in.");
    }
    try {
      await _dio.put(
        "customers/me/password",
        options: _auth(token),
        data: {
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        },
      );
      return true;
    } on DioException catch (e) {
      throw Exception("Failed to change password: ${parseMagentoError(e)}");
    }
  }

  // ---------------- Customers ----------------

  Future<Map<String, dynamic>?> getCustomerMe() async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) return null;
      final res = await _dio.get('customers/me', options: _auth(token));
      return Map<String, dynamic>.from(res.data);
    } on DioException {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCustomerInfo() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    try {
      final res = await _dio.get("customers/me", options: _auth(token));
      if (res.statusCode == 200) {
        return Map<String, dynamic>.from(res.data as Map);
      }
      return null;
    } catch (e) {
      throw Exception("Failed to fetch customer info: $e");
    }
  }

  // ---------------- Logout ----------------
  Future<void> logout() async {
    try {
      await clearAuthToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _secureStorage.deleteAll();
    } catch (_) {
      // ignore
    } finally {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) {
        Navigator.of(ctx).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (_) => false,
        );
      }
    });
  }

  // ---------------- Dashboard-ish helpers ----------------

  Future<List<dynamic>> getProducts({int pageSize = 1000}) async {
    try {
      final response = await _dio.get('products', queryParameters: {
        'searchCriteria[pageSize]': pageSize,
      });
      return response.data['items'] ?? [];
    } on DioException catch (e) {
      throw Exception('Failed to load products: ${parseMagentoError(e)}');
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final me = await getCustomerMe();
      if (me == null) throw Exception("Customer information not available");

      final token = await getAuthToken();
      if (token == null) throw Exception("Not authenticated");
      final vendor = await _isVendor(token);
      if (!vendor) throw Exception("User is not a vendor");

      final ordersRes = await _dio.get("orders", queryParameters: {'searchCriteria[pageSize]': 1000});
      final productsRes = await _dio.get("products", queryParameters: {'searchCriteria[pageSize]': 1000});
      final customersRes = await _dio.get("customers/search", queryParameters: {'searchCriteria[pageSize]': 1000});

      final orders = (ordersRes.data['items'] ?? []) as List<dynamic>;
      final products = (productsRes.data['items'] ?? []) as List<dynamic>;
      final customers = (customersRes.data['items'] ?? []) as List<dynamic>;

      double totalRevenue = 0;
      for (final order in orders) {
        totalRevenue += (order['grand_total'] as num?)?.toDouble() ?? 0;
      }

      return {
        'total_revenue': totalRevenue,
        'total_orders': orders.length,
        'total_products': products.length,
        'total_customers': customers.length,
        'vendor_id': me['id'] ?? 'N/A',
      };
    } on DioException catch (e) {
      throw Exception(parseMagentoError(e));
    }
  }

  Future<Map<String, double>> getSalesHistory() async {
    try {
      final response =
      await _dio.get("orders", queryParameters: {'searchCriteria[pageSize]': 1000});
      final List<dynamic> orders = response.data['items'] ?? [];
      final Map<String, double> salesByDate = {};

      for (var order in orders) {
        final date = (order['created_at'] as String?)?.substring(0, 10);
        if (date != null) {
          final grandTotal = (order['grand_total'] as num?)?.toDouble() ?? 0.0;
          salesByDate[date] = (salesByDate[date] ?? 0.0) + grandTotal;
        }
      }
      return salesByDate;
    } on DioException catch (e) {
      throw Exception(parseMagentoError(e));
    }
  }

  Future<Map<String, int>> getCustomerBreakdown() async {
    try {
      final response = await _dio.get("customers/search",
          queryParameters: {'searchCriteria[pageSize]': 1000});
      final List<dynamic> customers = response.data['items'] ?? [];

      int newer = 0, returning = 0, old = 0;
      for (final c in customers) {
        final createdAt = c['created_at'] as String?;
        if (createdAt != null) {
          final created = DateTime.tryParse(createdAt);
          if (created != null) {
            final days = DateTime.now().difference(created).inDays;
            if (days < 30) {
              newer++;
            } else if (days < 90) {
              returning++;
            } else {
              old++;
            }
          }
        }
      }

      return {
        'new': newer,
        'returning': returning,
        'old': old,
        'total': customers.length,
      };
    } on DioException catch (e) {
      throw Exception(parseMagentoError(e));
    }
  }

  Future<List<dynamic>> getTopSellingProducts() async {
    try {
      final res = await _dio.get("products", queryParameters: {
        "searchCriteria[sortOrders][0][field]": "created_at",
        "searchCriteria[sortOrders][0][direction]": "DESC",
        "searchCriteria[pageSize]": 10,
      });
      return res.data['items'] ?? [];
    } on DioException catch (e) {
      throw Exception(parseMagentoError(e));
    }
  }

  Future<List<dynamic>> getTopCategories() async {
    try {
      final res = await _dio.get("categories/list", queryParameters: {
        "searchCriteria[pageSize]": 10,
        "searchCriteria[filter_groups][0][filters][0][field]": "is_active",
        "searchCriteria[filter_groups][0][filters][0][value]": "1",
        "searchCriteria[filter_groups][0][filters][0][condition_type]": "eq",
      });
      return res.data['items'] ?? [];
    } on DioException catch (e) {
      throw Exception('Failed to load categories: ${parseMagentoError(e)}');
    }
  }

  Future<List<dynamic>> getLatestReviews() async {
    try {
      final res = await _dio.get("reviews/search", queryParameters: {
        "searchCriteria[sortOrders][0][field]": "created_at",
        "searchCriteria[sortOrders][0][direction]": "DESC",
        "searchCriteria[pageSize]": 10,
      });
      return res.data['items'] ?? [];
    } on DioException catch (e) {
      throw Exception(parseMagentoError(e));
    }
  }

  Future<Map<String, Map<int, double>>> getProductRatings() async {
    try {
      final res =
      await _dio.get("reviews/search", queryParameters: {"searchCriteria[pageSize]": 1000});
      final List<dynamic> reviews = res.data['items'] ?? [];
      final Map<int, double> price = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      final Map<int, double> value = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      final Map<int, double> quality = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

      for (final r in reviews) {
        final rating = (r['rating_summary'] as num?)?.toInt() ?? 0;
        final star = (rating ~/ 20).clamp(1, 5);
        price[star] = (price[star] ?? 0) + 1;
        value[star] = (value[star] ?? 0) + 1;
        quality[star] = (quality[star] ?? 0) + 1;
      }

      final total = reviews.length.toDouble();
      if (total > 0) {
        Map<int, double> pct(Map<int, double> m) =>
            m.map((k, v) => MapEntry(k, (v / total) * 100));
        return {'price': pct(price), 'value': pct(value), 'quality': pct(quality)};
      }

      return {
        'price': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        'value': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
        'quality': {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      };
    } on DioException catch (e) {
      throw Exception(parseMagentoError(e));
    }
  }

  // ---------------- Products CRUD ----------------

  Future<List<Map<String, dynamic>>> getDraftProducts() async {
    final token = await getAuthToken();
    if (token == null || !await _isVendor(token)) {
      throw Exception("User is not a vendor");
    }
    try {
      final res = await _dio.get("products", queryParameters: {
        "searchCriteria[filter_groups][0][filters][0][field]": "status",
        "searchCriteria[filter_groups][0][filters][0][value]": "2",
        "searchCriteria[filter_groups][0][filters][0][condition_type]": "eq",
        "searchCriteria[pageSize]": 100,
      });
      return List<Map<String, dynamic>>.from(res.data['items'] ?? []);
    } on DioException catch (e) {
      throw Exception("Failed to load drafts: ${parseMagentoError(e)}");
    }
  }

  Future<Map<String, dynamic>> createProductAsAdmin(Map<String, dynamic> productData) async {
    try {
      final res = await _dio.post("products", data: productData);
      return Map<String, dynamic>.from(res.data ?? {});
    } on DioException catch (e) {
      throw Exception("Failed to create product (admin): ${parseMagentoError(e)}");
    }
  }

  Future<Map<String, dynamic>> updateProduct(String sku, Map<String, dynamic> productData) async {
    final token = await getAuthToken();
    if (token == null || !await _isVendor(token)) {
      throw Exception("User is not a vendor");
    }
    try {
      final res = await _dio.put("products/${Uri.encodeComponent(sku)}", data: productData);
      return Map<String, dynamic>.from(res.data);
    } on DioException catch (e) {
      throw Exception("Failed to update product: ${parseMagentoError(e)}");
    }
  }

  Future<bool> deleteProduct(String sku) async {
    final token = await getAuthToken();
    if (token == null || !await _isVendor(token)) {
      throw Exception("User is not a vendor");
    }
    try {
      await _dio.delete("products/${Uri.encodeComponent(sku)}");
      return true;
    } on DioException catch (e) {
      throw Exception("Failed to delete product: ${parseMagentoError(e)}");
    }
  }

  // ---------------- Categories ----------------

  Future<List<Map<String, dynamic>>> getAllCategoriesFlat() async {
    try {
      final res = await _dio.get("categories/list", queryParameters: {
        "searchCriteria[pageSize]": 1000,
        "searchCriteria[filter_groups][0][filters][0][field]": "is_active",
        "searchCriteria[filter_groups][0][filters][0][value]": "1",
        "searchCriteria[filter_groups][0][filters][0][condition_type]": "eq",
      });

      final items = List<Map<String, dynamic>>.from(res.data['items'] ?? []);
      items.sort((a, b) {
        final la = (a['level'] as num?)?.toInt() ?? 0;
        final lb = (b['level'] as num?)?.toInt() ?? 0;
        if (la != lb) return la.compareTo(lb);
        final pa = (a['position'] as num?)?.toInt() ?? 0;
        final pb = (b['position'] as num?)?.toInt() ?? 0;
        return pa.compareTo(pb);
      });
      return items;
    } on DioException catch (e) {
      throw Exception('Failed to load categories: ${parseMagentoError(e)}');
    }
  }

  // ---------------- Vendor Orders ----------------

  Future<List<MagentoOrder>> getVendorOrders({
    int pageSize = 50,
    int currentPage = 1,
  }) async {
    final token = await getAuthToken();
    if (token == null || !await _isVendor(token)) {
      throw Exception("User is not a vendor");
    }

    try {
      final me = await getCustomerMe();
      final vendorId = me?['id']?.toString();
      final res = await _dio.get("orders", queryParameters: {
        "searchCriteria[filter_groups][0][filters][0][field]": "vendor_id",
        "searchCriteria[filter_groups][0][filters][0][value]": vendorId,
        "searchCriteria[filter_groups][0][filters][0][condition_type]": "eq",
        "searchCriteria[pageSize]": pageSize,
        "searchCriteria[currentPage]": currentPage,
        "searchCriteria[sortOrders][0][field]": "created_at",
        "searchCriteria[sortOrders][0][direction]": "DESC",
      });

      final items = List<Map<String, dynamic>>.from(res.data['items'] ?? []);
      return items.map((m) => MagentoOrder.fromJson(m)).toList();
    } on DioException catch (e) {
      throw Exception("Failed to load orders: ${parseMagentoError(e)}");
    }
  }

  Future<List<MagentoOrder>> searchVendorOrders(String query, {String? status}) async {
    final token = await getAuthToken();
    if (token == null || !await _isVendor(token)) {
      throw Exception("User is not a vendor");
    }

    try {
      final me = await getCustomerMe();
      final vendorId = me?['id']?.toString();

      final params = <String, dynamic>{
        "searchCriteria[filter_groups][0][filters][0][field]": "vendor_id",
        "searchCriteria[filter_groups][0][filters][0][value]": vendorId,
        "searchCriteria[filter_groups][0][filters][0][condition_type]": "eq",
        "searchCriteria[pageSize]": 100,
      };

      if (query.isNotEmpty) {
        params["searchCriteria[filter_groups][1][filters][0][field]"] = "increment_id";
        params["searchCriteria[filter_groups][1][filters][0][value]"] = "%$query%";
        params["searchCriteria[filter_groups][1][filters][0][condition_type]"] = "like";
      }

      if (status != null && status != 'all') {
        params["searchCriteria[filter_groups][2][filters][0][field]"] = "status";
        params["searchCriteria[filter_groups][2][filters][0][value]"] = status;
        params["searchCriteria[filter_groups][2][filters][0][condition_type]"] = "eq";
      }

      final res = await _dio.get("orders", queryParameters: params);
      final items = List<Map<String, dynamic>>.from(res.data['items'] ?? []);
      return items.map((m) => MagentoOrder.fromJson(m)).toList();
    } on DioException catch (e) {
      throw Exception("Failed to search orders: ${parseMagentoError(e)}");
    }
  }

  Future<MagentoOrder> getOrderDetails(String orderId) async {
    try {
      final res = await _dio.get("orders/$orderId");
      return MagentoOrder.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception("Failed to load order details: ${parseMagentoError(e)}");
    }
  }

  // ---------------- Admin: Products / Orders / Customers ----------------

  Future<List<Map<String, dynamic>>> getProductsAdmin({int pageSize = 1000}) async {
    try {
      final res =
      await _dio.get("products", queryParameters: {"searchCriteria[pageSize]": pageSize});
      return List<Map<String, dynamic>>.from(res.data?['items'] ?? const []);
    } on DioException catch (e) {
      throw Exception('Failed to load products: ${parseMagentoError(e)}');
    }
  }

  Future<List<Map<String, dynamic>>> getOrdersAdmin({
    DateTime? dateFrom,
    DateTime? dateTo,
    int pageSize = 100,
    int currentPage = 1,
  }) async {
    try {
      final qp = <String, dynamic>{
        'searchCriteria[pageSize]': pageSize,
        'searchCriteria[currentPage]': currentPage,
      };

      int gid = 0;
      if (dateFrom != null) {
        qp['searchCriteria[filter_groups][$gid][filters][0][field]'] = 'created_at';
        qp['searchCriteria[filter_groups][$gid][filters][0][value]'] =
            dateFrom.toUtc().toIso8601String();
        qp['searchCriteria[filter_groups][$gid][filters][0][condition_type]'] = 'gteq';
        gid++;
      }
      if (dateTo != null) {
        qp['searchCriteria[filter_groups][$gid][filters][0][field]'] = 'created_at';
        qp['searchCriteria[filter_groups][$gid][filters][0][value]'] =
            dateTo.toUtc().toIso8601String();
        qp['searchCriteria[filter_groups][$gid][filters][0][condition_type]'] = 'lteq';
        gid++;
      }

      final res = await _dio.get('orders', queryParameters: qp);
      return List<Map<String, dynamic>>.from(res.data?['items'] ?? const []);
    } on DioException catch (e) {
      throw Exception('Failed to load orders: ${parseMagentoError(e)}');
    }
  }

  Future<List<Map<String, dynamic>>> getAllOrdersAdminPaged({
    DateTime? dateFrom,
    DateTime? dateTo,
    int pageSize = 100,
    int maxPages = 3,
  }) async {
    final List<Map<String, dynamic>> all = [];
    for (int page = 1; page <= maxPages; page++) {
      final batch = await getOrdersAdmin(
        dateFrom: dateFrom,
        dateTo: dateTo,
        pageSize: pageSize,
        currentPage: page,
      );
      if (batch.isEmpty) break;
      all.addAll(batch);
      if (batch.length < pageSize) break;
    }
    return all;
  }

  Future<List<Map<String, dynamic>>> getCustomersAdmin({
    int currentPage = 1,
    int pageSize = 50,
    String? searchEmailLike,
  }) async {
    final qp = <String, dynamic>{
      'searchCriteria[currentPage]': currentPage,
      'searchCriteria[pageSize]': pageSize,
      'searchCriteria[sortOrders][0][field]': 'created_at',
      'searchCriteria[sortOrders][0][direction]': 'DESC',
    };

    int fg = 0;
    if (searchEmailLike != null && searchEmailLike.trim().isNotEmpty) {
      qp['searchCriteria[filter_groups][$fg][filters][0][field]'] = 'email';
      qp['searchCriteria[filter_groups][$fg][filters][0][value]'] = '%$searchEmailLike%';
      qp['searchCriteria[filter_groups][$fg][filters][0][condition_type]'] = 'like';
      fg++;
    }

    try {
      final resp = await _dio.get('customers/search', queryParameters: qp);
      return List<Map<String, dynamic>>.from(resp.data?['items'] ?? const []);
    } on DioException catch (e) {
      throw Exception('Failed to load customers: ${parseMagentoError(e)}');
    }
  }

  // ---------------- Invoices (Admin) ----------------

  Future<Map<String, dynamic>> getInvoiceById({required int invoiceId}) async {
    try {
      final resp = await _dio.get('invoices/$invoiceId');
      return Map<String, dynamic>.from(resp.data ?? const {});
    } on DioException catch (e) {
      throw Exception('Failed to load invoice: ${parseMagentoError(e)}');
    }
  }

  Future<List<Map<String, dynamic>>> getInvoiceComments({required int invoiceId}) async {
    try {
      final resp = await _dio.get('invoices/$invoiceId/comments');
      return List<Map<String, dynamic>>.from(resp.data ?? const []);
    } on DioException catch (e) {
      throw Exception('Failed to load invoice comments: ${parseMagentoError(e)}');
    }
  }

  Future<void> addInvoiceComment({
    required int invoiceId,
    required String comment,
    bool isVisibleOnFront = false,
    bool isCustomerNotified = false,
  }) async {
    try {
      await _dio.post(
        'invoices/$invoiceId/comments',
        data: {
          "comment": comment,
          "is_visible_on_front": isVisibleOnFront,
          "is_customer_notified": isCustomerNotified,
        },
      );
    } on DioException catch (e) {
      throw Exception('Failed to add invoice comment: ${parseMagentoError(e)}');
    }
  }

  // ---------------- Reviews ----------------

  Future<ReviewPage> getProductReviewsAdmin({
    required int page,
    required int pageSize,
    int? statusEq,
  }) async {
    final params = <String, dynamic>{
      'searchCriteria[currentPage]': page,
      'searchCriteria[pageSize]': pageSize,
    };

    if (statusEq != null) {
      params['searchCriteria[filterGroups][99][filters][0][field]'] = 'status';
      params['searchCriteria[filterGroups][99][filters][0][value]'] = statusEq.toString();
      params['searchCriteria[filterGroups][99][filters][0][condition_type]'] = 'eq';
    }

    try {
      final resp = await _dio.get('reviews', queryParameters: params);
      final data = resp.data is Map ? resp.data as Map : const {};
      final itemsRaw = (data['items'] is List) ? (data['items'] as List) : const [];
      final total = (data['total_count'] is int)
          ? data['total_count'] as int
          : (data['total_count'] is String ? int.tryParse('${data['total_count']}') ?? 0 : 0);

      final items =
      itemsRaw.map<MagentoReview>((e) => MagentoReview.fromJson(e as Map)).toList();
      return ReviewPage(items: items, totalCount: total);
    } on DioException catch (e) {
      throw Exception('Failed to load reviews: ${parseMagentoError(e)}');
    }
  }

  /// Lightweight product fetch used by Reviews screen.
  /// Returns the raw product (id, sku, name, type_id, price, custom_attributes, media_gallery_entries).
  Future<Map<String, dynamic>> getProductLiteBySku({required String sku}) async {
    try {
      // Attempt with `fields` to reduce payload (some Magento setups may ignore it).
      final res = await _dio.get(
        'products/${Uri.encodeComponent(sku)}',
        queryParameters: {
          'fields':
          'id,sku,name,type_id,price,custom_attributes,media_gallery_entries[file]',
        },
      );
      return Map<String, dynamic>.from(res.data ?? const {});
    } on DioException catch (e) {
      // Fallback without fields if store disallows it
      if (e.response?.statusCode == 400 || e.response?.statusCode == 422) {
        final res = await _dio.get('products/${Uri.encodeComponent(sku)}');
        return Map<String, dynamic>.from(res.data ?? const {});
      }
      throw Exception('Failed to fetch product $sku: ${parseMagentoError(e)}');
    }
  }

  String get mediaBaseUrlForCatalog {
    final b = _dio.options.baseUrl; // .../rest/V1/
    final root = b.replaceFirst(RegExp(r'/rest/.*$'), '').replaceFirst(RegExp(r'/$'), '');
    return '$root/pub/media/catalog/product';
  }

  /// Media base for vendor images (adjust if your instance differs)
  String get mediaBaseUrlForVendor {
    final b = _dio.options.baseUrl; // .../rest/V1/
    final root = b.replaceFirst(RegExp(r'/rest/.*$'), '').replaceFirst(RegExp(r'/$'), '');
    return '$root/pub/media';
  }

  String guessMimeFromName(String filename) {
    final lower = filename.trim().toLowerCase();

    if (lower.endsWith('.tar.gz')) return 'application/gzip';
    if (lower.endsWith('.svgz')) return 'image/svg+xml';

    final dot = lower.lastIndexOf('.');
    if (dot == -1 || dot == lower.length - 1) {
      return 'application/octet-stream';
    }

    final ext = lower.substring(dot + 1);
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'tif':
      case 'tiff':
        return 'image/tiff';
      case 'heic':
      case 'heif':
        return 'image/heic';
      case 'svg':
        return 'image/svg+xml';
      case 'ico':
        return 'image/x-icon';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'json':
        return 'application/json';
      case 'zip':
        return 'application/zip';
      case 'gz':
        return 'application/gzip';
      case 'tar':
        return 'application/x-tar';
      default:
        return 'application/octet-stream';
    }
  }

  // ---------- VENDOR PROFILE (CUSTOMER) ----------

  // Attribute codes to persist the vendor profile (edit to match your backend)
  static const _attrCompanyName = 'vendor_company_name';
  static const _attrBio = 'vendor_bio';
  static const _attrCountry = 'vendor_country';
  static const _attrPhone = 'vendor_phone';
  static const _attrLowStockQty = 'vendor_low_stock_qty';
  static const _attrVat = 'vendor_vat_number';
  static const _attrPayment = 'vendor_payment_details';

  static const _attrTwitter = 'vendor_twitter';
  static const _attrFacebook = 'vendor_facebook';
  static const _attrInstagram = 'vendor_instagram';
  static const _attrYoutube = 'vendor_youtube';
  static const _attrVimeo = 'vendor_vimeo';
  static const _attrPinterest = 'vendor_pinterest';
  static const _attrMoleskine = 'vendor_moleskine';
  static const _attrTiktok = 'vendor_tiktok';

  static const _attrReturnPolicy = 'vendor_return_policy';
  static const _attrShippingPolicy = 'vendor_shipping_policy';
  static const _attrPrivacyPolicy = 'vendor_privacy_policy';

  static const _attrMetaKeywords = 'vendor_meta_keywords';
  static const _attrMetaDescription = 'vendor_meta_description';
  static const _attrGoogleAnalytics = 'vendor_google_analytics';

  static const _attrProfileReq = 'vendor_profile_request_path';
  static const _attrCollectionReq = 'vendor_collection_request_path';
  static const _attrReviewReq = 'vendor_review_request_path';
  static const _attrLocationReq = 'vendor_location_request_path';
  static const _attrPrivacyReq = 'vendor_privacy_request_path';

  // Image handling
  static const _attrLogoUrl = 'vendor_logo';
  static const _attrBannerUrl = 'vendor_banner';
  static const _attrLogoBase64 = 'vendor_logo_base64';
  static const _attrBannerBase64 = 'vendor_banner_base64';

  /// Helper to read a custom attribute value by code from a customer map
  String? _readCA(Map m, String code) {
    if (m['custom_attributes'] is List) {
      for (final a in (m['custom_attributes'] as List)) {
        if (a is Map && (a['attribute_code']?.toString() ?? '') == code) {
          final v = a['value'];
          return v == null ? null : v.toString();
        }
      }
    }
    return null;
  }

  /// Helper to write/replace a custom attribute in the payload
  void _putCA(List list, String code, String? value) {
    if (value == null) return;
    list.removeWhere((e) => e is Map && (e['attribute_code']?.toString() ?? '') == code);
    list.add({'attribute_code': code, 'value': value});
  }

  /// Load current logged-in vendor profile from customers/me
  Future<VendorProfile?> getVendorProfileMe() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) return null;

    try {
      final res = await _dio.get('customers/me', options: _auth(token));
      final m = (res.data as Map);
      final id = (m['id'] is int) ? m['id'] as int : int.tryParse('${m['id'] ?? ''}') ?? 0;

      final p = VendorProfile(
        customerId: id,
        companyName: _readCA(m, _attrCompanyName),
        bio: _readCA(m, _attrBio),
        country: _readCA(m, _attrCountry),
        phone: _readCA(m, _attrPhone),
        lowStockQty: _readCA(m, _attrLowStockQty),
        vatNumber: _readCA(m, _attrVat),
        paymentDetails: _readCA(m, _attrPayment),
        logoUrl: _readCA(m, _attrLogoUrl),
        bannerUrl: _readCA(m, _attrBannerUrl),
        logoBase64: _readCA(m, _attrLogoBase64),
        bannerBase64: _readCA(m, _attrBannerBase64),
        twitter: _readCA(m, _attrTwitter),
        facebook: _readCA(m, _attrFacebook),
        instagram: _readCA(m, _attrInstagram),
        youtube: _readCA(m, _attrYoutube),
        vimeo: _readCA(m, _attrVimeo),
        pinterest: _readCA(m, _attrPinterest),
        moleskine: _readCA(m, _attrMoleskine),
        tiktok: _readCA(m, _attrTiktok),
        returnPolicy: _readCA(m, _attrReturnPolicy),
        shippingPolicy: _readCA(m, _attrShippingPolicy),
        privacyPolicy: _readCA(m, _attrPrivacyPolicy),
        metaKeywords: _readCA(m, _attrMetaKeywords),
        metaDescription: _readCA(m, _attrMetaDescription),
        googleAnalyticsId: _readCA(m, _attrGoogleAnalytics),
        profilePathReq: _readCA(m, _attrProfileReq),
        collectionPathReq: _readCA(m, _attrCollectionReq),
        reviewPathReq: _readCA(m, _attrReviewReq),
        locationPathReq: _readCA(m, _attrLocationReq),
        privacyPathReq: _readCA(m, _attrPrivacyReq),
      );
      return p;
    } on DioException catch (e) {
      throw Exception('Failed to load vendor profile: ${parseMagentoError(e)}');
    }
  }

  /// Update current logged-in vendor profile (customers/me)
  Future<void> updateVendorProfileMe(VendorProfile profile) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    // Build custom attributes list to send
    final ca = <Map<String, dynamic>>[];
    _putCA(ca, _attrCompanyName, profile.companyName);
    _putCA(ca, _attrBio, profile.bio);
    _putCA(ca, _attrCountry, profile.country);
    _putCA(ca, _attrPhone, profile.phone);
    _putCA(ca, _attrLowStockQty, profile.lowStockQty);
    _putCA(ca, _attrVat, profile.vatNumber);
    _putCA(ca, _attrPayment, profile.paymentDetails);

    _putCA(ca, _attrLogoUrl, profile.logoUrl);
    _putCA(ca, _attrBannerUrl, profile.bannerUrl);
    _putCA(ca, _attrLogoBase64, profile.logoBase64);
    _putCA(ca, _attrBannerBase64, profile.bannerBase64);

    _putCA(ca, _attrTwitter, profile.twitter);
    _putCA(ca, _attrFacebook, profile.facebook);
    _putCA(ca, _attrInstagram, profile.instagram);
    _putCA(ca, _attrYoutube, profile.youtube);
    _putCA(ca, _attrVimeo, profile.vimeo);
    _putCA(ca, _attrPinterest, profile.pinterest);
    _putCA(ca, _attrMoleskine, profile.moleskine);
    _putCA(ca, _attrTiktok, profile.tiktok);

    _putCA(ca, _attrReturnPolicy, profile.returnPolicy);
    _putCA(ca, _attrShippingPolicy, profile.shippingPolicy);
    _putCA(ca, _attrPrivacyPolicy, profile.privacyPolicy);

    _putCA(ca, _attrMetaKeywords, profile.metaKeywords);
    _putCA(ca, _attrMetaDescription, profile.metaDescription);
    _putCA(ca, _attrGoogleAnalytics, profile.googleAnalyticsId);

    _putCA(ca, _attrProfileReq, profile.profilePathReq);
    _putCA(ca, _attrCollectionReq, profile.collectionPathReq);
    _putCA(ca, _attrReviewReq, profile.reviewPathReq);
    _putCA(ca, _attrLocationReq, profile.locationPathReq);
    _putCA(ca, _attrPrivacyReq, profile.privacyPathReq);

    final payload = {
      'customer': {
        'id': profile.customerId,
        'custom_attributes': ca,
      }
    };

    try {
      await _dio.put('customers/me', data: payload, options: _auth(token));
    } on DioException catch (e) {
      throw Exception('Failed to update vendor profile: ${parseMagentoError(e)}');
    }
  }

  /// Get vendor products (for VendorProfileScreen) — requires your store to have a vendor_id
  Future<List<Map<String, dynamic>>> getProductsByVendor({
    required int vendorId,
    int pageSize = 20,
    int currentPage = 1,
  }) async {
    final qp = <String, dynamic>{
      'searchCriteria[pageSize]': pageSize,
      'searchCriteria[currentPage]': currentPage,
      'searchCriteria[sortOrders][0][field]': 'created_at',
      'searchCriteria[sortOrders][0][direction]': 'DESC',
      'searchCriteria[filter_groups][0][filters][0][field]': 'vendor_id',
      'searchCriteria[filter_groups][0][filters][0][value]': vendorId.toString(),
      'searchCriteria[filter_groups][0][filters][0][condition_type]': 'eq',
    };

    try {
      final res = await _dio.get('products', queryParameters: qp);
      final items = List<Map<String, dynamic>>.from(res.data?['items'] ?? const []);
      return items;
    } on DioException catch (e) {
      throw Exception('Failed to load vendor products: ${parseMagentoError(e)}');
    }
  }

  /// Extract product image URL from Magento product map.
  String productImageUrl(Map<String, dynamic> p) {
    String? rel;
    if (p['media_gallery_entries'] is List && (p['media_gallery_entries'] as List).isNotEmpty) {
      final first = (p['media_gallery_entries'] as List).first;
      if (first is Map && first['file'] is String) {
        rel = first['file'] as String;
      }
    }
    if (rel == null && p['custom_attributes'] is List) {
      for (final a in (p['custom_attributes'] as List)) {
        if (a is Map && a['attribute_code'] == 'image' && a['value'] is String) {
          rel = a['value'] as String;
          break;
        }
      }
    }
    if (rel == null || rel.isEmpty) return '';
    final root = mediaBaseUrlForCatalog; // .../pub/media/catalog/product
    if (rel.startsWith('/')) rel = rel.substring(1);
    return '$root/$rel';
  }

  // ---------------- Errors ----------------
  String parseMagentoError(
      Object error, {
        String fallback = 'An unknown error occurred',
      }) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
      if (data is Map && data['parameters'] is List && (data['parameters'] as List).isNotEmpty) {
        return '${data['message']} (${(data['parameters'] as List).join(", ")})';
      }
      if (data is String && data.isNotEmpty) return data;
      return error.message ?? fallback;
    }
    return error.toString();
  }
}
