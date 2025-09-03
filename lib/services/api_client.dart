import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/auth/login/welcome_screen.dart';



final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// A singleton class to handle all API calls and token management.
class ApiClient {
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
          final isAuthEndpoint = path.contains("integration/customer/token") ||
              (path.contains("customers") && options.method.toUpperCase() == "POST");

          if (!isAuthEndpoint) {
            final token = await _readCustomerToken();
            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await _clearCustomerToken();
            _navigateToLogin();
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
          "Authorization": null,
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
    String? phone,
  }) async {
    try {
      final customerData = {
        "customer": {
          "email": email,
          "firstname": firstname,
          "lastname": lastname,
          "custom_attributes": [
            {"attribute_code": "is_vendor", "value": "1"},
            {"attribute_code": "vendor_status", "value": "1"},
            if (phone != null) {"attribute_code": "phone", "value": phone}
          ]
        },
        "password": password,
      };

      final response = await _dio.post(
        "customers",
        data: customerData,
        options: Options(headers: {"Authorization": null}),
      );

      final customerResponse = Map<String, dynamic>.from(response.data ?? {});
      print('Customer created with vendor attributes: $customerResponse');

      return customerResponse;
    } on DioException catch (e) {
      throw Exception(parseMagentoError(e));
    }
  }

  Future<Map<String, dynamic>> createVendorAccount({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String phone,
    required String businessName,
  }) async {
    try {
      final response = await _dio.post(
        "customers",
        data: {
          "customer": {
            "email": email,
            "firstname": firstname,
            "lastname": lastname,
            "custom_attributes": [
              {"attribute_code": "is_vendor", "value": "1"},
              {"attribute_code": "vendor_status", "value": "1"},
              {"attribute_code": "phone", "value": phone},
              {"attribute_code": "business_name", "value": businessName}
            ]
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

  Future<bool> isUserVendor() async {
    try {
      final customerInfo = await getCustomerInfo();
      // Check for the 'is_vendor' custom attribute
      final customAttributes = customerInfo?['custom_attributes'] as List<dynamic>?;
      return customAttributes?.any((attr) => attr['attribute_code'] == 'is_vendor' && attr['value'] == '1') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _setVendorAttributes(String email, String phone, String businessName) async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo == null) throw Exception('Customer not found');

      final customerId = customerInfo['id'];
      if (customerId == null) throw Exception('Customer ID not found');

      await _dio.put(
        "customers/$customerId",
        data: {
          "customer": {
            "email": email,
            "custom_attributes": [
              {"attribute_code": "is_vendor", "value": "1"},
              {"attribute_code": "vendor_status", "value": "1"},
              {"attribute_code": "vendor_phone", "value": phone},
              {"attribute_code": "business_name", "value": businessName},
              {"attribute_code": "vendor_id", "value": customerId.toString()}
            ]
          }
        },
      );

      print('Vendor attributes set successfully');
    } catch (e) {
      print('Setting vendor attributes failed: $e');
      throw Exception('Failed to set vendor attributes: $e');
    }
  }

  Options unauthenticated() => Options(headers: {"Authorization": null});

  Options withBearer(String token) => Options(headers: {"Authorization": "Bearer $token"});

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
      await clearAuthToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      final secureStorage = const FlutterSecureStorage();
      await secureStorage.deleteAll();

      print('Logout successful - storage cleared');
    } catch (e) {
      print('Logout error: $e');
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

  void _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (route) => false,
        );
      }
    });
  }

  /// Fetches a list of all products from the Magento API.
  ///
  /// This method sends a GET request to the 'products' endpoint and
  /// retrieves the product data, handling potential network errors.
  Future<List<dynamic>> getProducts() async {
    try {
      final response = await _dio.get('products', queryParameters: {
        'searchCriteria[pageSize]': 1000,
      });

      // Magento returns products in an 'items' array
      final products = response.data['items'] ?? [];
      return products;
    } on DioException catch (e) {
      throw Exception('Failed to load products: ${parseMagentoError(e)}');
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final customerInfo = await getCustomerInfo();
      if (customerInfo == null) {
        throw Exception("Customer information not available");
      }

      final isVendor = await isUserVendor();
      if (!isVendor) {
        throw Exception("User is not a vendor");
      }
      final ordersResponse = await _dio.get("orders", queryParameters: {
        'searchCriteria[pageSize]': 1000,
      });

      final productsResponse = await _dio.get("products", queryParameters: {
        'searchCriteria[pageSize]': 1000,
      });

      final customersResponse = await _dio.get("customers/search", queryParameters: {
        'searchCriteria[pageSize]': 1000,
      });

      final orders = ordersResponse.data['items'] ?? [];
      final products = productsResponse.data['items'] ?? [];
      final customers = customersResponse.data['items'] ?? [];

      double totalRevenue = 0;
      for (var order in orders) {
        totalRevenue += (order['grand_total'] as num?)?.toDouble() ?? 0;
      }

      return {
        'total_revenue': totalRevenue,
        'total_orders': orders.length,
        'total_products': products.length,
        'total_customers': customers.length,
        'vendor_id': customerInfo['id'] ?? 'N/A'
      };
    } on DioException catch (e) {
      throw Exception(parseMagentoError(e));
    }
  }


  Future<Map<String, double>> getSalesHistory() async {
    try {
      final response = await _dio.get("orders", queryParameters: {
        'searchCriteria[pageSize]': 1000,
      });

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
      final response = await _dio.get("customers/search", queryParameters: {
        'searchCriteria[pageSize]': 1000,
      });

      final List<dynamic> customers = response.data['items'] ?? [];

      int newCustomers = 0;
      int returningCustomers = 0;
      int oldCustomers = 0;

      for (var customer in customers) {
        final createdAt = customer['created_at'] as String?;
        if (createdAt != null) {
          final createdDate = DateTime.parse(createdAt);
          final daysSinceCreation = DateTime.now().difference(createdDate).inDays;

          if (daysSinceCreation < 30) {
            newCustomers++;
          } else if (daysSinceCreation < 90) {
            returningCustomers++;
          } else {
            oldCustomers++;
          }
        }
      }

      return {
        'new': newCustomers,
        'returning': returningCustomers,
        'old': oldCustomers,
        'total': customers.length,
      };
    } on DioException catch (e) {
      throw Exception(parseMagentoError(e));
    }
  }

  Future<List<dynamic>> getTopSellingProducts() async {
    try {
      final response = await _dio.get("products", queryParameters: {
        "searchCriteria[sortOrders][0][field]": "created_at",
        "searchCriteria[sortOrders][0][direction]": "DESC",
        "searchCriteria[pageSize]": 10,
      });
      return response.data['items'] ?? [];
    } on DioException catch (e) {
      throw Exception(parseMagentoError(e));
    }
  }

  Future<List<dynamic>> getTopCategories() async {
    try {
      final response = await _dio.get("categories/list", queryParameters: {
        "searchCriteria[pageSize]": 10,
      });
      return response.data['items'] ?? [];
    } on DioException catch (e) {
      throw Exception(parseMagentoError(e));
    }
  }

  Future<List<dynamic>> getLatestReviews() async {
    try {
      final response = await _dio.get("reviews/search", queryParameters: {
        "searchCriteria[sortOrders][0][field]": "created_at",
        "searchCriteria[sortOrders][0][direction]": "DESC",
        "searchCriteria[pageSize]": 10,
      });
      return response.data['items'] ?? [];
    } on DioException catch (e) {
      throw Exception(parseMagentoError(e));
    }
  }

  Future<Map<String, Map<int, double>>> getProductRatings() async {
    try {
      final response = await _dio.get("reviews/search", queryParameters: {
        "searchCriteria[pageSize]": 1000,
      });

      final List<dynamic> reviews = response.data['items'] ?? [];
      final Map<int, double> price = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      final Map<int, double> value = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
      final Map<int, double> quality = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

      for (var review in reviews) {
        final rating = (review['rating_summary'] as num?)?.toInt() ?? 0;
        final starRating = (rating ~/ 20).clamp(1, 5);

        price[starRating] = (price[starRating] ?? 0) + 1;
        value[starRating] = (value[starRating] ?? 0) + 1;
        quality[starRating] = (quality[starRating] ?? 0) + 1;
      }

      final totalReviews = reviews.length;
      if (totalReviews > 0) {
        final normalize = (Map<int, double> map) => map.map((key, value) =>
            MapEntry(key, (value / totalReviews) * 100));

        return {
          'price': normalize(price),
          'value': normalize(value),
          'quality': normalize(quality),
        };
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

  // New and corrected method to fetch draft products.
  Future<List<Map<String, dynamic>>> getDraftProducts() async {
    try {
      if (!await isUserVendor()) {
        throw Exception("User is not a vendor");
      }

      final response = await _dio.get("products", queryParameters: {
        "searchCriteria[filter_groups][0][filters][0][field]": "status",
        "searchCriteria[filter_groups][0][filters][0][value]": "2", // Draft status
        "searchCriteria[filter_groups][0][filters][0][condition_type]": "eq",
        "searchCriteria[pageSize]": 100,
      });

      final products = List<Map<String, dynamic>>.from(response.data['items'] ?? []);
      return products;
    } on DioException catch (e) {
      throw Exception("Failed to load drafts: ${e.message}");
    }
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData) async {
    try {
      if (!await isUserVendor()) {
        throw Exception("User is not a vendor");
      }

      final response = await _dio.post(
        "products",
        data: productData,
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception("Failed to create product: ${e.message}");
    }
  }

  Future<Map<String, dynamic>> updateProduct(String sku, Map<String, dynamic> productData) async {
    try {
      if (!await isUserVendor()) {
        throw Exception("User is not a vendor");
      }

      final response = await _dio.put(
        "products/$sku",
        data: productData,
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception("Failed to update product: ${e.message}");
    }
  }

  Future<bool> deleteProduct(String sku) async {
    try {
      if (!await isUserVendor()) {
        throw Exception("User is not a vendor");
      }

      await _dio.delete("products/$sku");
      return true;
    } on DioException catch (e) {
      throw Exception("Failed to delete product: ${e.message}");
    }
  }
}
