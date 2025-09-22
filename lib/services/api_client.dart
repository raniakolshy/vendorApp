

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kolshy_vendor/data/models/vendor_profile_model.dart';
import 'package:kolshy_vendor/data/models/product_model.dart';



class ReviewPage {
  final int totalCount;
  final List<dynamic> items;
  ReviewPage({required this.totalCount, required this.items});
}
class MagentoOrder {
  final String incrementId;
  final String status;
  final String createdAt;
  final String subtotal;
  final String grandTotal;
  final String customerName;
  final String customerEmail;
  final List<MagentoOrderItem> items;
  MagentoOrder({required this.incrementId, required this.status, required this.createdAt, required this.subtotal, required this.grandTotal, required this.customerName, required this.customerEmail, required this.items});
  factory MagentoOrder.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List?) ?? [];
    return MagentoOrder(incrementId: (json['increment_id'] ?? '').toString(), status: (json['status'] ?? '').toString(), createdAt: (json['created_at'] ?? '').toString(), subtotal: (json['subtotal'] ?? '').toString(), grandTotal: (json['grand_total'] ?? '').toString(), customerName: (json['customer_firstname'] != null && json['customer_lastname'] != null) ? '${json['customer_firstname']} ${json['customer_lastname']}' : 'Guest', customerEmail: (json['customer_email'] ?? '').toString(), items: itemsJson.map((e) => MagentoOrderItem.fromJson(e)).toList());
  }
}
class MagentoOrderItem {
  final int? itemId;
  final int? orderId;
  final String? sku;
  final String? name;
  final double? price;
  final int? qtyOrdered;
  final String? typeId;
  final String? image;
  final List<dynamic>? mediaGalleryEntries;
  MagentoOrderItem({this.itemId, this.orderId, this.sku, this.name, this.price, this.qtyOrdered, this.typeId, this.image, this.mediaGalleryEntries});
  factory MagentoOrderItem.fromJson(Map<String, dynamic> json) {
    return MagentoOrderItem(itemId: json['item_id'], orderId: json['order_id'], sku: json['sku'], name: json['name'], price: json['price'] != null ? double.tryParse(json['price'].toString()) : null, qtyOrdered: (json['qty_ordered'] is num) ? (json['qty_ordered'] as num).toInt() : null, typeId: json['product_type']?.toString(), image: json['image']?.toString(), mediaGalleryEntries: (json['media_gallery_entries'] as List<dynamic>?)?.toList());
  }
}
class MagentoProduct {
  final String sku;
  final String name;
  final List<dynamic> mediaGalleryEntries;
  MagentoProduct({required this.sku, required this.name, required this.mediaGalleryEntries});
  factory MagentoProduct.fromJson(Map<String, dynamic> json) {
    return MagentoProduct(sku: (json['sku'] ?? '').toString(), name: (json['name'] ?? '').toString(), mediaGalleryEntries: (json['media_gallery_entries'] as List?)?.toList() ?? const []);
  }
}
class MagentoProductLite {
  final String sku;
  final String name;
  final List<String> imageFiles;
  MagentoProductLite({required this.sku, required this.name, required this.imageFiles});
  factory MagentoProductLite.fromJson(Map<String, dynamic> json) {
    final entries = (json['media_gallery_entries'] as List?) ?? const [];
    final files = <String>[];
    for (final e in entries) {
      final f = (e is Map && e['file'] != null) ? e['file'].toString() : '';
      if (f.isNotEmpty) files.add(f);
    }
    return MagentoProductLite(sku: (json['sku'] ?? '').toString(), name: (json['name'] ?? '').toString(), imageFiles: files);
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
  MagentoReview({required this.id, this.nickname, this.title, this.detail, this.status, this.productSku, this.ratings});
  factory MagentoReview.fromJson(Map<String, dynamic> j) {
    int _int(dynamic v) => (v is int) ? v : (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;
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
    return MagentoReview(id: _int(j['id']), nickname: (j['nickname'] ?? j['customer_nickname'])?.toString(), title: (j['title'] ?? '').toString(), detail: (j['detail'] ?? '').toString(), status: (j['status_id'] is num) ? (j['status_id'] as num).toInt() : null, productSku: _sku(), ratings: _ratings());
  }
}
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
  final String? twitter, facebook, instagram, youtube, vimeo, pinterest, moleskine, tiktok;
  final String? returnPolicy, shippingPolicy, privacyPolicy;
  final String? metaKeywords, metaDescription, googleAnalyticsId;
  final String? profilePathReq, collectionPathReq, reviewPathReq, locationPathReq, privacyPathReq;
  final String? logoUrl, bannerUrl, logoBase64, bannerBase64;
  VendorProfile({this.customerId, this.firstname, this.lastname, this.companyName, this.bio, this.country, this.phone, this.lowStockQty, this.vatNumber, this.paymentDetails, this.twitter, this.facebook, this.instagram, this.youtube, this.vimeo, this.pinterest, this.moleskine, this.tiktok, this.returnPolicy, this.shippingPolicy, this.privacyPolicy, this.metaKeywords, this.metaDescription, this.googleAnalyticsId, this.profilePathReq, this.collectionPathReq, this.reviewPathReq, this.locationPathReq, this.privacyPathReq, this.logoUrl, this.bannerUrl, this.logoBase64, this.bannerBase64,});
  factory VendorProfile.fromJson(Map<String, dynamic> j) {
    T? _s<T>(String a, [String? b]) {
      final v = j[a] ?? (b != null ? j[b] : null);
      if (v == null) return null;
      if (T == int) return (v is int ? v : int.tryParse('$v')) as T?;
      return v.toString() as T?;
    }
    return VendorProfile(customerId: _s<int>('customerId', 'customer_id'), firstname: _s<String>('firstname'), lastname: _s<String>('lastname'), companyName: _s<String>('companyName', 'company_name'), bio: _s<String>('bio'), country: _s<String>('country'), phone: _s<String>('phone', 'telephone'), lowStockQty: _s<String>('lowStockQty', 'low_stock_qty'), vatNumber: _s<String>('vatNumber', 'vat_number'), paymentDetails: _s<String>('paymentDetails', 'payment_details'), twitter: _s<String>('twitter'), facebook: _s<String>('facebook'), instagram: _s<String>('instagram'), youtube: _s<String>('youtube'), vimeo: _s<String>('vimeo'), pinterest: _s<String>('pinterest'), moleskine: _s<String>('moleskine'), tiktok: _s<String>('tiktok'), returnPolicy: _s<String>('returnPolicy', 'return_policy'), shippingPolicy: _s<String>('shippingPolicy', 'shipping_policy'), privacyPolicy: _s<String>('privacyPolicy', 'privacy_policy'), metaKeywords: _s<String>('metaKeywords', 'meta_keywords'), metaDescription: _s<String>('metaDescription', 'meta_description'), googleAnalyticsId: _s<String>('googleAnalyticsId', 'google_analytics_id'), profilePathReq: _s<String>('profilePathReq', 'profile_path_req'), collectionPathReq: _s<String>('collectionPathReq', 'collection_path_req'), reviewPathReq: _s<String>('reviewPathReq', 'review_path_req'), locationPathReq: _s<String>('locationPathReq', 'location_path_req'), privacyPathReq: _s<String>('privacyPathReq', 'privacy_path_req'), logoUrl: _s<String>('logoUrl', 'logo_url'), bannerUrl: _s<String>('bannerUrl', 'banner_url'), logoBase64: _s<String>('logoBase64', 'logo_base64'), bannerBase64: _s<String>('bannerBase64', 'banner_base64'),);
  }
}

class VendorApiClient {

