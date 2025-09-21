

import 'package:kolshy_vendor/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kolshy_vendor/state_management/locale_provider.dart';
import 'package:kolshy_vendor/l10n/app_localizations.dart';
import 'presentation/Translation/Language.dart';
import 'presentation/admin/admin_news_screen.dart';
import 'presentation/admin/ask_admin_screen.dart';
import 'presentation/pdf/print_pdf_screen.dart';
import 'presentation/analytics/customer_analytics_screen.dart';
import 'presentation/dashboard/dashboard_screen.dart';
import 'presentation/orders/orders_list_screen.dart';
import 'presentation/products/add_product_screen.dart';
import 'presentation/products/drafts_list_screen.dart';
import 'presentation/products/products_list_screen.dart';
import 'presentation/revenue/revenue_screen.dart';
import 'presentation/reviews/reviews_screen.dart';
import 'presentation/transactions/transactions_screen.dart' as transactions_screen;
import 'presentation/common/app_shell.dart';
import 'presentation/common/nav_key.dart';
import 'presentation/auth/login/welcome_screen.dart';
import 'presentation/profile/view_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('Starting app initialization...');

    final localeProvider = LocaleProvider();
    print('Loading saved locale...');
    await localeProvider.loadSavedLocale();

    print('Initializing VendorApiClient...');
    await VendorApiClient().init();

    print('App initialization completed successfully.');
    runApp(MyApp(localeProvider: localeProvider));

  } catch (e) {
    print('App initialization failed with an error: $e');
    runApp(const ErrorApp());
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'An error occurred during app startup. Please check the logs.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final LocaleProvider localeProvider;

  const MyApp({super.key, required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: localeProvider,
      child: Consumer<LocaleProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Kolshy',
            locale: provider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback: (locale, supportedLocales) {
              if (locale == null) return supportedLocales.first;
              for (var supported in supportedLocales) {
                if (supported.languageCode == locale.languageCode) {
                  return supported;
                }
              }
              return supportedLocales.first;
            },
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Inter',
              scaffoldBackgroundColor: Colors.white,
            ),
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;
  final _apiClient = VendorApiClient();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final hasToken = _apiClient.hasToken;
      if (hasToken) {
        await _apiClient.getVendorProfile();
        setState(() {
          _isLoggedIn = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      final apiClient = VendorApiClient();
      await apiClient.removeToken();
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isLoggedIn ? const Home() : const WelcomeScreen();
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  NavKey _selected = NavKey.dashboard;
  int _bottomIndex = 1;
  int _unreadCount = 4;

  @override
  Widget build(BuildContext context) {
    print('Building Home screen...');

    return AppShell(
      scaffoldKey: _scaffoldKey,
      selected: _selected,
      onSelect: (k) {
        setState(() {
          _selected = k;
          _scaffoldKey.currentState?.closeDrawer();
        });
      },
      bottomIndex: _bottomIndex,
      onBottomTap: (i) {
        setState(() {
          _bottomIndex = i;
          _selected = _navKeyForBottomIndex(i);
          if (i == 3) {
            _unreadCount = 0;
          }
        });
      },
      unreadCount: _unreadCount,
      child: _screenFor(_selected),
    );
  }

  Widget _screenFor(NavKey key) {
    switch (key) {
      case NavKey.dashboard:
        return const DashboardScreen();
      case NavKey.orders:
        return const OrdersListScreen();
      case NavKey.productAdd:
        return const AddProductScreen();
      case NavKey.productList:
        return const ProductsListScreen();
      case NavKey.productDrafts:
        return const DraftsListScreen();
      case NavKey.analytics:
        return const CustomerAnalyticsScreen();
      case NavKey.transactions:
        return const transactions_screen.TransactionsScreen();
      case NavKey.revenue:
        return const RevenueScreen();
      case NavKey.review:
        return const ReviewsScreen();
      case NavKey.profileSettings:
        return const VendorProfileScreen();
      case NavKey.printPdf:
        return const PrintPdfScreen();
      case NavKey.adminNews:
        return const AdminNewsScreen();
      case NavKey.askadmin:
        return const AskAdminScreen();
      case NavKey.language:
        return const LanguageScreen();
      default:
        return const DashboardScreen();
    }
  }

  NavKey _navKeyForBottomIndex(int index) {
    switch (index) {
      case 1:
        return NavKey.dashboard;
      case 2:
        return NavKey.orders;
      case 3:
        return _selected;
      case 0:
      default:
        return _selected;
    }
  }
}