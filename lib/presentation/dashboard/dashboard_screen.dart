// lib/presentation/dashboard/dashboard_screen.dart
import 'dart:math' show min, max, pi, atan2;
import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../services/api_client.dart';


/// =============================================================
/// Constants / Colors
/// =============================================================
const double kHeaderHeight   = 200;
const double kStatCardWidth  = 140;
const double kStatCardHeight = 92;
const double kStatOverlap    = kStatCardHeight / 2;

const Color kPrimaryLine  = Color(0xFF97ADFF); // 97ADFF
const Color kCompareLine  = Color(0xFFFFC879); // FFC879
const Color kPageBg       = Color(0xFFF6F7FB);
const Color kHeaderColor  = Color(0xFF222222);

/// =============================================================
/// Models for UI
/// =============================================================
class ProductTileData {
  final String name;
  final double price;
  final int sold;
  final Widget? thumb; // e.g. Image.network(...)
  ProductTileData({required this.name, required this.price, required this.sold, this.thumb});
}

class CategoryTileData {
  final String name;
  final int items;
  final Widget? icon;
  CategoryTileData({required this.name, required this.items, this.icon});
}

class Review {
  final String user;
  final int rating; // 1..5
  final String timeAgo; // e.g., "2h"
  final String comment;
  final String? product;
  Review({required this.user, required this.rating, required this.timeAgo, required this.comment, this.product});
}

/// =============================================================
/// Ranges: internal keys + localized labels
/// =============================================================
const String kRangeAll   = 'all';
const String kRange30    = 'last30';
const String kRange7     = 'last7';
const String kRangeYear  = 'year';

List<String> rangeKeys() => const [kRangeAll, kRange30, kRange7, kRangeYear];

String rangeLabel(BuildContext context, String key) {
  final l10n = AppLocalizations.of(context)!;
  switch (key) {
    case kRange30: return l10n.rangeLast30Days;
    case kRange7:  return l10n.rangeLast7Days;
    case kRangeYear:return l10n.rangeThisYear;
    default:       return l10n.rangeAllTime;
  }
}

List<String> xLabelsForRangeKey(BuildContext context, String key) {
  final l = AppLocalizations.of(context)!;
  switch (key) {
    case kRange7:
      return [l.weekMon, l.weekTue, l.weekWed, l.weekThu, l.weekFri, l.weekSat, l.weekSun];
    case kRange30:
      return ['1','5','10','15','20','25','30'];
    case kRangeYear:
      return [l.monthJan, l.monthFeb, l.monthMar, l.monthApr, l.monthMay, l.monthJun, l.monthJul, l.monthAug, l.monthSep, l.monthOct, l.monthNov, l.monthDec];
    default:
      return ['2019','2020','2021','2022','2023','2024'];
  }
}

/// Convert website daily map into FL spots according to selected range.
List<FlSpot> spotsFromSiteByKey(Map<DateTime, double> daily, String key) {
  final entries = daily.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

  if (key == kRangeYear) {
    final now = DateTime.now();
    final byMonth = List<double?>.filled(12, null);
    final counts  = List<int>.filled(12, 0);
    for (final e in entries.where((e) => e.key.year == now.year)) {
      final m = e.key.month - 1;
      (byMonth[m] == null) ? byMonth[m] = e.value : byMonth[m] = byMonth[m]! + e.value;
      counts[m] += 1;
    }
    for (var i = 0; i < 12; i++) {
      if (counts[i] > 0) byMonth[i] = byMonth[i]! / counts[i];
      byMonth[i] ??= (i > 0 ? byMonth[i - 1] : (entries.isNotEmpty ? entries.first.value : 0));
    }
    return List.generate(12, (i) => FlSpot(i.toDouble(), byMonth[i]!.toDouble()));
  }

  if (key == kRange30) {
    final last30 = entries.where((e) => e.key.isAfter(DateTime.now().subtract(const Duration(days: 30)))).toList();
    final anchor = [1, 5, 10, 15, 20, 25, 30];
    return List.generate(anchor.length, (i) {
      final target = DateTime.now().subtract(Duration(days: 30 - anchor[i]));
      final nearest = last30.isEmpty ? null
          : last30.reduce((a, b) => (a.key.difference(target)).abs() < (b.key.difference(target)).abs() ? a : b);
      return FlSpot(i.toDouble(), (nearest?.value ?? (entries.isNotEmpty ? entries.last.value : 0)));
    });
  }

  if (key == kRange7) {
    final last7 = entries.where((e) => e.key.isAfter(DateTime.now().subtract(const Duration(days: 7)))).toList();
    final base = (entries.isNotEmpty ? entries.last.value : 0.0);
    final arr = List<double>.filled(7, base);
    for (final e in last7) {
      final diff = DateTime.now().difference(e.key).inDays;
      final pos = 6 - diff;
      if (pos >= 0 && pos < 7) arr[pos] = e.value;
    }
    return List.generate(7, (i) => FlSpot(i.toDouble(), arr[i]));
  }

  // All time (by year, averaged)
  final years = entries.map((e) => e.key.year).toSet().toList()..sort();
  final byYear = <int, double>{};
  final counts = <int, int>{};
  for (final e in entries) {
    byYear[e.key.year] = (byYear[e.key.year] ?? 0) + e.value;
    counts[e.key.year] = (counts[e.key.year] ?? 0) + 1;
  }
  final vals = years.map((y) => (byYear[y]! / counts[y]!.clamp(1, 1 << 30))).toList();
  return List.generate(years.length, (i) => FlSpot(i.toDouble(), vals[i]));
}

