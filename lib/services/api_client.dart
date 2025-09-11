import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorApiClient {
  static final VendorApiClient _instance = VendorApiClient._internal();
  factory VendorApiClient() => _instance;
  VendorApiClient._internal();
  int? _vendorId;
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://kolshy.ae/rest/V1/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer 87igct1wbbphdok6dk1roju4i83kyub9', // Add admin token here
      },
    ),
  );

  String? _token;
  static const String _adminToken = "87igct1wbbphdok6dk1roju4i83kyub9";
  bool get hasToken => _token != null && _token!.isNotEmpty;

  // ==========================
  // Init / Token helpers
  // ==========================
  Future<void> init() async {
    _token = await _getToken();
    _setAuthHeader(_token);

    if (_token != null && _token!.isNotEmpty) {
      try {
        final profile = await getVendorProfile();
        _vendorId = profile.customerId;
      } catch (e) {
        print('Failed to get vendor ID: $e');
      }
    }
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vendor_token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vendor_token');
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('vendor_token');
  }

  void _setAuthHeader(String? token) {
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }
  Future<int> getVendorId() async {
    if (_vendorId != null) return _vendorId!;

    final profile = await getVendorProfile();
    _vendorId = profile.customerId;
    return _vendorId!;
  }
  // Centralized error parsing (also exposed via parseMagentoError)
  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data['message'] is String) {
        return 'API error: ${data['message']}';
      }
      if (data is String && data.isNotEmpty) {
        return 'API error: $data';
      }
      return 'HTTP ${e.response!.statusCode}: ${e.message}';
    }
    return 'Network error: ${e.message}';
  }

  // ==========================
  // 🔐 Authentication
  // ==========================
  Future<String> loginVendor(String email, String password) async {
    try {
      // Use customer login endpoint
      final response = await _dio.post(
        'integration/customer/token',
        data: {"username": email, "password": password},
      );

      final token = response.data.toString();
      if (token.isNotEmpty) {
        await saveToken(token);
        _token = token;
        _setAuthHeader(_token);
        return token;
      }
      throw Exception('Login failed: Invalid token received.');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }


  Future<Map<String, dynamic>> registerVendor(
      String email,
      String firstName,
      String lastName,
      String password,
      String shopUrl,
      String phone,
      ) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';

      final response = await _dio.post(
        'customers',
        data: {
          "customer": {
            "email": email,
            "firstname": firstName,
            "lastname": lastName,
            "website_id": 1,
            "store_id": 1,
          },
          "password": password,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }


  Future<bool> forgotPassword(String email) async {
    try {
      await _dio.put(
        "customers/password",
        data: {"email": email, "template": "email_reset", "websiteId": 1},
      );
      return true;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> logout() async {
    await removeToken();
    _token = null;
    _setAuthHeader(null);
  }

  // ==========================
  // 👤 VENDOR PROFILE (Customer endpoints)
  // ==========================
  Future<VendorProfile> getVendorProfile() async {
    try {
      final response = await _dio.get('customers/me');
      return VendorProfile.fromJson(Map<String, dynamic>.from(response.data));
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<VendorProfile> getVendorProfileMe() => getVendorProfile();

  Future<void> updateVendorProfileMe(Map<String, dynamic> vendorData) async {
    try {
      await _dio.put(
        'customers/me',
        data: jsonEncode({'customer': vendorData}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // ==========================
// 📊 DASHBOARD ANALYTICS FUNCTIONS
// ==========================

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get vendor ID first
      final vendorProfile = await getVendorProfile();
      final vendorId = vendorProfile.customerId;

      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';

      // Get orders for this specific vendor
      final ordersResponse = await _dio.get(
        'orders',
        queryParameters: {
          'searchCriteria[filterGroups][0][filters][0][field]': 'vendor_id',
          'searchCriteria[filterGroups][0][filters][0][value]': vendorId,
          'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
          'searchCriteria[pageSize]': 1,
          'searchCriteria[currentPage]': 1,
        },
      );

      final orders = ordersResponse.data['items'] ?? [];
      final totalOrders = ordersResponse.data['total_count'] ?? 0;

      // Calculate total revenue for this vendor
      double totalRevenue = 0;
      for (var order in orders) {
        totalRevenue += double.tryParse(order['grand_total']?.toString() ?? '0') ?? 0;
      }

      // Get products for this vendor
      final productsResponse = await _dio.get(
        'products',
        queryParameters: {
          'searchCriteria[filterGroups][0][filters][0][field]': 'vendor_id',
          'searchCriteria[filterGroups][0][filters][0][value]': vendorId,
          'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
          'searchCriteria[pageSize]': 1,
        },
      );
      final totalProducts = productsResponse.data['total_count'] ?? 0;

      // Get pending orders for this vendor
      final pendingOrdersResponse = await _dio.get(
        'orders',
        queryParameters: {
          'searchCriteria[filterGroups][0][filters][0][field]': 'vendor_id',
          'searchCriteria[filterGroups][0][filters][0][value]': vendorId,
          'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
          'searchCriteria[filterGroups][1][filters][0][field]': 'status',
          'searchCriteria[filterGroups][1][filters][0][value]': 'pending',
          'searchCriteria[pageSize]': 1,
        },
      );
      final pendingOrders = pendingOrdersResponse.data['total_count'] ?? 0;

      return {
        'total_orders': totalOrders,
        'total_revenue': totalRevenue,
        'total_products': totalProducts,
        'pending_orders': pendingOrders,
      };
    } on DioException catch (e) {
      return {
        'total_orders': 0,
        'total_revenue': 0,
        'total_products': 0,
        'pending_orders': 0,
      };
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<List<Map<String, dynamic>>> getSalesHistory({int days = 30}) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';

      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));
      final response = await _dio.get(
        'orders',
        queryParameters: {
          'searchCriteria[filterGroups][0][filters][0][field]': 'created_at',
          'searchCriteria[filterGroups][0][filters][0][value]': startDate.toIso8601String(),
          'searchCriteria[filterGroups][0][filters][0][condition_type]': 'gteq',
          'searchCriteria[pageSize]': 100,
        },
      );

      final orders = List<Map<String, dynamic>>.from(response.data['items'] ?? []);

      // Group sales by date
      final salesByDate = <String, double>{};
      for (var order in orders) {
        final date = order['created_at']?.toString().split(' ')[0] ?? '';
        final amount = double.tryParse(order['grand_total']?.toString() ?? '0') ?? 0;

        if (salesByDate.containsKey(date)) {
          salesByDate[date] = salesByDate[date]! + amount;
        } else {
          salesByDate[date] = amount;
        }
      }

      // Convert to list format
      return salesByDate.entries.map((entry) => {
        'date': entry.key,
        'amount': entry.value,
      }).toList();
    } on DioException catch (e) {
      return [];
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<Map<String, dynamic>> getCustomerBreakdown() async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';

      final response = await _dio.get(
        'customers/search',
        queryParameters: {
          'searchCriteria[pageSize]': 100,
        },
      );

      final customers = List<Map<String, dynamic>>.from(response.data['items'] ?? []);

      // Simple breakdown - you can enhance this based on customer attributes
      return {
        'total_customers': customers.length,
        'new_customers': customers.where((c) {
          final created = c['created_at']?.toString();
          if (created == null) return false;
          final createdDate = DateTime.parse(created.split(' ')[0]);
          return createdDate.isAfter(DateTime.now().subtract(const Duration(days: 30)));
        }).length,
        'returning_customers': customers.length,
      };
    } on DioException catch (e) {
      return {
        'total_customers': 0,
        'new_customers': 0,
        'returning_customers': 0,
      };
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<List<Map<String, dynamic>>> getTopSellingProducts({int limit = 10}) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';

      final response = await _dio.get(
        'products',
        queryParameters: {
          'searchCriteria[pageSize]': limit,
          'searchCriteria[sortOrders][0][field]': 'created_at',
          'searchCriteria[sortOrders][0][direction]': 'DESC',
        },
      );

      final products = List<Map<String, dynamic>>.from(response.data['items'] ?? []);

      return products.map((product) => {
        'id': product['id'],
        'name': product['name'],
        'sku': product['sku'],
        'price': product['price'],
        'image': product['media_gallery_entries']?[0]?['file'] ?? '',
        'qty_sold': 0, // Magento doesn't provide this directly
      }).toList();
    } on DioException catch (e) {
      return [];
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<List<Map<String, dynamic>>> getTopCategories({int limit = 5}) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';

      final response = await _dio.get('categories');
      final categories = List<Map<String, dynamic>>.from(response.data['children_data'] ?? []);

      return categories.take(limit).map((category) => {
        'id': category['id'],
        'name': category['name'],
        'product_count': category['product_count'] ?? 0,
      }).toList();
    } on DioException catch (e) {
      return [];
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<List<Map<String, dynamic>>> getProductRatings() async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';

      final response = await _dio.get(
        'reviews',
        queryParameters: {
          'searchCriteria[pageSize]': 20,
        },
      );

      final reviews = List<Map<String, dynamic>>.from(response.data['items'] ?? []);

      // Calculate average ratings per product
      final productRatings = <String, List<int>>{};
      for (var review in reviews) {
        final productSku = review['extension_attributes']?['sku'] ?? review['product_sku'];
        final rating = review['ratings']?[0]?['value'] ?? review['rating_votes']?[0]?['value'];

        if (productSku != null && rating != null) {
          if (productRatings.containsKey(productSku)) {
            productRatings[productSku]!.add(int.tryParse(rating.toString()) ?? 0);
          } else {
            productRatings[productSku] = [int.tryParse(rating.toString()) ?? 0];
          }
        }
      }

      return productRatings.entries.map((entry) => {
        'product_sku': entry.key,
        'average_rating': entry.value.isEmpty ? 0 : entry.value.reduce((a, b) => a + b) / entry.value.length,
        'total_reviews': entry.value.length,
      }).toList();
    } on DioException catch (e) {
      return [];
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<List<Map<String, dynamic>>> getLatestReviews({int limit = 10}) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';

      final response = await _dio.get(
        'reviews',
        queryParameters: {
          'searchCriteria[pageSize]': limit,
          'searchCriteria[sortOrders][0][field]': 'created_at',
          'searchCriteria[sortOrders][0][direction]': 'DESC',
        },
      );

      final reviews = List<Map<String, dynamic>>.from(response.data['items'] ?? []);

      return reviews.map((review) => {
        'id': review['id'],
        'title': review['title'],
        'detail': review['detail'],
        'nickname': review['nickname'],
        'created_at': review['created_at'],
        'rating': review['ratings']?[0]?['value'] ?? review['rating_votes']?[0]?['value'] ?? 0,
        'product_sku': review['extension_attributes']?['sku'] ?? review['product_sku'],
      }).toList();
    } on DioException catch (e) {
      return [];
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<Map<String, dynamic>> getCustomerInfo() async {
    try {
      // Use customer endpoint for basic info
      final response = await _dio.get('customers/me');
      final customerData = Map<String, dynamic>.from(response.data);

      return {
        'id': customerData['id'],
        'email': customerData['email'],
        'firstname': customerData['firstname'],
        'lastname': customerData['lastname'],
        'phone': customerData['telephone'] ?? customerData['phone'],
        'created_at': customerData['created_at'],
      };
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<VendorProfile> getVendorInfo() async => getVendorProfile();

  Future<List<dynamic>> getVendorProducts({
    int pageSize = 20,
    int currentPage = 1,
  }) async {
    try {
      // First get vendor profile to get the vendor ID
      final vendorProfile = await getVendorProfile();

      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
      final response = await _dio.get(
        'products',
        queryParameters: {
          'searchCriteria[filterGroups][0][filters][0][field]': 'vendor_id',
          'searchCriteria[filterGroups][0][filters][0][value]': vendorProfile.customerId,
          'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
          'searchCriteria[pageSize]': pageSize,
          'searchCriteria[currentPage]': currentPage,
        },
      );
      return response.data['items'] ?? [];
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<List<dynamic>> getProductsByVendor({
    required int vendorId,
    int pageSize = 20,
    int currentPage = 1,
  }) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
      final res = await _dio.get(
        'products',
        queryParameters: {
          'searchCriteria[filterGroups][0][filters][0][field]': 'vendor_id',
          'searchCriteria[filterGroups][0][filters][0][value]': vendorId,
          'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
          'searchCriteria[pageSize]': pageSize,
          'searchCriteria[currentPage]': currentPage,
        },
      );
      return res.data['items'] ?? [];
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<List<dynamic>> getVendorReviews({
    int pageSize = 20,
    int currentPage = 1,
  }) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
      final response = await _dio.get(
        'reviews',
        queryParameters: {
          'searchCriteria[pageSize]': pageSize,
          'searchCriteria[currentPage]': currentPage,
        },
      );
      return response.data['items'] ?? [];
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<List<MagentoOrder>> searchVendorOrders(
      String searchQuery, {
        String? status,
        int pageSize = 20,
        int currentPage = 1,
      }) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
      final queryParams = {
        'searchCriteria[filterGroups][0][filters][0][field]': 'increment_id',
        'searchCriteria[filterGroups][0][filters][0][value]': '%$searchQuery%',
        'searchCriteria[filterGroups][0][filters][0][conditionType]': 'like',
        'searchCriteria[pageSize]': '$pageSize',
        'searchCriteria[currentPage]': '$currentPage',
      };

      if (status != null) {
        queryParams['searchCriteria[filterGroups][1][filters][0][field]'] = 'status';
        queryParams['searchCriteria[filterGroups][1][filters][0][value]'] = status;
      }

      final response = await _dio.get('orders', queryParameters: queryParams);
      final ordersJson = (response.data['items'] as List?) ?? [];
      return ordersJson.map((json) => MagentoOrder.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<List<Map<String, dynamic>>> getVendorOrders({
    DateTime? dateFrom,
    DateTime? dateTo,
    int currentPage = 1,
    int pageSize = 20,
  }) async {
    try {
      final vendorId = await getVendorId();

      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
      final response = await _dio.get(
        'orders',
        queryParameters: {
          'searchCriteria[filterGroups][0][filters][0][field]': 'vendor_id',
          'searchCriteria[filterGroups][0][filters][0][value]': vendorId,
          'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
          'searchCriteria[currentPage]': currentPage,
          'searchCriteria[pageSize]': pageSize,
        },
      );
      return List<Map<String, dynamic>>.from(response.data['items'] ?? []);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  // ==========================
  // 🛍️ CATALOG (Admin token)
  // ==========================
  Future<List<dynamic>> getProducts({
    int pageSize = 50,
    int currentPage = 1,
  }) async {
    try {
      final vendorId = await getVendorId();

      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
      final response = await _dio.get(
        'products',
        queryParameters: {
          'searchCriteria[filterGroups][0][filters][0][field]': 'vendor_id',
          'searchCriteria[filterGroups][0][filters][0][value]': vendorId,
          'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
          'searchCriteria[pageSize]': pageSize,
          'searchCriteria[currentPage]': currentPage,
        },
      );
      return response.data['items'] ?? [];
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<List<dynamic>> getDraftProducts({
    int pageSize = 20,
    int currentPage = 1,
  }) async {
    try {
      final vendorId = await getVendorId();

      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
      final response = await _dio.get(
        'products',
        queryParameters: {
          'searchCriteria[filterGroups][0][filters][0][field]': 'status',
          'searchCriteria[filterGroups][0][filters][0][value]': 0,
          'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
          'searchCriteria[filterGroups][1][filters][0][field]': 'vendor_id',
          'searchCriteria[filterGroups][1][filters][0][value]': vendorId,
          'searchCriteria[filterGroups][1][filters][0][conditionType]': 'eq',
          'searchCriteria[pageSize]': pageSize,
          'searchCriteria[currentPage]': currentPage,
        },
      );
      return response.data['items'] ?? [];
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<Map<String, dynamic>> getProductLiteBySku({required String sku}) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
      final response = await _dio.get(
        'products',
        queryParameters: {
          'searchCriteria[filterGroups][0][filters][0][field]': 'sku',
          'searchCriteria[filterGroups][0][filters][0][value]': sku,
          'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
          'fields': 'items[sku,name,type_id,image,media_gallery_entries[file],custom_attributes[attribute_code,value]]',
        },
      );
      final items = (response.data['items'] as List?) ?? [];
      if (items.isEmpty) {
        throw Exception('Product with SKU $sku not found.');
      }
      return Map<String, dynamic>.from(items.first);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<MagentoProduct> getProductDetailsBySku(String sku) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
      final response = await _dio.get(
        'products',
        queryParameters: {
          'searchCriteria[filterGroups][0][filters][0][field]': 'sku',
          'searchCriteria[filterGroups][0][filters][0][value]': sku,
          'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
        },
      );
      final items = (response.data['items'] as List?) ?? [];
      if (items.isNotEmpty) return MagentoProduct.fromJson(items.first);
      throw Exception('Product with SKU $sku not found.');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  // ==========================
  // 🧑‍💼 ADMIN ENDPOINTS (Admin token)
  // ==========================
  Future<List<Map<String, dynamic>>> getCustomersAdmin({
    int currentPage = 1,
    int pageSize = 20,
  }) async {
    _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
    try {
      final response = await _dio.get(
        'customers/search',
        queryParameters: {
          'searchCriteria[currentPage]': currentPage,
          'searchCriteria[pageSize]': pageSize,
        },
      );
      final data = response.data;
      return List<Map<String, dynamic>>.from(data['items'] ?? []);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<List<Map<String, dynamic>>> getOrdersAdmin({
    DateTime? dateFrom,
    DateTime? dateTo,
    int currentPage = 1,
    int pageSize = 20,
  }) async {
    _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
    final Map<String, dynamic> queryParameters = {
      'searchCriteria[currentPage]': currentPage,
      'searchCriteria[pageSize]': pageSize,
    };

    var filterIndex = 0;
    if (dateFrom != null) {
      queryParameters['searchCriteria[filter_groups][$filterIndex][filters][0][field]'] = 'created_at';
      queryParameters['searchCriteria[filter_groups][$filterIndex][filters][0][value]'] = dateFrom.toIso8601String();
      queryParameters['searchCriteria[filter_groups][$filterIndex][filters][0][condition_type]'] = 'gteq';
      filterIndex++;
    }
    if (dateTo != null) {
      queryParameters['searchCriteria[filter_groups][$filterIndex][filters][0][field]'] = 'created_at';
      queryParameters['searchCriteria[filter_groups][$filterIndex][filters][0][value]'] = dateTo.toIso8601String();
      queryParameters['searchCriteria[filter_groups][$filterIndex][filters][0][condition_type]'] = 'lteq';
      filterIndex++;
    }

    try {
      final response = await _dio.get('orders', queryParameters: queryParameters);
      final data = response.data;
      return List<Map<String, dynamic>>.from(data['items'] ?? []);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<List<Map<String, dynamic>>> getProductsAdmin({
    int currentPage = 1,
    int pageSize = 20,
  }) async {
    _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
    try {
      final response = await _dio.get(
        'products',
        queryParameters: {
          'searchCriteria[currentPage]': currentPage,
          'searchCriteria[pageSize]': pageSize,
        },
      );
      final data = response.data;
      return List<Map<String, dynamic>>.from(data['items'] ?? []);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<ReviewPage> getProductReviewsAdmin({
    int page = 1,
    int pageSize = 20,
    int? statusEq,
  }) async {
    try {
      final vendorId = await getVendorId();

      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';

      final Map<String, dynamic> qp = {
        'searchCriteria[currentPage]': page,
        'searchCriteria[pageSize]': pageSize,
        'searchCriteria[filterGroups][0][filters][0][field]': 'vendor_id',
        'searchCriteria[filterGroups][0][filters][0][value]': vendorId,
        'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
      };

      if (statusEq != null) {
        qp['searchCriteria[filterGroups][1][filters][0][field]'] = 'status_id';
        qp['searchCriteria[filterGroups][1][filters][0][value]'] = statusEq;
        qp['searchCriteria[filterGroups][1][filters][0][conditionType]'] = 'eq';
      }

      final res = await _dio.get('reviews', queryParameters: qp);

      final itemsList = (res.data['items'] as List?) ?? const [];
      final total = (res.data['total_count'] is num)
          ? (res.data['total_count'] as num).toInt()
          : itemsList.length;

      final items = itemsList
          .whereType<Map>()
          .map((e) => MagentoReview.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return ReviewPage(totalCount: total, items: items);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<Map<String, dynamic>> getInvoiceById({required int invoiceId}) async {
    _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
    try {
      final response = await _dio.get('invoices/$invoiceId');
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<List<dynamic>> getInvoiceComments({required int invoiceId}) async {
    _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
    try {
      final response = await _dio.get('invoices/$invoiceId/comments');
      return List<dynamic>.from(response.data['items'] ?? []);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<void> addInvoiceComment({
    required int invoiceId,
    required String comment,
    required bool isVisibleOnFront,
  }) async {
    _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
    try {
      await _dio.post(
        'invoices/$invoiceId/comments',
        data: {
          'comment': {
            'comment': comment,
            'is_visible_on_front': isVisibleOnFront,
          },
        },
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
    try {
      final response = await _dio.get('categories');
      final decodedData = response.data;
      final raw = (decodedData['children_data'] ?? decodedData['items'] ?? []) as List;
      return raw.map((e) => Map<String, dynamic>.from(e)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  Future<Map<String, dynamic>> createProductAsAdmin(
      Map<String, dynamic> productData,
      ) async {
    _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
    try {
      final response = await _dio.post(
        'products',
        data: json.encode({'product': productData}),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_token);
    }
  }

  // ==========================
  // 📨 CONTACT (Unauthenticated)
  // ==========================
  Future<void> sendContactMessage({
    required String name,
    required String email,
    required String telephone,
    required String comment,
  }) async {
    try {
      await _dio.post(
        'contact',
        data: jsonEncode({
          'name': name,
          'email': email,
          'telephone': telephone,
          'comment': comment,
        }),
        options: Options(headers: {'Authorization': null}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // ==========================
  // 🔧 HELPER METHODS
  // ==========================
  String guessMimeFromName(String filename) {
    final ext = filename.split('.').last.toLowerCase();
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
      case 'svg':
        return 'image/svg+xml';
      case 'pdf':
        return 'application/pdf';
      case 'json':
        return 'application/json';
      case 'csv':
        return 'text/csv';
      default:
        return 'application/octet-stream';
    }
  }

  String parseMagentoError(Object error) {
    if (error is DioException) return _handleDioError(error);
    if (error is SocketException) return 'Network error: ${error.message}';
    return 'Unexpected error: $error';
  }

  String get _originFromBase {
    final uri = Uri.parse(_dio.options.baseUrl);
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
    ).toString().replaceAll(RegExp(r'/$'), '');
  }

  String get mediaBaseUrlForVendor => '$_originFromBase/media/vendor';
  String get mediaBaseUrlForCatalog => '$_originFromBase/media/catalog/product';

  String productImageUrl(String? filePath, {bool vendor = false}) {
    if (filePath == null || filePath.isEmpty) return '';
    final cleaned = filePath.startsWith('/') ? filePath : '/$filePath';
    final base = vendor ? mediaBaseUrlForVendor : mediaBaseUrlForCatalog;
    return '$base$cleaned';
  }

  Future<bool> testConnection() async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
      final response = await _dio.get('');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    } finally {
      _setAuthHeader(_token);
    }
  }
}
class ReviewPage {
  final int totalCount;
  final List<MagentoReview> items;
  ReviewPage({required this.totalCount, required this.items});
}
// ==========================
// Models
// ==========================
class MagentoOrder {
  final String incrementId;
  final String status;
  final String createdAt;
  final String subtotal;
  final String grandTotal;
  final String customerName;
  final String customerEmail;
  final List<MagentoOrderItem> items;

  MagentoOrder({
    required this.incrementId,
    required this.status,
    required this.createdAt,
    required this.subtotal,
    required this.grandTotal,
    required this.customerName,
    required this.customerEmail,
    required this.items,
  });

  factory MagentoOrder.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List?) ?? [];
    return MagentoOrder(
      incrementId: (json['increment_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      subtotal: (json['subtotal'] ?? '').toString(),
      grandTotal: (json['grand_total'] ?? '').toString(),
      customerName: (json['customer_firstname'] != null && json['customer_lastname'] != null)
          ? '${json['customer_firstname']} ${json['customer_lastname']}'
          : 'Guest',
      customerEmail: (json['customer_email'] ?? '').toString(),
      items: itemsJson.map((e) => MagentoOrderItem.fromJson(e)).toList(),
    );
  }
}

class MagentoOrderItem {
  final String sku;
  final String name;
  final String price;
  MagentoOrderItem({
    required this.sku,
    required this.name,
    required this.price,
  });

  factory MagentoOrderItem.fromJson(Map<String, dynamic> json) {
    return MagentoOrderItem(
      sku: (json['sku'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: (json['price'] ?? '').toString(),
    );
  }
}

class MagentoProduct {
  final String sku;
  final String name;
  final List<dynamic> mediaGalleryEntries;

  MagentoProduct({
    required this.sku,
    required this.name,
    required this.mediaGalleryEntries,
  });

  factory MagentoProduct.fromJson(Map<String, dynamic> json) {
    return MagentoProduct(
      sku: (json['sku'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      mediaGalleryEntries: (json['media_gallery_entries'] as List?)?.toList() ?? const [],
    );
  }
}

/// Minimal product used by getProductLiteBySku
class MagentoProductLite {
  final String sku;
  final String name;
  final List<String> imageFiles;

  MagentoProductLite({
    required this.sku,
    required this.name,
    required this.imageFiles,
  });

  factory MagentoProductLite.fromJson(Map<String, dynamic> json) {
    final entries = (json['media_gallery_entries'] as List?) ?? const [];
    final files = <String>[];
    for (final e in entries) {
      final f = (e is Map && e['file'] != null) ? e['file'].toString() : '';
      if (f.isNotEmpty) files.add(f);
    }
    return MagentoProductLite(
      sku: (json['sku'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      imageFiles: files,
    );
  }
}

class MagentoReview {
  final int id;
  final String? nickname;
  final String? title;
  final String? detail;
  final int? status;
  final String? productSku;
  final List<dynamic>? ratings;

  MagentoReview({
    required this.id,
    this.nickname,
    this.title,
    this.detail,
    this.status,
    this.productSku,
    this.ratings,
  });

  factory MagentoReview.fromJson(Map<String, dynamic> j) {
    int _int(dynamic v) =>
        (v is int) ? v : (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

    String? _sku() {
      final ext = j['extension_attributes'];
      if (ext is Map && ext['sku'] is String) return ext['sku'] as String;
      if (j['product_sku'] is String) return j['product_sku'] as String;
      return null;
    }

    List<dynamic>? _ratings() {
      if (j['rating_votes'] is List) return j['rating_votes'] as List;
      if (j['ratings'] is List) return j['ratings'] as List;
      return null;
    }

    return MagentoReview(
      id: _int(j['id']),
      nickname: (j['nickname'] ?? j['customer_nickname'])?.toString(),
      title: (j['title'] ?? '').toString(),
      detail: (j['detail'] ?? '').toString(),
      status: (j['status_id'] is num) ? (j['status_id'] as num).toInt() : null,
      productSku: _sku(),
      ratings: _ratings(),
    );
  }
}


/// Typed vendor profile so you can do vp.customerId, vp.companyName, etc.
class VendorProfile {
  final int? customerId;
  final String? firstname;
  final String? lastname;
  final String? companyName;
  final String? bio;
  final String? country;
  final String? phone;
  final String? lowStockQty;
  final String? vatNumber;
  final String? paymentDetails;

  // socials
  final String? twitter, facebook, instagram, youtube, vimeo, pinterest, moleskine, tiktok;

  // policies
  final String? returnPolicy, shippingPolicy, privacyPolicy;

  // meta
  final String? metaKeywords, metaDescription, googleAnalyticsId;

  // paths
  final String? profilePathReq, collectionPathReq, reviewPathReq, locationPathReq, privacyPathReq;

  // media
  final String? logoUrl, bannerUrl, logoBase64, bannerBase64;

  VendorProfile({
    this.customerId,
    this.firstname,
    this.lastname,
    this.companyName,
    this.bio,
    this.country,
    this.phone,
    this.lowStockQty,
    this.vatNumber,
    this.paymentDetails,
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
    this.logoUrl,
    this.bannerUrl,
    this.logoBase64,
    this.bannerBase64,
  });

  factory VendorProfile.fromJson(Map<String, dynamic> j) {
    T? _s<T>(String a, [String? b]) {
      final v = j[a] ?? (b != null ? j[b] : null);
      if (v == null) return null;
      if (T == int) return (v is int ? v : int.tryParse('$v')) as T?;
      return v.toString() as T?;
    }

    return VendorProfile(
      customerId: _s<int>('customerId', 'customer_id'),
      firstname: _s<String>('firstname'),
      lastname: _s<String>('lastname'),
      companyName: _s<String>('companyName', 'company_name'),
      bio: _s<String>('bio'),
      country: _s<String>('country'),
      phone: _s<String>('phone', 'telephone'),
      lowStockQty: _s<String>('lowStockQty', 'low_stock_qty'),
      vatNumber: _s<String>('vatNumber', 'vat_number'),
      paymentDetails: _s<String>('paymentDetails', 'payment_details'),
      twitter: _s<String>('twitter'),
      facebook: _s<String>('facebook'),
      instagram: _s<String>('instagram'),
      youtube: _s<String>('youtube'),
      vimeo: _s<String>('vimeo'),
      pinterest: _s<String>('pinterest'),
      moleskine: _s<String>('moleskine'),
      tiktok: _s<String>('tiktok'),
      returnPolicy: _s<String>('returnPolicy', 'return_policy'),
      shippingPolicy: _s<String>('shippingPolicy', 'shipping_policy'),
      privacyPolicy: _s<String>('privacyPolicy', 'privacy_policy'),
      metaKeywords: _s<String>('metaKeywords', 'meta_keywords'),
      metaDescription: _s<String>('metaDescription', 'meta_description'),
      googleAnalyticsId: _s<String>('googleAnalyticsId', 'google_analytics_id'),
      profilePathReq: _s<String>('profilePathReq', 'profile_path_req'),
      collectionPathReq: _s<String>('collectionPathReq', 'collection_path_req'),
      reviewPathReq: _s<String>('reviewPathReq', 'review_path_req'),
      locationPathReq: _s<String>('locationPathReq', 'location_path_req'),
      privacyPathReq: _s<String>('privacyPathReq', 'privacy_path_req'),
      logoUrl: _s<String>('logoUrl', 'logo_url'),
      bannerUrl: _s<String>('bannerUrl', 'banner_url'),
      logoBase64: _s<String>('logoBase64', 'logo_base64'),
      bannerBase64: _s<String>('bannerBase64', 'banner_base64'),
    );
  }

}