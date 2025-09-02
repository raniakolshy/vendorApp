import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  static const String _adminToken = "87igct1wbbphdok6dk1roju4i83kyub9";

  factory AuthService() => _instance;

  AuthService._internal()
      : _dio = Dio(
    BaseOptions(
      baseUrl: "https://kolshy.ae/rest/V1/",
      headers: {
        "Authorization": "Bearer 87igct1wbbphdok6dk1roju4i83kyub9",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // --------- utilities ---------
  String _magentoErr(DioException e, {String fallback = "An error occurred"}) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) return data['message'];
    if (data is Map && data['parameters'] is List && data['parameters'].isNotEmpty) {
      return '${data['message']} (${data['parameters'].join(", ")})';
    }
    if (data is String && data.isNotEmpty) return data;
    return fallback;
  }

  Future<void> _saveToken(String token) async {
    await _storage.write(key: 'authToken', value: token);
  }

  Future<void> _clearToken() async {
    await _storage.delete(key: 'authToken');
  }

  Future<String?> getToken() => _storage.read(key: 'authToken');
  Future<bool> isLoggedIn() async => (await getToken())?.isNotEmpty == true;

  // --------- login ---------
  Future<String> login(String email, String password) async {
    try {
      final res = await _dio.post(
        'integration/customer/token',
        data: {'username': email.trim(), 'password': password},
        options: Options(headers: {'Authorization': null}),
      );
      final token = (res.data as String).replaceAll('"', '').trim();
      if (token.isEmpty) throw Exception("Access code not received");
      await _storage.write(key: 'authToken', value: token);
      return token;
    } on DioException catch (e) {
      throw Exception(_magentoErr(e, fallback: "login failed"));
    } catch (e) {
      throw Exception("login failed: $e");
    }
  }

  // --------- customer register ---------
  Future<String> registerCustomer({
    required String email,
    required String firstname,
    required String lastname,
    required String password,
  }) async {
    try {
      final payload = {
        'customer': {
          'email': email.trim().toLowerCase(),
          'firstname': firstname.trim(),
          'lastname': lastname.trim(),
          'website_id': 1, // adjust to your website id
          // 'store_id': 1,
        },
        'password': password,
      };

      await _dio.post(
        'customers',
        data: payload,
        options: Options(headers: {'Authorization': null}),
      );

      // auto login after register
      return await login(email, password);
    } on DioException catch (e) {
      throw Exception(_magentoErr(e, fallback: "Account creation failed"));
    } catch (e) {
      throw Exception("Account creation failed: $e");
    }
  }

  // --------- vendor register (requires admin token) ---------
  Future<void> registerVendor({
    required String email,
    required String firstname,
    required String lastname,
    required String password,
  }) async {
    try {
      final payload = {
        'customer': {
          'email': email.trim(),
          'firstname': firstname.trim(),
          'lastname': lastname.trim(),
        },
        'password': password,
      };

      await _dio.post(
        'customers',
        data: payload,
        options: Options(headers: {
          "Authorization": "Bearer $_adminToken",
          "Content-Type": "application/json",
          "Accept": "application/json",
        }),
      );
    } on DioException catch (e) {
      final msg = _magentoErr(e, fallback: "Vendor creation failed");
      throw Exception(msg);
    }
  }

  // --------- logout ---------
  Future<void> logout() async {
    try {
      await _dio.post('integration/customer/revoke'); // must be with *customer* token
    } catch (_) {} finally {
      await _storage.delete(key: 'authToken');
    }
  }
}