/// Compute tight Y bounds with padding so nothing clips.
({double minY, double maxY}) yBounds(List<FlSpot> a, [List<FlSpot>? b]) {
  final all = [...a, if (b != null) ...b];
  if (all.isEmpty) return (minY: 0, maxY: 1);
  var lo = all.first.y, hi = all.first.y;
  for (final s in all) {
    lo = min(lo, s.y);
    hi = max(hi, s.y);
  }
  const pad = 0.2;
  var minY = lo - pad, maxY = hi + pad;
  if (minY == maxY) { minY -= 0.5; maxY += 0.5; }
  minY = (minY * 10).floor() / 10.0;
  maxY = (maxY * 10).ceil() / 10.0;
  return (minY: minY, maxY: maxY);
}

/// =============================================================
/// Dashboard Screen
/// =============================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _dashboardStats;
  Map<String, double>? _salesHistory;
  Map<String, int>? _customerBreakdown;
  List<dynamic> _topProducts = [];
  List<dynamic> _topCategories = [];
  Map<String, Map<int, double>>? _productRatings;
  List<dynamic> _latestReviews = [];
  bool _isLoading = false;
  String _salesRangeKey = kRangeAll;
  String _aovRangeKey   = kRangeAll;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kPageBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: kPageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ---------- Top ----------
              SizedBox(
                height: kHeaderHeight + kStatOverlap + 16,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 0, left: 0, right: 0, height: kHeaderHeight,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: kHeaderColor,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32)),
                        ),
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50, height: 50,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _userName != null ? l10n.helloUser(_userName!) : l10n.hiThere,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w700, color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.letsCheckStore,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: kHeaderHeight,
                      left: 0, right: 0, height: kStatOverlap + 16,
                      child: Container(color: kPageBg),
                    ),
                    Positioned(
                      top: kHeaderHeight - kStatOverlap + 4,
                      left: 0, right: 0,
                      child: const SizedBox.shrink(),
                    ),
                    Positioned(
                      top: kHeaderHeight - kStatOverlap + 4,
                      left: 0, right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _StatRow(dashboardStats: _dashboardStats),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ---------- Content ----------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Total sales
                    TotalSalesCard(
                      rangeKey: _salesRangeKey,
                      onRangeChanged: (v) => setState(() => _salesRangeKey = v),
                      salesHistory: _salesHistory,
                    ),
                    const SizedBox(height: 20),

                    // Customers donut + AOV
                    _TwoUpGrid(children: [
                      SectionCard(
                        title: l10n.totalCustomers,
                        child: _CustomersCard(customerBreakdown: _customerBreakdown),
                      ),
                      SectionCard(
                        title: l10n.averageOrderValue,
                        child: AOVSection(rangeKey: _aovRangeKey, salesHistory: _salesHistory),
                        trailing: _RangeDropDown(
                          value: _aovRangeKey,
                          items: rangeKeys().map((k) => DropdownMenuItem(value: k, child: Text(rangeLabel(context, k)))).toList(),
                          onChanged: (v) => setState(() => _aovRangeKey = v!),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Carousels
                    _TwoUpGrid(children: [
                      SectionCard(
                        title: l10n.topSellingProducts,
                        child: ProductCarousel(products: _convertProductsToTileData(_topProducts)),
                      ),
                      SectionCard(
                        title: l10n.topCategories,
                        child: CategoryCarousel(categories: _convertCategoriesToTileData(_topCategories)),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Ratings
                    SectionCard(
                      title: l10n.ratings,
                      child: RatingsPanel(
                        price: _productRatings?['price'] ?? const {5:0,4:0,3:0,2:0,1:0},
                        value: _productRatings?['value'] ?? const {5:0,4:0,3:0,2:0,1:0},
                        quality: _productRatings?['quality'] ?? const {5:0,4:0,3:0,2:0,1:0},
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Reviews
                    SectionCard(
                      title: l10n.latestCommentsReviews,
                      child: LatestReviewsList(reviews: _convertReviewsToModel(_latestReviews)),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ProductTileData> _convertProductsToTileData(List<dynamic> products) {
    return products.map((product) {
      return ProductTileData(
        name: product['name'] ?? 'Unknown Product',
        price: double.tryParse(product['price']?.toString() ?? '0') ?? 0.0,
        sold: int.tryParse(product['qty_ordered']?.toString() ?? '0') ?? 0,
        thumb: product['image'] != null
            ? Image.network(product['image'].toString(), fit: BoxFit.cover)
            : null,
      );
    }).toList();
  }

  List<CategoryTileData> _convertCategoriesToTileData(List<dynamic> categories) {
    return categories.map((category) {
      return CategoryTileData(
        name: category['name'] ?? 'Unknown Category',
        items: int.tryParse(category['product_count']?.toString() ?? '0') ?? 0,
        icon: const Icon(Icons.category_outlined),
      );
    }).toList();
  }

  List<Review> _convertReviewsToModel(List<dynamic> reviews) {
    return reviews.map((review) {
      return Review(
        user: review['nickname'] ?? 'Anonymous',
        rating: (int.tryParse(review['rating_summary']?.toString() ?? '0') ?? 0) ~/ 20,
        timeAgo: _formatTimeAgo(review['created_at']?.toString() ?? ''),
        comment: review['detail'] ?? 'No comment',
        product: review['product_name']?.toString(),
      );
    }).toList();
  }

  String _formatTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) return '${difference.inDays}d';
      if (difference.inHours > 0) return '${difference.inHours}h';
      if (difference.inMinutes > 0) return '${difference.inMinutes}m';
      return 'Just now';
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _loadUserName() async {
    try {
      final customerInfo = await VendorApiClient().getCustomerInfo();

      if (customerInfo != null) {
        final firstName = customerInfo['firstname'] ?? '';
        final lastName = customerInfo['lastname'] ?? '';
        final email = customerInfo['email'] ?? '';

        setState(() {
          _userName = '$firstName $lastName'.trim();
          if (_userName!.isEmpty) _userName = email;
        });
      } else {
        setState(() {
          _userName = 'Guest';
        });
      }
    } catch (e) {
      // ignore
      setState(() => _userName = 'Guest');
    }
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final vendorApi = VendorApiClient();
      final stats = await vendorApi.getDashboardStats();
      final salesHistory = await vendorApi.getSalesHistory();
      final customerBreakdown = await vendorApi.getCustomerBreakdown();
      final topProducts = await vendorApi.getTopSellingProducts();
      final topCategories = await vendorApi.getTopCategories();
      final productRatings = await vendorApi.getProductRatings();
      final latestReviews = await vendorApi.getLatestReviews();
      final customerInfo = await vendorApi.getCustomerInfo();

      setState(() {
        _dashboardStats     = stats;
        _salesHistory       = _convertToSalesHistory(salesHistory);
        _customerBreakdown  = _convertToCustomerBreakdown(customerBreakdown);
        _topProducts        = topProducts;
        _topCategories      = topCategories;
        _productRatings     = _convertToProductRatings(productRatings);
        _latestReviews      = latestReviews;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
Map<String, double> _convertToSalesHistory(dynamic salesData) {
  final result = <String, double>{};

  if (salesData is Map<String, double>) {
    return salesData;
  } else if (salesData is List<Map<String, dynamic>>) {
    // Convert list of maps to date->amount mapping
    for (var item in salesData) {
      if (item['date'] != null && item['amount'] != null) {
        final date = item['date'].toString();
        final amount = double.tryParse(item['amount'].toString()) ?? 0.0;
        result[date] = amount;
      }
    }
  }

  return result;
}

Map<String, int> _convertToCustomerBreakdown(dynamic breakdownData) {
  final result = <String, int>{};

  if (breakdownData is Map<String, int>) {
    return breakdownData;
  } else if (breakdownData is Map<String, dynamic>) {
    // Convert dynamic values to int
    breakdownData.forEach((key, value) {
      if (value is int) {
        result[key] = value;
      } else if (value is num) {
        result[key] = value.toInt();
      } else if (value is String) {
        result[key] = int.tryParse(value) ?? 0;
      }
    });
  }

  // Ensure we have the expected keys with default values
  result['old'] = result['old'] ?? result['old_customers'] ?? 0;
  result['new'] = result['new'] ?? result['new_customers'] ?? 0;
  result['returning'] = result['returning'] ?? result['returning_customers'] ?? 0;

  return result;
}

Map<String, Map<int, double>> _convertToProductRatings(dynamic ratingsData) {
  final result = <String, Map<int, double>>{};

  if (ratingsData is Map<String, Map<int, double>>) {
    return ratingsData;
  } else if (ratingsData is Map<String, dynamic>) {
    // Convert nested dynamic values to the expected format
    ratingsData.forEach((category, ratingMap) {
      if (ratingMap is Map<int, double>) {
        result[category] = ratingMap;
      } else if (ratingMap is Map<String, dynamic>) {
        final convertedMap = <int, double>{};
        ratingMap.forEach((key, value) {
          final intKey = int.tryParse(key.toString());
          final doubleValue = value is double ? value :
          (value is num ? value.toDouble() :
          double.tryParse(value.toString()) ?? 0.0);
          if (intKey != null) {
            convertedMap[intKey] = doubleValue;
          }
        });
        result[category] = convertedMap;
      }
    });
  } else if (ratingsData is List<Map<String, dynamic>>) {
    // Handle list format - convert to expected structure
    final priceRatings = <int, double>{};
    final valueRatings = <int, double>{};
    final qualityRatings = <int, double>{};

    for (var rating in ratingsData) {
      final stars = int.tryParse(rating['stars']?.toString() ?? '0') ?? 0;
      final pricePercent = double.tryParse(rating['price_percent']?.toString() ?? '0') ?? 0.0;
      final valuePercent = double.tryParse(rating['value_percent']?.toString() ?? '0') ?? 0.0;
      final qualityPercent = double.tryParse(rating['quality_percent']?.toString() ?? '0') ?? 0.0;

      if (stars >= 1 && stars <= 5) {
        priceRatings[stars] = pricePercent;
        valueRatings[stars] = valuePercent;
        qualityRatings[stars] = qualityPercent;
      }
    }

    result['price'] = priceRatings;
    result['value'] = valueRatings;
    result['quality'] = qualityRatings;
  }

  result['price'] = result['price'] ?? {5: 0.0, 4: 0.0, 3: 0.0, 2: 0.0, 1: 0.0};
  result['value'] = result['value'] ?? {5: 0.0, 4: 0.0, 3: 0.0, 2: 0.0, 1: 0.0};
  result['quality'] = result['quality'] ?? {5: 0.0, 4: 0.0, 3: 0.0, 2: 0.0, 1: 0.0};

  return result;
}

// =============================================================
// All of the nested classes moved outside of the State class
// =============================================================

/// Little dropdown used in cards (modern popup)
class _RangeDropDown extends StatelessWidget {
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  const _RangeDropDown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Subtle, clean popup theme
    final popupTheme = Theme.of(context).copyWith(
      dialogTheme: const DialogThemeData(surfaceTintColor: Colors.transparent),
      canvasColor: Colors.white,
      shadowColor: Colors.black26,
    );

    return Theme(
      data: popupTheme,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: Colors.white,
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          style: Theme.of(context).textTheme.bodyMedium,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// =============================================================
/// Small stat row
/// =============================================================
class _StatRow extends StatelessWidget {
  final Map<String, dynamic>? dashboardStats;
  const _StatRow({this.dashboardStats});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final totalRevenue = (dashboardStats?['totalRevenue'] ?? 0.0) as double;
    final orderCount   = (dashboardStats?['orderCount'] ?? 0) as int;
    final customerCount= (dashboardStats?['customerCount'] ?? 0) as int;

    return SizedBox(
      height: kStatCardHeight + 4,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _MiniStatCard(
            iconPath: 'assets/icons/payments_outlined.png',
            label: l.revenue,
            value: l.currencyAmount('AED', totalRevenue.toStringAsFixed(2)),
            delta: '+0% ${l.lastWeek}',
            deltaColor: Colors.green,
          ),
          const SizedBox(width: 12),
          _MiniStatCard(
            iconPath: 'assets/icons/shopping_bag_outlined.png',
            label: l.orders,
            value: orderCount.toString(),
            delta: '+0% ${l.lastWeek}',
            deltaColor: Colors.green,
          ),
          const SizedBox(width: 12),
          _MiniStatCard(
            iconPath: 'assets/icons/people_alt_outlined.png',
            label: l.customers,
            value: customerCount.toString(),
            delta: '+0% ${l.lastWeek}',
            deltaColor: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String iconPath;
  final String label;
  final String value;
  final String delta;
  final Color deltaColor;

  const _MiniStatCard({
    required this.iconPath,
    required this.label,
    required this.value,
    required this.delta,
    required this.deltaColor,
  });

  @override
  Widget build(BuildContext context) {
    final parts   = delta.split(' ');
    final percent = parts.isNotEmpty ? parts.first : delta;
    final rest    = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return Container(
      width: kStatCardWidth,
      height: kStatCardHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            Image.asset(iconPath, width: 20, height: 20),
          ]),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: percent.isEmpty ? '' : '$percent ',
                  style: TextStyle(color: deltaColor, fontSize: 12, fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: rest,
                  style: const TextStyle(color: Color(0xFF9AA1A9), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
              style: DefaultTextStyle.of(context).style,
            ),
          ),
        ],
      ),
    );
  }
}

/// =============================================================
/// Section card (overflow-safe title/trailing)
/// =============================================================
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const SectionCard({super.key, required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (trailing != null)
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.labelMedium!,
                    child: trailing!,
                  ),
                ),
              ),
          ]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// =============================================================
/// TOTAL SALES card
/// =============================================================
class TotalSalesCard extends StatefulWidget {
  final String rangeKey;
  final ValueChanged<String> onRangeChanged;
  final Map<String, double>? salesHistory;

  const TotalSalesCard({
    super.key,
    required this.rangeKey,
    required this.onRangeChanged,
    required this.salesHistory,
  });

  @override
  State<TotalSalesCard> createState() => _TotalSalesCardState();
}

class _TotalSalesCardState extends State<TotalSalesCard> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    // Convert sales history to the format expected by spotsFromSiteByKey
    final Map<DateTime, double> salesData = {};
    if (widget.salesHistory != null) {
      for (var entry in widget.salesHistory!.entries) {
        try {
          final date = DateTime.parse(entry.key);
          salesData[date] = entry.value;
        } catch (_) {}
      }
    }

    final labels  = xLabelsForRangeKey(context, widget.rangeKey);
    final primary = spotsFromSiteByKey(salesData, widget.rangeKey);
    final bounds  = yBounds(primary);

    // Calculate total sales
    final totalSales = salesData.values.fold<double>(0, (sum, value) => sum + value);

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))]),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(l.totalSales, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const Spacer(),
          _PillDropdown(
            value: widget.rangeKey,
            items: rangeKeys().map((k) => DropdownMenuItem(value: k, child: Text(rangeLabel(context, k)))).toList(),
            onChanged: (v) { if (v != null) widget.onRangeChanged(v); },
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Text(l.currencyAmount('AED', totalSales.toStringAsFixed(2)), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFE9F7EF), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.arrow_upward_rounded, size: 14, color: Colors.green),
              const SizedBox(width: 4),
              Text(l.percentTotalSales('0.0'), style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (labels.length - 1).toDouble(),
              minY: bounds.minY,
              maxY: bounds.maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 0.2,
                verticalInterval: 1,
                getDrawingHorizontalLine: (v) => const FlLine(color: Color(0xFFE9ECF2), strokeWidth: 1),
                getDrawingVerticalLine:   (v) => const FlLine(color: Color(0xFFE9ECF2), strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 46,
                    interval: 0.2,
                    getTitlesWidget: (v, _) => SizedBox(
                      width: 42,
                      child: Text('${v.toStringAsFixed(1)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(labels[i], style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                    );
                  },
                )),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: primary, isCurved: true, barWidth: 3, color: kPrimaryLine,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (s, p, bar, i) => FlDotCirclePainter(radius: 3.5, color: kPrimaryLine, strokeWidth: 2, strokeColor: Colors.white),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => Colors.white,
                  tooltipRoundedRadius: 10,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (spots) {
                    if (spots.isEmpty) return [];
                    final idx = spots.first.x.toInt().clamp(0, labels.length - 1);
                    return [LineTooltipItem('${labels[idx]}: ${spots.first.y.toStringAsFixed(2)}', const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700, fontSize: 12))];
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          _LegendSwatch(label: l.legendRangeYear('Current'), color: kPrimaryLine, solid: true),
        ]),
      ]),
    );
  }
}

class _PillDropdown extends StatelessWidget {
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  const _PillDropdown({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: Colors.white,
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  final String label;
  final Color color;
  final bool solid;
  final bool dimmed;
  const _LegendSwatch({required this.label, required this.color, this.solid = true, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    final paintColor = dimmed ? color.withOpacity(0.35) : color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 18, height: 4, child: CustomPaint(painter: _LinePainter(color: paintColor, dashed: !solid))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  final Color color;
  final bool dashed;
  _LinePainter({required this.color, required this.dashed});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (!dashed) {
      canvas.drawLine(Offset(0, size.height/2), Offset(size.width, size.height/2), p);
    } else {
      const dashWidth = 3.0, dashSpace = 2.0;
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, size.height/2), Offset(x + dashWidth, size.height/2), p);
        x += dashWidth + dashSpace;
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// =============================================================
/// Animated Donut (for “Total customers”)
/// =============================================================
class _CustomersCard extends StatefulWidget {
  final Map<String, int>? customerBreakdown;
  const _CustomersCard({this.customerBreakdown});

  @override
  State<_CustomersCard> createState() => _CustomersCardState();
}

class _CustomersCardState extends State<_CustomersCard> {
  // UI knobs (keep in sync with painter)
  final double _size = 170;
  final double _stroke = 18;

  int? _hovered; // null = nothing active
  late List<_DonutSegment> segments;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rebuildSegments(); // build once for initial paint
  }

  void _rebuildSegments() {
    final l = AppLocalizations.of(context)!;

    final oldC       = (widget.customerBreakdown?['old'] ?? 0).toDouble();
    final newC       = (widget.customerBreakdown?['new'] ?? 0).toDouble();
    final returningC = (widget.customerBreakdown?['returning'] ?? 0).toDouble();

    segments = [
      _DonutSegment(label: l.oldCustomer,       value: oldC,       color: const Color(0xFFB7A6FF)),
      _DonutSegment(label: l.newCustomer,       value: newC,       color: const Color(0xFFFFC879)),
      _DonutSegment(label: l.returningCustomer, value: returningC, color: const Color(0xFFFF96B5)),
    ];
  }

  @override
  void didUpdateWidget(covariant _CustomersCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customerBreakdown != widget.customerBreakdown) {
      _rebuildSegments();
    }
  }

  void _updateFromLocalPos(Offset local) {
    final idx = _hitTestDonut(
      localPos: local,
      size: Size(_size, _size),
      strokeWidth: _stroke,
      values: segments.map((e) => e.value).toList(),
    );
    if (idx != _hovered) setState(() => _hovered = idx);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context)!;

    final total = segments.fold<double>(0, (p, s) => p + s.value);
    final active = _hovered != null ? segments[_hovered!] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 210,
          child: Center(
            child: MouseRegion(
              onHover: (e) => _updateFromLocalPos(
                _localFromGlobal(context, e.position),
              ),
              onExit: (_) => setState(() => _hovered = null),
              child: GestureDetector(
                onTapDown: (e) => _updateFromLocalPos(e.localPosition),
                onPanDown: (e) => _updateFromLocalPos(e.localPosition),
                onPanUpdate: (e) => _updateFromLocalPos(e.localPosition),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedDonut(
                      values: segments.map((e) => e.value).toList(),
                      colors: segments.map((e) => e.color).toList(),
                      strokeWidth: _stroke + (_hovered != null ? 1.5 : 0),
                      size: _size,
                      highlightedIndex: _hovered,
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                    ),
                    if (active != null)
                      _FloatingInfoCard(
                        label: active.label,
                        valueText: _formatCount(active.value, total), // shows %
                        color: active.color,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 18, runSpacing: 8,
          children: [for (final seg in segments) _DotLegend(color: seg.color, label: seg.label)],
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: text.bodyMedium?.copyWith(color: const Color(0xFF111827)),
            children: [
              TextSpan(text: '${l.welcome} '),
              TextSpan(
                text: l.customersCount(total.toInt().toString()),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: ' ${l.withPersonalMessage} 🥳'),
            ],
          ),
        ),
      ],
    );
  }
}

/// Format percentage properly
String _formatCount(double part, double total) {
  if (total == 0) return '0%';
  final pct = (part / total * 100).toStringAsFixed(1);
  return '$pct%';
}

/// =============================================================
/// AOV section (kept simple)
/// =============================================================
class AOVSection extends StatelessWidget {
  final String rangeKey;
  final Map<String, double>? salesHistory;
  const AOVSection({super.key, required this.rangeKey, required this.salesHistory});

  Map<DateTime, double> _toDateMap(Map<String, double>? src) {
    final out = <DateTime, double>{};
    if (src == null) return out;
    for (final e in src.entries) {
      try {
        out[DateTime.parse(e.key)] = e.value;
      } catch (_) {}
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final data = _toDateMap(salesHistory);
    final labels = xLabelsForRangeKey(context, rangeKey);
    final series = spotsFromSiteByKey(data, rangeKey);
    final b = yBounds(series);
    final avg = (series.isEmpty)
        ? 0.0
        : series.map((s) => s.y).reduce((a, b) => a + b) / series.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(
            l.currencyAmount('AED', avg.toStringAsFixed(2)),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFE9F7EF), borderRadius: BorderRadius.circular(8)),
            child: Text(l.percentAov('+0.0'),
                style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minX: 0, maxX: (labels.length - 1).toDouble(),
              minY: b.minY, maxY: b.maxY,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 46,
                    interval: 0.2,
                    getTitlesWidget: (v, _) => SizedBox(
                      width: 42,
                      child: Text('${v.toStringAsFixed(1)}${l.millionsSuffix}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true, interval: 1,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(labels[i], style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                      );
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true, drawVerticalLine: true, horizontalInterval: 0.2, verticalInterval: 1,
                getDrawingHorizontalLine: (v) => const FlLine(color: Color(0xFFEDEEF2), strokeWidth: 1),
                getDrawingVerticalLine:   (v) => const FlLine(color: Color(0xFFEDEEF2), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: series, isCurved: true, barWidth: 3, color: kPrimaryLine,
                  dotData: const FlDotData(show: false),
                ),
              ],
              lineTouchData: const LineTouchData(enabled: true),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [ _LegendDot(label: l.averageOrderValue) ]),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  const _LegendDot({required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

/// =============================================================
/// Carousels
/// =============================================================
class ProductCarousel extends StatelessWidget {
  final List<ProductTileData> products;
  const ProductCarousel({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (products.isEmpty) return _EmptyStripe(message: l.noProductFound);

    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: products.length,
        itemBuilder: (context, i) => _ProductCard(item: products[i]),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductTileData item;
  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context)!;
    return Container(
      width: 180,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: item.thumb ?? Container(color: const Color(0xFFF3F4F6), child: const Icon(Icons.photo_outlined)),
            ),
          ),
          const SizedBox(height: 8),
          Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(l.currencyAmount('AED', item.price.toStringAsFixed(2)), style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(l.soldCount(item.sold.toString()), style: text.labelSmall?.copyWith(color: const Color(0xFF6B7280))),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryCarousel extends StatelessWidget {
  final List<CategoryTileData> categories;
  const CategoryCarousel({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (categories.isEmpty) return _EmptyStripe(message: l.noCategoryFound);

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: categories.length,
        itemBuilder: (context, i) => _CategoryCard(item: categories[i]),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryTileData item;
  const _CategoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context)!;
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)),
            child: item.icon ?? const Icon(Icons.category_outlined),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(l.itemsCount(item.items.toString()), style: text.labelMedium?.copyWith(color: const Color(0xFF6B7280))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStripe extends StatelessWidget {
  final String message;
  const _EmptyStripe({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(color: const Color(0xFFF6F7FB), borderRadius: BorderRadius.circular(10)),
      child: Text(message, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

/// =============================================================
/// Ratings triple
/// =============================================================
class RatingsPanel extends StatelessWidget {
  final Map<int, double> price;   // 5..1 -> percent 0..100
  final Map<int, double> value;
  final Map<int, double> quality;

  const RatingsPanel({super.key, required this.price, required this.value, required this.quality});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _ThreeUp(
      children: [
        _RatingCard(title: l.priceRating),
        _RatingCard(title: l.valueRating),
        _RatingCard(title: l.qualityRating),
      ],
      series: [price, value, quality],
    );
  }
}

class _ThreeUp extends StatelessWidget {
  final List<_RatingCard> children;
  final List<Map<int, double>> series;
  const _ThreeUp({required this.children, required this.series});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final is3 = c.maxWidth >= 900;
      final is2 = c.maxWidth >= 600;
      final cols = is3 ? 3 : (is2 ? 2 : 1);
      final width = (c.maxWidth - (cols - 1) * 16) / cols;

      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: List.generate(children.length, (i) {
          return SizedBox(width: width, child: _RatingCard(title: children[i].title, data: series[i]));
        }),
      );
    });
  }
}

class _RatingCard extends StatelessWidget {
  final String title;
  final Map<int, double>? data; // optional to allow default
  const _RatingCard({required this.title, this.data});

  @override
  Widget build(BuildContext context) {
    final d = data ?? {5:0,4:0,3:0,2:0,1:0};
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 12, offset: const Offset(0,6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        ...[5,4,3,2,1].map((star) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(children: [
            const Icon(Icons.star, size: 16, color: Color(0xFFF59E0B)),
            const SizedBox(width: 6),
            Text('$star', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (d[star] ?? 0) / 100.0,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFF3F4F6),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF97ADFF)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('${(d[star] ?? 0).toStringAsFixed(0)}%', style: const TextStyle(color: Color(0xFF6B7280))),
          ]),
        )),
      ]),
    );
  }
}

/// =============================================================
/// Modern Reviews list
/// =============================================================
class LatestReviewsList extends StatelessWidget {
  final List<Review> reviews;
  const LatestReviewsList({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const _EmptyReviewState();

    return Column(
      children: [
        for (final r in reviews) ...[
          _ModernReviewCard(r: r),
          const SizedBox(height: 16),
        ]
      ],
    );
  }
}

class _ModernReviewCard extends StatelessWidget {
  final Review r;
  const _ModernReviewCard({required this.r});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final l = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info and rating
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User avatar with gradient background
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    r.user.isNotEmpty
                        ? r.user.trim().split(RegExp(r'\s+')).map((w) => w[0]).take(2).join().toUpperCase()
                        : '?',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.user,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Star rating
                    Row(
                      children: [
                        Wrap(
                          children: List.generate(5, (i) => Icon(
                            i < r.rating ? Icons.star : Icons.star_border,
                            size: 16,
                            color: const Color(0xFFF59E0B),
                          )),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          r.timeAgo,
                          style: textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Product name if available
          if (r.product != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                r.product!,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Review comment
          Text(
            r.comment,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF374151),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Interactive buttons
          Row(
            children: [
              _InteractiveButton(
                icon: Icons.thumb_up_outlined,
                label: l.helpful,
                onPressed: () {},
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class _InteractiveButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _InteractiveButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6B7280)),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _EmptyReviewState extends StatelessWidget {
  const _EmptyReviewState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// =============================================================
/// Simple responsive 2-up grid
/// =============================================================
class _TwoUpGrid extends StatelessWidget {
  final List<Widget> children;
  const _TwoUpGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isTwo = c.maxWidth >= 660; // split when there’s room
        final itemWidth = isTwo ? (c.maxWidth - 16) / 2 : c.maxWidth;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: children.map((w) => SizedBox(width: itemWidth, child: w)).toList(),
        );
      },
    );
  }
}

/// =============================================================
/// Donut plumbing: model + painter + helpers
/// =============================================================
class _DonutSegment {
  final String label;
  final double value;
  final Color color;
  const _DonutSegment({required this.label, required this.value, required this.color});
}

/// Converts a global position into the local coordinates of [context].
Offset _localFromGlobal(BuildContext context, Offset global) {
  final box = context.findRenderObject() as RenderBox?;
  if (box == null) return Offset.zero;
  return box.globalToLocal(global);
}

/// Hit-test which donut slice is under [localPos].
/// Returns the segment index or null if outside of the ring.
int? _hitTestDonut({
  required Offset localPos,
  required Size size,
  required double strokeWidth,
  required List<double> values,
}) {
  if (values.isEmpty) return null;

  final center = Offset(size.width / 2, size.height / 2);
  final dx = localPos.dx - center.dx;
  final dy = localPos.dy - center.dy;
  final r = (size.shortestSide / 2);

  final outerR2 = r * r;
  final innerR = r - strokeWidth;
  final innerR2 = innerR * innerR;

  final dist2 = dx * dx + dy * dy;
  if (dist2 < innerR2 || dist2 > outerR2) return null;

  var angle = atan2(dy, dx);
  if (angle < 0) angle += 2 * pi;

  final total = values.fold<double>(0, (p, v) => p + (v.isFinite ? v : 0));
  if (total <= 0) return null;

  double acc = 0.0;
  for (int i = 0; i < values.length; i++) {
    final sweep = (values[i] / total) * 2 * pi;
    final start = acc;
    final end = acc + sweep;
    if (angle >= start && angle < end) return i;
    acc = end;
  }
  return values.isNotEmpty ? values.length - 1 : null;
}

/// Animated donut that paints proportions of [values] with [colors].
class AnimatedDonut extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;
  final double size;
  final int? highlightedIndex;
  final Duration duration;
  final Curve curve;

  const AnimatedDonut({
    super.key,
    required this.values,
    required this.colors,
    required this.strokeWidth,
    required this.size,
    this.highlightedIndex,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      builder: (context, t, _) {
        return CustomPaint(
          size: Size.square(size),
          painter: _DonutPainter(
            values: values,
            colors: colors,
            strokeWidth: strokeWidth,
            highlightedIndex: highlightedIndex,
            t: t,
          ),
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;
  final int? highlightedIndex;
  final double t; // 0..1 animation progress

  _DonutPainter({
    required this.values,
    required this.colors,
    required this.strokeWidth,
    required this.highlightedIndex,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (p, v) => p + (v.isFinite ? v : 0));
    if (total <= 0) return;

    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double acc = -pi / 2; // start at top
    for (int i = 0; i < values.length; i++) {
      final frac = (values[i] / total);
      final sweep = frac * 2 * pi * t;
      if (sweep <= 0) continue;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = (i == highlightedIndex) ? (strokeWidth + 1.5) : strokeWidth;

      canvas.drawArc(rect, acc, sweep, false, paint);
      acc += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) {
    return old.values != values ||
        old.colors != colors ||
        old.strokeWidth != strokeWidth ||
        old.highlightedIndex != highlightedIndex ||
        old.t != t;
  }
}

class _FloatingInfoCard extends StatelessWidget {
  final String label;
  final String valueText;
  final Color color;
  const _FloatingInfoCard({required this.label, required this.valueText, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text(valueText, style: const TextStyle(color: Color(0xFF6B7280))),
        ],
      ),
    );
  }
}

class _DotLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _DotLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Color(0xFF374151))),
      ],
    );
  }
}