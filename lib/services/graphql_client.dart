import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GraphQLClientService {
  static final GraphQLClientService _instance = GraphQLClientService._internal();
  factory GraphQLClientService() => _instance;
  GraphQLClientService._internal();

  static const String _graphqlEndpoint = 'https://kolshy.ae/graphql';
  String? _token;

  Future<GraphQLClient> getClient() async {
    await _loadToken();

    final HttpLink httpLink = HttpLink(_graphqlEndpoint);

    final AuthLink authLink = AuthLink(
      getToken: () async => _token != null ? 'Bearer $_token' : '',
    );

    final Link link = authLink.concat(httpLink);

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('vendor_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vendor_token', token);
    _instance._token = token;
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vendor_token');
    _instance._token = null;
  }

  bool get hasToken => _token != null && _token!.isNotEmpty;
}