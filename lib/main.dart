import 'package:flutter/material.dart';
import 'package:vendor_app/presentation/revenue/revenue_screen.dart';
import 'package:vendor_app/presentation/transactions/transactions_screen.dart';
import 'presentation/common/app_shell.dart';
import 'presentation/common/nav_key.dart';

// screens you already have
import 'presentation/dashboard/dashboard_screen.dart';
import 'presentation/orders/orders_list_screen.dart';
import 'presentation/analytics/customer_analytics_screen.dart';
import 'presentation/payouts/payouts_screen.dart';       // if you map to "transactions", adjust
import 'presentation/pdf/print_pdf_screen.dart';
import 'presentation/products/add_product_screen.dart';
import 'presentation/products/products_list_screen.dart';
import 'presentation/products/drafts_list_screen.dart';
import 'presentation/profile/edit_profile_screen.dart';

void main() => runApp(const KolshyApp());

class KolshyApp extends StatelessWidget {
  const KolshyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kolshy',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Inter', scaffoldBackgroundColor: Colors.white),
      home: const Home(),
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
      onSelect: (k) => setState(() => _selected = k),
      bottomIndex: _bottomIndex,
      onBottomTap: (i) => setState(() => _bottomIndex = i),
      unreadCount: _unreadCount,
      onOpenNotifications: _showNotifications,
      child: _screenFor(_selected),
    );
  }

  // === route mapper -> ALL page code lives in their own files ===
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
      case NavKey.revenue:
        return const PrintPdfScreen();
      case NavKey.review:
        return const ReviewsScreen();
    }
  }

  Future<void> _showNotifications() async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(.25),
      builder: (context) => AlertDialog(
        title: const Text('Notification'),
        content: const Text('…your notifications list here…'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
    setState(() => _unreadCount = 0);
  }
}
