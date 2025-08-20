// main.dart

import 'package:app_vendor/state_management/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_vendor/presentation/analytics/customer_analytics_screen.dart';
import 'package:app_vendor/presentation/dashboard/dashboard_screen.dart';
import 'package:app_vendor/presentation/orders/orders_list_screen.dart';
import 'package:app_vendor/presentation/payouts/payouts_screen.dart';
import 'package:app_vendor/presentation/products/add_product_screen.dart';
import 'package:app_vendor/presentation/products/drafts_list_screen.dart';
import 'package:app_vendor/presentation/products/products_list_screen.dart';
import 'package:app_vendor/presentation/revenue/revenue_screen.dart';
import 'package:app_vendor/presentation/reviews/reviews_screen.dart';
import 'package:app_vendor/presentation/transactions/transactions_screen.dart' as transactions_screen; // <-- AJOUT DE L'ALIAS ICI
import 'package:app_vendor/l10n/app_localizations.dart';
import 'presentation/common/app_shell.dart';
import 'presentation/common/nav_key.dart';

// --- INITIALISATION ASYNCHRONE DE LA LANGUE ---
void main() async {
  // Garantit que les services natifs de Flutter sont initialisés
  WidgetsFlutterBinding.ensureInitialized();

  // Crée une instance du provider
  final localeProvider = LocaleProvider();

  // Charge la langue sauvegardée de manière asynchrone
  await localeProvider.loadSavedLocale();

  // Lance l'application en passant le provider initialisé
  runApp(MyApp(localeProvider: localeProvider));
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
            // --- UTILISATION DE LA LOCALE FOURNIE PAR LE PROVIDER ---
            locale: provider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // --------------------------------------------------------
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Inter',
              scaffoldBackgroundColor: Colors.white,
            ),
            home: const Home(),
          );
        },
      ),
    );
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
        return const transactions_screen.TransactionsScreen(); // <-- UTILISATION DE L'ALIAS
      case NavKey.payouts:
        return const PayoutsScreen();
      case NavKey.revenue:
        return const RevenueScreen();
      case NavKey.review:
        return const ReviewsScreen();
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