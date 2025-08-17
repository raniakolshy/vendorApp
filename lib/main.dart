import 'package:flutter/material.dart';
import 'package:vendor_app/presentation/auth/login/welcome_screen.dart';
import 'package:vendor_app/presentation/reviews/reviews_screen.dart';
import 'presentation/common/app_shell.dart';
import 'presentation/common/nav_key.dart';
import 'package:vendor_app/presentation/analytics/customer_analytics_screen.dart';
import 'package:vendor_app/presentation/dashboard/dashboard_screen.dart';
import 'package:vendor_app/presentation/orders/orders_list_screen.dart';
import 'package:vendor_app/presentation/payouts/payouts_screen.dart';
import 'package:vendor_app/presentation/products/add_product_screen.dart';
import 'package:vendor_app/presentation/products/drafts_list_screen.dart';
import 'package:vendor_app/presentation/products/products_list_screen.dart';
import 'package:vendor_app/presentation/revenue/revenue_screen.dart';
import 'package:vendor_app/presentation/transactions/transactions_screen.dart';

void main() => runApp(const KolshyApp());

class KolshyApp extends StatelessWidget {
  const KolshyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kolshy',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const WelcomeScreen(),
    );
  }
}

// Add the missing Home StatefulWidget class here
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  NavKey _selected = NavKey.dashboard;

  // The 'home' icon is at index 1 in your AppShell, so we start there.
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
        });
      },
      unreadCount: _unreadCount,
      onOpenNotifications: _showNotifications,
      child: _screenFor(_selected),
    );
  }

  // === route mapper ===
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
        return const TransactionsScreen();
    // Corrected mapping: using PayoutsScreen for transactions
      case NavKey.payouts:
        return const PayoutsScreen();
    // Corrected mapping: assuming RevenueScreen is the correct destination
      case NavKey.revenue:
        return const ReviewsScreen();
    // Added missing case for ReviewsScreen
      case NavKey.review:
        return const ReviewsScreen();
    // Fallback for unmapped keys to avoid errors
      default:
        return const DashboardScreen();
    }
  }

  // A helper function to map the bottom bar index to a NavKey.
  NavKey _navKeyForBottomIndex(int index) {
    switch (index) {
      case 1:
        return NavKey.dashboard;
      case 2:
        return NavKey.orders; // The 'chat' icon
      case 3:
      // Assuming notifications have their own screen or NavKey
        return NavKey.dashboard; // Fallback to dashboard for now
      default:
        return NavKey.dashboard;
    }
  }

  Future<void> _showNotifications() async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.25),
      builder: (context) => AlertDialog(
        title: const Text('Notification'),
        content: const Text('…your notifications list here…'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    setState(() => _unreadCount = 0);
  }
}