import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class VendorGraphQLManager with ChangeNotifier {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://kolshy.ae/rest/V1/",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );

  String? _vendorToken;
  String? _adminToken = "87igct1wbbphdok6dk1roju4i83kyub9";
  GraphQLClient? _graphQLClient;

  String? get vendorToken => _vendorToken;
  bool get hasToken => _vendorToken != null && _vendorToken!.isNotEmpty;

  Future<void> initVendorSession() async {
    final prefs = await SharedPreferences.getInstance();
    _vendorToken = prefs.getString("vendor_token");

    if (_vendorToken != null) {
      _setupGraphQLClient();

      try {
        final profile = await getVendorProfile();
      } catch (e) {
        if (kDebugMode) {
          print('Failed to get vendor ID: $e');
        }
      }
    }
  }

  void _setupGraphQLClient() {
    final HttpLink httpLink = HttpLink("https://kolshy.ae/graphql");
    final AuthLink authLink = AuthLink(getToken: () => "Bearer $_vendorToken");
    final Link link = authLink.concat(httpLink);

    _graphQLClient = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vendor_token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vendor_token');
  }

  Future<String> loginVendor(String email, String password) async {
    try {
      final response = await _dio.post(
        'integration/customer/token',
        data: {"username": email, "password": password},
      );

      final token = response.data.toString();
      if (token.isNotEmpty) {
        await saveToken(token);
        _vendorToken = token;
        _setupGraphQLClient();
        notifyListeners();
        return token;
      }
      throw Exception('Login failed: Invalid token received.');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> logout() async {
    await removeToken();
    _vendorToken = null;
    _graphQLClient = null;
    notifyListeners();
  }

  Future<VendorProfile> getVendorProfile() async {
    if (_graphQLClient == null) {
      throw Exception("Vendor not authenticated");
    }

    const String query = r'''
      query {
        customer {
          id
          firstname
          lastname
          email
          telephone
          custom_attributes {
            attribute_code
            value
          }
        }
      }
    ''';

    try {
      final result = await _graphQLClient!.query(
          QueryOptions(document: gql(query))
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      final customerData = result.data?['customer'] ?? {};
      return VendorProfile.fromJson(Map<String, dynamic>.from(customerData));
    } catch (e) {
      if (kDebugMode) print("Error fetching vendor profile: $e");
      rethrow;
    }
  }

  Future<List<dynamic>> getVendorProducts({
    int pageSize = 20,
    int currentPage = 1,
  }) async {
    if (_graphQLClient == null) {
      throw Exception("Vendor not authenticated");
    }

    const String query = r'''
      query VendorProducts($pageSize: Int, $currentPage: Int) {
        vendorProducts(pageSize: $pageSize, currentPage: $currentPage) {
          items {
            id
            sku
            name
            price
            status
            type_id
            created_at
            media_gallery_entries {
              file
            }
            extension_attributes {
              stock_item {
                qty
              }
            }
          }
          total_count
        }
      }
    ''';

    try {
      final result = await _graphQLClient!.query(
          QueryOptions(
            document: gql(query),
            variables: {
              'pageSize': pageSize,
              'currentPage': currentPage,
            },
          )
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['vendorProducts']?['items'] ?? [];
    } catch (e) {
      if (kDebugMode) print("Error fetching vendor products: $e");
      rethrow;
    }
  }

  Future<List<dynamic>> getDraftProducts({
    int pageSize = 20,
    int currentPage = 1,
  }) async {
    if (_graphQLClient == null) {
      throw Exception("Vendor not authenticated");
    }

    const String query = r'''
      query VendorDraftProducts($pageSize: Int, $currentPage: Int) {
        vendorProducts(
          pageSize: $pageSize, 
          currentPage: $currentPage,
          filters: {status: {eq: 2}}
        ) {
          items {
            id
            sku
            name
            price
            status
            type_id
            created_at
            media_gallery_entries {
              file
            }
            extension_attributes {
              stock_item {
                qty
              }
            }
          }
          total_count
        }
      }
    ''';

    try {
      final result = await _graphQLClient!.query(
          QueryOptions(
            document: gql(query),
            variables: {
              'pageSize': pageSize,
              'currentPage': currentPage,
            },
          )
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['vendorProducts']?['items'] ?? [];
    } catch (e) {
      if (kDebugMode) print("Error fetching draft products: $e");
      rethrow;
    }
  }

  Future<List<dynamic>> getVendorOrders({
    int pageSize = 20,
    int currentPage = 1,
  }) async {
    if (_graphQLClient == null) {
      throw Exception("Vendor not authenticated");
    }

    const String query = r'''
      query VendorOrders($pageSize: Int, $currentPage: Int) {
        vendorOrders(pageSize: $pageSize, currentPage: $currentPage) {
          items {
            increment_id
            status
            created_at
            grand_total
            customer_firstname
            customer_lastname
            customer_email
            items {
              sku
              name
              price
              qty_ordered
            }
          }
          total_count
        }
      }
    ''';

    try {
      final result = await _graphQLClient!.query(
          QueryOptions(
            document: gql(query),
            variables: {
              'pageSize': pageSize,
              'currentPage': currentPage,
            },
          )
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['vendorOrders']?['items'] ?? [];
    } catch (e) {
      if (kDebugMode) print("Error fetching vendor orders: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    if (_graphQLClient == null) {
      throw Exception("Vendor not authenticated");
    }

    const String query = r'''
      query VendorDashboardStats {
        vendorDashboard {
          total_orders
          total_revenue
          total_products
          pending_orders
        }
      }
    ''';

    try {
      final result = await _graphQLClient!.query(
          QueryOptions(document: gql(query))
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['vendorDashboard'] ?? {
        'total_orders': 0,
        'total_revenue': 0,
        'total_products': 0,
        'pending_orders': 0,
      };
    } catch (e) {
      if (kDebugMode) print("Error fetching dashboard stats: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCustomerAnalytics({
    String period = 'all_time',
  }) async {
    if (_graphQLClient == null) {
      throw Exception("Vendor not authenticated");
    }

    const String query = r'''
      query VendorCustomerAnalytics($period: String!) {
        vendorCustomerAnalytics(period: $period) {
          total_customers
          total_revenue
          currency
          customers {
            email
            name
            total_orders
            total_spent
            last_order_date
          }
        }
      }
    ''';

    try {
      final result = await _graphQLClient!.query(
          QueryOptions(
            document: gql(query),
            variables: {'period': period},
          )
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data?['vendorCustomerAnalytics'] ?? {
        'total_customers': 0,
        'total_revenue': 0,
        'currency': '',
        'customers': [],
      };
    } catch (e) {
      if (kDebugMode) print("Error fetching customer analytics: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _adminRequest(String endpoint, dynamic data) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _dio.options.headers['Authorization'] = 'Bearer $_vendorToken';
    }
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> productData) async {
    return await _adminRequest(
      'products',
      json.encode({'product': productData}),
    );
  }

  Future<Map<String, dynamic>> updateProduct(String sku, Map<String, dynamic> productData) async {
    return await _adminRequest(
      'products/$sku',
      json.encode({'product': productData}),
    );
  }

  Future<void> deleteProduct(String sku) async {
    await _adminRequest('products/$sku', null);
  }

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
}