  static final VendorApiClient _instance = VendorApiClient._internal();
  factory VendorApiClient() => _instance;
  VendorApiClient._internal();


  final _secureStorage = const FlutterSecureStorage();
  late final Dio _dio;
  late final Dio _adminDio;

  String? _adminToken;
  String? _vendorToken;
  VendorProfileModel? _vendorProfile;

  String? get adminToken => _adminToken;
  String? get vendorToken => _vendorToken;
  VendorProfileModel? get vendorProfile => _vendorProfile;
  bool get hasToken => _vendorToken != null && _vendorToken!.isNotEmpty;
  int? get vendorId => _vendorProfile?.customerId;

  static const String _tokenKey = 'vendor_auth_token';
  static const String _adminTokenKey = 'admin_auth_token';


  Future<void> init() async {
    if (this.vendorProfile != null) {
      return;
    }


    const base = 'http://91.99.125.241/rest/V1/';
    _dio = Dio(BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
    ));
    _adminDio = Dio(BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
    ));
    await _loadTokens();
  }

  Future<void> _loadTokens() async {
    _adminToken = '87igct1wbbphdok6dk1roju4i83kyub9';
    _setAdminAuthHeader(_adminToken);
  }


  void _setAuthHeader(String? token) {
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }
  void _setAdminAuthHeader(String? token) {
    if (token != null && token.isNotEmpty) {
      _adminDio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _adminDio.options.headers.remove('Authorization');
    }
  }

  Future<ReviewPage> getProductReviewsAdmin({
    int currentPage = 1,
    int pageSize = 20,
    int? statusEq,
  }) async {
    try {
      if (_adminToken == null || _adminToken!.isEmpty) {
        throw Exception('Admin token not available.');
      }
      _setAdminAuthHeader(_adminToken);
      final query = <String, dynamic>{
        'searchCriteria[currentPage]': currentPage,
        'searchCriteria[pageSize]': pageSize,
      };
      if (statusEq != null) {
        query['searchCriteria[filterGroups][0][filters][0][field]'] = 'status_id';
        query['searchCriteria[filterGroups][0][filters][0][value]'] = statusEq;
        query['searchCriteria[filterGroups][0][filters][0][conditionType]'] = 'eq';
      }
      final response = await _adminDio.get('reviews', queryParameters: query);
      final data = (response.data is Map) ? (response.data as Map).cast<String, dynamic>() : <String, dynamic>{};
      final totalCount = (data['total_count'] as num?)?.toInt() ?? 0;
      final rawItems = (data['items'] as List?) ?? const <dynamic>[];
      final items = <dynamic>[
        for (final it in rawItems)
          if (it is Map<String, dynamic>) it,
      ];
      return ReviewPage(totalCount: totalCount, items: items);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }


  Future<void> loginVendor(String username, String password) async {
    try {
      print('Attempting to login with username: $username');
      final res = await _dio.post(
        'integration/customer/token',
        data: {'username': username, 'password': password},
      );

      print('Login successful. Server response:');
      print('Status Code: ${res.statusCode}');
      print('Response Data: ${res.data}');

      final data = res.data;
      if (data is String) {
        _vendorToken = data;
      } else if (data is Map && data['token'] is String) {
        _vendorToken = data['token'] as String;
      }

      if (_vendorToken == null || _vendorToken!.isEmpty) {
        throw Exception('Login failed: empty token');
      }

      await _secureStorage.write(key: _tokenKey, value: _vendorToken!);
      _setAuthHeader(_vendorToken);
      await getVendorProfile();
    } on DioException catch (e) {
      print('Login failed. Server response:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      throw Exception(_handleDioError(e));
    }
  }
// ...
  Future<void> login(String username, String password) => loginVendor(username, password);
  Future<void> loginAdmin(String username, String password) async {
    try {
      if (_adminDio == null) await init();
      final res = await _adminDio.post(
        'integration/admin/token',
        data: {'username': username, 'password': password},
      );
      final data = res.data;
      if (data is String) {
        _adminToken = data;
      } else if (data is Map && data['token'] is String) {
        _adminToken = data['token'] as String;
      }
      if (_adminToken == null || _adminToken!.isEmpty) {
        throw Exception('Admin login failed: empty token');
      }
      await _secureStorage.write(key: _adminTokenKey, value: _adminToken!);
      _setAdminAuthHeader(_adminToken);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<void> registerVendor(Map<String, dynamic> vendorData) async {
    try {
      _dio.options.headers.remove('Authorization');
      await _dio.post('vendors', data: vendorData);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<void> forgotPassword(String email) async {
    try {
      _dio.options.headers.remove('Authorization');
      await _dio.put('customers/password', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<void> logout() async {
    await _secureStorage.deleteAll();
    _vendorToken = null;
    _adminToken = null;
    _vendorProfile = null;
    _setAuthHeader(null);
    _setAdminAuthHeader(null);
  }
  Future<void> removeToken() async {
    await _secureStorage.delete(key: _tokenKey);
    _vendorToken = null;
    _vendorProfile = null;
    _setAuthHeader(null);
  }
  Future<List<dynamic>> getVendorNotifications() async {
    try {
      final response = await _dio.get(
        'vendor/notifications',
        options: Options(headers: {"Authorization": "Bearer $_adminToken"}),
      );
      return response.data['items'] ?? [];
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<List<dynamic>> getAdminNews() async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $_adminToken';
      final response = await _dio.get(
        'notifications',
        queryParameters: {
          'searchCriteria[pageSize]': 20,
          'searchCriteria[sortOrders][0][field]': 'created_at',
          'searchCriteria[sortOrders][0][direction]': 'DESC',
        },
      );
      return response.data['items'] ?? [];
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    } finally {
      _setAuthHeader(_adminToken);
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _dio.post(
        'vendor/notifications/$notificationId/read',
        options: Options(headers: {"Authorization": "Bearer $_adminToken"}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _dio.post(
        'vendor/notifications/read-all',
        options: Options(headers: {"Authorization": "Bearer $_adminToken"}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _dio.delete(
        'vendor/notifications/$notificationId',
        options: Options(headers: {"Authorization": "Bearer $_adminToken"}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await _dio.delete(
        'vendor/notifications',
        options: Options(headers: {"Authorization": "Bearer $_adminToken"}),
      );
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }


  Future<VendorProfileModel> getVendorProfile() async {
    try {
      if (_dio == null) await init();
      _setAuthHeader(_vendorToken);

      print('Attempting to get vendor profile...');


      final res = await _dio.get('customers/me');

      print('Successfully got vendor profile.');
      print('Status Code: ${res.statusCode}');
      print('Response Data: ${res.data}');

      final model = VendorProfileModel.fromJson(res.data);
      _vendorProfile = model;
      return model;
    } on DioException catch (e) {
      print('Failed to get vendor profile. Server response:');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      throw Exception('Failed to get vendor profile: ${_handleDioError(e)}');
    }
  }

  Future<void> updateVendorProfile(Map<String, dynamic> payload) async {
    try {
      if (_dio == null) await init();
      _setAuthHeader(_vendorToken);
      await _dio.put('vendors/me', data: payload);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<VendorProfileModel> getVendorInfo() async {
    return await getVendorProfile();
  }

  Future<List<ProductModel>> getVendorProducts({
    required int vendorId,
    int pageSize = 20,
    int currentPage = 1,
    String? productStatus,
  }) async {
    try {
      if (_dio == null) await init();
      _setAuthHeader(_vendorToken);
      final qp = <String, dynamic>{
        'searchCriteria[filterGroups][0][filters][0][field]': 'vendor_id',
        'searchCriteria[filterGroups][0][filters][0][value]': vendorId,
        'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
        'searchCriteria[pageSize]': pageSize,
        'searchCriteria[currentPage]': currentPage,
      };
      if (productStatus != null) {
        qp['searchCriteria[filterGroups][1][filters][0][field]'] = 'status';
        qp['searchCriteria[filterGroups][1][filters][0][value]'] = productStatus;
        qp['searchCriteria[filterGroups][1][filters][0][conditionType]'] = 'eq';
      }
      final res = await _dio.get('products', queryParameters: qp);
      final items = (res.data['items'] as List?) ?? const [];
      return items.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<List<MagentoProduct>> getProductsAdmin({
    int? pageSize,
    String? search,
  }) async {
    try {
      if (_adminToken == null) throw Exception('Admin token not available.');
      if (_adminDio == null) await init();
      _setAdminAuthHeader(_adminToken);
      final qp = <String, dynamic>{};
      if (pageSize != null) qp['searchCriteria[pageSize]'] = pageSize;
      if (search != null && search.isNotEmpty) {
        qp['searchCriteria[filterGroups][0][filters][0][field]'] = 'name';
        qp['searchCriteria[filterGroups][0][filters][0][value]'] = '%$search%';
        qp['searchCriteria[filterGroups][0][filters][0][conditionType]'] = 'like';
      }
      final res = await _adminDio.get('products', queryParameters: qp);
      final items = (res.data['items'] as List?) ?? const [];
      return items.map((e) => MagentoProduct.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<Map<String, dynamic>> getProductDetailsBySku({required String sku}) async {
    try {
      if (_adminToken == null) throw Exception('Admin token not available.');
      if (_adminDio == null) await init();
      _setAdminAuthHeader(_adminToken);
      final res = await _adminDio.get('products/$sku');
      return Map<String, dynamic>.from(res.data ?? {});
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<MagentoProductLite> getProductLiteBySku({required String sku}) async {
    try {
      if (_adminToken == null) throw Exception('Admin token not available.');
      if (_adminDio == null) await init();
      _setAdminAuthHeader(_adminToken);
      final res = await _adminDio.get('products/$sku');
      return MagentoProductLite.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<Map<String, dynamic>> getProductLiteBySkuMap({required String sku}) async {
    final lite = await getProductLiteBySku(sku: sku);
    return {
      'sku': lite.sku,
      'name': lite.name,
      'media_gallery_entries': lite.imageFiles.map((f) => {'file': f}).toList(),
    };
  }
  Future<void> createProductAsVendor(Map<String, dynamic> payload) async {
    try {
      if (_dio == null) await init();
      _setAuthHeader(_vendorToken);
      await _dio.post('products', data: payload);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<List<dynamic>> getCategories() async {
    try {
      if (_adminDio == null) await init();
      _setAdminAuthHeader(_adminToken);
      final res = await _adminDio.get('categories');
      return res.data;
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<List<dynamic>> getAllCategories() async {
    try {
      if (_adminToken == null) throw Exception('Admin token not available.');
      if (_adminDio == null) await init();
      _setAdminAuthHeader(_adminToken);
      final res = await _adminDio.get('categories');
      return (res.data['children_data'] as List?) ?? const [];
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> getOrders({
    required int currentPage,
    required int pageSize,
    String? status,
  }) async {
    try {
      if (_dio == null) await init();
      _setAuthHeader(_vendorToken);
      final qp = <String, dynamic>{
        'searchCriteria[filterGroups][0][filters][0][field]': 'vendor_id',
        'searchCriteria[filterGroups][0][filters][0][value]': vendorId,
        'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
        'searchCriteria[currentPage]': currentPage,
        'searchCriteria[pageSize]': pageSize,
      };
      if (status != null) {
        qp['searchCriteria[filterGroups][1][filters][0][field]'] = 'status';
        qp['searchCriteria[filterGroups][1][filters][0][value]'] = status;
        qp['searchCriteria[filterGroups][1][filters][0][conditionType]'] = 'eq';
      }
      final res = await _dio.get('orders', queryParameters: qp);
      return Map<String, dynamic>.from(res.data ?? {});
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<List<Map<String, dynamic>>> getVendorOrders({
    DateTime? dateFrom,
    DateTime? dateTo,
    int currentPage = 1,
    int pageSize = 20,
  }) async {
    try {
      if (vendorId == null) throw Exception('Vendor ID is not available.');
      if (_dio == null) await init();
      _setAuthHeader(_vendorToken);
      final qp = {
        'searchCriteria[filterGroups][0][filters][0][field]': 'vendor_id',
        'searchCriteria[filterGroups][0][filters][0][value]': vendorId,
        'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
        'searchCriteria[currentPage]': currentPage,
        'searchCriteria[pageSize]': pageSize,
      };
      if (dateFrom != null) {
        qp['searchCriteria[filterGroups][1][filters][0][field]'] = 'created_at';
        qp['searchCriteria[filterGroups][1][filters][0][value]'] = dateFrom.toIso8601String();
        qp['searchCriteria[filterGroups][1][filters][0][conditionType]'] = 'gteq';
      }
      if (dateTo != null) {
        qp['searchCriteria[filterGroups][2][filters][0][field]'] = 'created_at';
        qp['searchCriteria[filterGroups][2][filters][0][value]'] = dateTo.toIso8601String();
        qp['searchCriteria[filterGroups][2][filters][0][conditionType]'] = 'lteq';
      }
      final res = await _dio.get('orders', queryParameters: qp);
      return List<Map<String, dynamic>>.from(res.data['items'] ?? []);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<List<dynamic>> searchVendorOrders(
      String searchQuery, {
        String? status,
        int pageSize = 20,
        int currentPage = 1,
      }) async {
    try {
      if (vendorId == null) throw Exception('Vendor ID is not available.');
      if (_dio == null) await init();
      _setAuthHeader(_vendorToken);
      final qp = {
        'searchCriteria[filterGroups][0][filters][0][field]': 'vendor_id',
        'searchCriteria[filterGroups][0][filters][0][value]': vendorId,
        'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
        'searchCriteria[filterGroups][1][filters][0][field]': 'increment_id',
        'searchCriteria[filterGroups][1][filters][0][value]': '%$searchQuery%',
        'searchCriteria[filterGroups][1][filters][0][conditionType]': 'like',
        'searchCriteria[pageSize]': '$pageSize',
        'searchCriteria[currentPage]': '$currentPage',
      };
      if (status != null) {
        qp['searchCriteria[filterGroups][2][filters][0][field]'] = 'status';
        qp['searchCriteria[filterGroups][2][filters][0][value]'] = status;
      }
      final res = await _dio.get('orders', queryParameters: qp);
      return (res.data['items'] as List?) ?? const [];
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<List<Map<String, dynamic>>> getOrdersAdmin({
    DateTime? dateFrom,
    DateTime? dateTo,
    int currentPage = 1,
    int pageSize = 20,
  }) async {
    try {
      if (_adminToken == null) throw Exception('Admin token not available.');
      if (_adminDio == null) await init();
      _setAdminAuthHeader(_adminToken);
      final qp = <String, dynamic>{
        'searchCriteria[currentPage]': currentPage,
        'searchCriteria[pageSize]': pageSize,
      };
      int g = 0;
      if (dateFrom != null) {
        qp['searchCriteria[filterGroups][$g][filters][0][field]'] = 'created_at';
        qp['searchCriteria[filterGroups][$g][filters][0][value]'] = dateFrom.toUtc().toIso8601String();
        qp['searchCriteria[filterGroups][$g][filters][0][conditionType]'] = 'from';
        g++;
      }
      if (dateTo != null) {
        qp['searchCriteria[filterGroups][$g][filters][0][field]'] = 'created_at';
        qp['searchCriteria[filterGroups][$g][filters][0][value]'] = dateTo.toUtc().toIso8601String();
        qp['searchCriteria[filterGroups][$g][filters][0][conditionType]'] = 'to';
      }
      final res = await _adminDio.get('orders', queryParameters: qp);
      return List<Map<String, dynamic>>.from(res.data['items'] ?? []);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> getInvoiceById({required int invoiceId}) async {
    try {
      if (_adminToken == null && _vendorToken == null) {
        throw Exception('No token set.');
      }
      if (_adminToken != null) {
        if (_adminDio == null) await init();
        _setAdminAuthHeader(_adminToken);
        final res = await _adminDio.get('invoices/$invoiceId');
        return Map<String, dynamic>.from(res.data ?? {});
      } else {
        if (_dio == null) await init();
        _setAuthHeader(_vendorToken);
        final res = await _dio.get('invoices/$invoiceId');
        return Map<String, dynamic>.from(res.data ?? {});
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<List<dynamic>> getInvoiceComments({required int invoiceId}) async {
    try {
      if (_adminToken != null) {
        if (_adminDio == null) await init();
        _setAdminAuthHeader(_adminToken);
        final res = await _adminDio.get('invoices/$invoiceId/comments');
        return (res.data['items'] as List?) ?? const [];
      } else {
        if (_dio == null) await init();
        _setAuthHeader(_vendorToken);
        final res = await _dio.get('invoices/$invoiceId/comments');
        return (res.data['items'] as List?) ?? const [];
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<void> addInvoiceComment({
    required int invoiceId,
    required String comment,
    bool isVisibleOnFront = false,
  }) async {
    try {
      if (_adminToken != null) {
        if (_adminDio == null) await init();
        _setAdminAuthHeader(_adminToken);
        await _adminDio.post('invoices/$invoiceId/comments', data: {
          'comment': {'comment': comment, 'is_visible_on_front': isVisibleOnFront},
        });
      } else {
        if (_dio == null) await init();
        _setAuthHeader(_vendorToken);
        await _dio.post('invoices/$invoiceId/comments', data: {
          'comment': {'comment': comment, 'is_visible_on_front': isVisibleOnFront},
        });
      }
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      if (vendorId == null) throw Exception('Vendor ID is not available.');
      if (_dio == null) await init();
      _setAuthHeader(_vendorToken);
      final qp1 = <String, dynamic>{
        'searchCriteria[filterGroups][0][filters][0][field]': 'vendor_id',
        'searchCriteria[filterGroups][0][filters][0][value]': vendorId,
        'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
        'searchCriteria[pageSize]': 100,
      };
      final ordersRes = await _dio.get('orders', queryParameters: qp1);
      final orders = (ordersRes.data['items'] as List?) ?? const [];
      final totalOrders = (ordersRes.data['total_count'] as int?) ?? orders.length;
      double totalRevenue = 0;
      for (final o in orders) {
        totalRevenue += double.tryParse(o['grand_total']?.toString() ?? '0') ?? 0;
      }
      final qp2 = <String, dynamic>{
        'searchCriteria[filterGroups][0][filters][0][field]': 'vendor_id',
        'searchCriteria[filterGroups][0][filters][0][value]': vendorId,
        'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
        'searchCriteria[pageSize]': 1,
      };
      final productsRes = await _dio.get('products', queryParameters: qp2);
      final totalProducts = (productsRes.data['total_count'] as int?) ?? 0;
      final qp3 = <String, dynamic>{
        'searchCriteria[filterGroups][0][filters][0][field]': 'vendor_id',
        'searchCriteria[filterGroups][0][filters][0][value]': vendorId,
        'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
        'searchCriteria[filterGroups][1][filters][0][field]': 'status',
        'searchCriteria[filterGroups][1][filters][0][value]': 'pending',
        'searchCriteria[filterGroups][1][filters][0][conditionType]': 'eq',
        'searchCriteria[pageSize]': 1,
      };
      final pendingRes = await _dio.get('orders', queryParameters: qp3);
      final pendingOrders = (pendingRes.data['total_count'] as int?) ?? 0;
      return {
        'total_orders': totalOrders,
        'total_revenue': totalRevenue,
        'total_products': totalProducts,
        'pending_orders': pendingOrders,
      };
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<List<Map<String, dynamic>>> getSalesHistory({int days = 30}) async {
    try {
      if (vendorId == null) throw Exception('Vendor ID is not available.');
      if (_dio == null) await init();
      _setAuthHeader(_vendorToken);
      final now = DateTime.now();
      final start = now.subtract(Duration(days: days)).toIso8601String();
      final qp = {
        'searchCriteria[filterGroups][0][filters][0][field]': 'vendor_id',
        'searchCriteria[filterGroups][0][filters][0][value]': vendorId,
        'searchCriteria[filterGroups][0][filters][0][conditionType]': 'eq',
        'searchCriteria[pageSize]': 100,
      };

      qp['searchCriteria[filterGroups][1][filters][0][field]'] = 'created_at';
      qp['searchCriteria[filterGroups][1][filters][0][value]'] = start;
      qp['searchCriteria[filterGroups][1][filters][0][conditionType]'] = 'gteq';
      final res = await _dio.get('orders', queryParameters: qp);
      final orders = List<Map<String, dynamic>>.from(res.data['items'] ?? []);
      final map = <String, double>{};
      for (final o in orders) {
        final date = (o['created_at']?.toString().split(' ').first) ?? '';
        final amount = double.tryParse(o['grand_total']?.toString() ?? '0') ?? 0.0;
        if (date.isEmpty) continue;
        map[date] = (map[date] ?? 0.0) + amount;
      }
      return map.entries
          .map((e) => {'date': e.key, 'amount': e.value})
          .toList()
        ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<Map<String, dynamic>> getCustomerBreakdown() async {
    try {
      if (_adminToken == null) throw Exception('Admin token not available.');
      if (_adminDio == null) await init();
      _setAdminAuthHeader(_adminToken);
      final res = await _adminDio.get('customers/search', queryParameters: {
        'searchCriteria[pageSize]': 100,
      });
      final customers = List<Map<String, dynamic>>.from(res.data['items'] ?? []);
      final total = customers.length;
      final newCount = customers.where((c) {
        final created = c['created_at']?.toString();
        if (created == null) return false;
        final date = DateTime.parse(created.split(' ').first);
        return date.isAfter(DateTime.now().subtract(const Duration(days: 30)));
      }).length;
      final returning = total - newCount;
      return {
        'total_customers': total,
        'new_customers': newCount,
        'returning_customers': returning,
      };
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<List<Map<String, dynamic>>> getTopSellingProducts({int limit = 10}) async {
    try {
      if (_adminToken == null) throw Exception('Admin token not available.');
      if (_adminDio == null) await init();
      _setAdminAuthHeader(_adminToken);
      final res = await _adminDio.get('products', queryParameters: {
        'searchCriteria[sortOrders][0][field]': 'created_at',
        'searchCriteria[sortOrders][0][direction]': 'DESC',
        'searchCriteria[pageSize]': limit,
      });
      final items = List<Map<String, dynamic>>.from(res.data['items'] ?? []);
      return items.map((p) => {'id': p['id'], 'name': p['name'], 'sku': p['sku'], 'price': p['price'], 'image': (p['media_gallery_entries'] as List?)?.isNotEmpty == true ? (p['media_gallery_entries'][0]['file'] ?? '') : '', 'qty_sold': 0,}).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<List<Map<String, dynamic>>> getTopCategories({int limit = 5}) async {
    try {
      if (_adminToken == null) throw Exception('Admin token not available.');
      if (_adminDio == null) await init();
      _setAdminAuthHeader(_adminToken);
      final res = await _adminDio.get('categories');
      final children = (res.data['children_data'] as List?) ?? const [];
      return children.take(limit).map((e) => Map<String, dynamic>.from(e)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<List<Map<String, dynamic>>> getProductRatings() async {
    try {
      if (_adminToken == null) throw Exception('Admin token not available.');
      if (_adminDio == null) await init();
      _setAdminAuthHeader(_adminToken);
      final res = await _adminDio.get('reviews', queryParameters: {
        'searchCriteria[pageSize]': 20,
      });
      final reviews = List<Map<String, dynamic>>.from(res.data['items'] ?? []);
      final map = <String, List<int>>{};
      for (final r in reviews) {
        final sku = r['extension_attributes']?['sku'] ?? r['product_sku'];
        final rating = r['ratings']?[0]?['value'] ?? r['rating_votes']?[0]?['value'];
        if (sku != null && rating != null) {
          (map[sku] ??= []).add(int.tryParse(rating.toString()) ?? 0);
        }
      }
      return map.entries.map((e) => {'product_sku': e.key, 'average_rating': e.value.isEmpty ? 0 : e.value.reduce((a, b) => a + b) / e.value.length, 'total_reviews': e.value.length,}).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<List<Map<String, dynamic>>> getLatestReviews({int limit = 10}) async {
    try {
      if (_adminToken == null) throw Exception('Admin token not available.');
      if (_adminDio == null) await init();
      _setAdminAuthHeader(_adminToken);
      final res = await _adminDio.get('reviews', queryParameters: {
        'searchCriteria[pageSize]': limit,
        'searchCriteria[sortOrders][0][field]': 'created_at',
        'searchCriteria[sortOrders][0][direction]': 'DESC',
      });
      final reviews = List<Map<String, dynamic>>.from(res.data['items'] ?? []);
      return reviews.map((r) => {'id': r['id'], 'title': r['title'], 'detail': r['detail'], 'nickname': r['nickname'], 'created_at': r['created_at'], 'rating': r['ratings']?[0]?['value'] ?? r['rating_votes']?[0]?['value'] ?? 0, 'product_sku': r['extension_attributes']?['sku'] ?? r['product_sku'],}).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }
  Future<Map<String, dynamic>> getCustomerInfo() async {
    try {
      if (_dio == null) await init();
      _setAuthHeader(_vendorToken);
      final res = await _dio.get('customers/me');
      final map = Map<String, dynamic>.from(res.data ?? {});
      return {'id': map['id'], 'email': map['email'], 'firstname': map['firstname'], 'lastname': map['lastname'], 'phone': map['telephone'] ?? map['phone'], 'created_at': map['created_at'],};
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  Future<void> sendContactMessage({
    required String name,
    required String email,
    required String telephone,
    required String comment,
  }) async {
    try {
      if (_dio == null) await init();
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
  String _handleDioError(DioException e) {
    if (e.response != null && e.response!.data is Map) {
      final data = e.response!.data as Map;
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timed out. Please check your internet connection.';
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Response timed out. The server might be busy.';
    }
    return e.message ?? 'An unknown error occurred.';
  }
  Future<void> _loadVendorTokens() async {
    _vendorToken = await _secureStorage.read(key: _tokenKey);
    _setAuthHeader(_vendorToken);
  }
  String guessMimeFromName(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg': case 'jpeg': return 'image/jpeg';
      case 'png': return 'image/png';
      case 'gif': return 'image/gif';
      case 'webp': return 'image/webp';
      case 'bmp': return 'image/bmp';
      case 'svg': return 'image/svg+xml';
      case 'pdf': return 'application/pdf';
      case 'json': return 'application/json';
      case 'csv': return 'text/csv';
      default: return 'application/octet-stream';
    }
  }
  String parseMagentoError(dynamic error) {
    if (error is DioException) return _handleDioError(error);
    return error.toString();
  }
  String get _originFromBase {
    final uri = Uri.parse(_dio.options.baseUrl);
    return Uri(scheme: uri.scheme, host: uri.host, port: uri.hasPort ? uri.port : null,).toString().replaceAll(RegExp(r'/$'), '');
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
      if (_adminToken == null) return false;
      _setAdminAuthHeader(_adminToken);
      final res = await _adminDio.get('');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}