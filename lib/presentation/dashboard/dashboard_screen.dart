import 'dart:math' show min, max, pi, atan2;
import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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
/// Example website-like data holder (plug your API here)
/// =============================================================
class WebsiteSeries {
  final Map<DateTime, double> totalSales; // AED in millions for the “m” ticks
  final Map<DateTime, double> aov;

  WebsiteSeries({
    required this.totalSales,
    required this.aov,
  });

  factory WebsiteSeries.flat({
    required DateTime start,
    required int days,
    double sales = 8.2, // “8.2m”
    double aov = 0.0,
  }) {
    final s = <DateTime, double>{};
    final v = <DateTime, double>{};
    for (var i = 0; i < days; i++) {
      final d = DateTime(start.year, start.month, start.day).add(Duration(days: i));
      s[d] = sales;
      v[d] = aov;
    }
    return WebsiteSeries(totalSales: s, aov: v);
  }
}

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
    // anchor ticks the same as before
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
  String _salesRangeKey = kRangeAll;
  String _aovRangeKey   = kRangeAll;
  String? _userName;

  final WebsiteSeries site = WebsiteSeries.flat(
    start: DateTime.now().subtract(const Duration(days: 60)),
    days: 90,
    sales: 8.2,
    aov: 0.0,
  );

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                      top: 0,
                      left: 0,
                      right: 0,
                      height: kHeaderHeight,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: kHeaderColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                          ),
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
                    const Positioned(
                      top: kHeaderHeight - kStatOverlap + 4,
                      left: 0, right: 0,
                      child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: _StatRow()),
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
                      data: site.totalSales,
                      compareData: site.totalSales,
                    ),
                    const SizedBox(height: 20),

                    // Customers donut + AOV
                    _TwoUpGrid(children: [
                      SectionCard(
                        title: l10n.totalCustomers,
                        child: const _CustomersCard(),
                      ),
                      SectionCard(
                        title: l10n.averageOrderValue,
                        child: AOVSection(rangeKey: _aovRangeKey, siteAov: site.aov),
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
                        child: ProductCarousel(products: [
                          ProductTileData(
                            name: 'Wireless Headphones Pro 300',
                            price: 249.00, sold: 132,
                            thumb: Image.network('https://picsum.photos/seed/hdph/320/200', fit: BoxFit.cover),
                          ),
                          ProductTileData(
                            name: 'Smartwatch Lite',
                            price: 99.00, sold: 98,
                            thumb: Image.network('https://picsum.photos/seed/watch/320/200', fit: BoxFit.cover),
                          ),
                          ProductTileData(
                            name: '4K Action Camera',
                            price: 179.99, sold: 76,
                            thumb: Image.network('https://picsum.photos/seed/cam/320/200', fit: BoxFit.cover),
                          ),
                          ProductTileData(
                            name: 'USB-C Charging Cable 2m',
                            price: 12.49, sold: 240,
                            thumb: Image.network('https://picsum.photos/seed/cable/320/200', fit: BoxFit.cover),
                          ),
                        ]),
                      ),
                      SectionCard(
                        title: l10n.topCategories,
                        child: CategoryCarousel(categories: [
                          CategoryTileData(name: l10n.catHeadphones, items: 42, icon: const Icon(Icons.headphones_outlined)),
                          CategoryTileData(name: l10n.catWatches,     items: 18, icon: const Icon(Icons.watch_outlined)),
                          CategoryTileData(name: l10n.catCameras,     items: 26, icon: const Icon(Icons.photo_camera_outlined)),
                          CategoryTileData(name: l10n.catAccessories, items: 120, icon: const Icon(Icons.extension_outlined)),
                        ]),
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Ratings
                    SectionCard(
                      title: l10n.ratings,
                      child: RatingsPanel(
                        price:  const {5:12,4:18,3:32,2:21,1:17},
                        value:  const {5:15,4:20,3:30,2:20,1:15},
                        quality:const {5:10,4:25,3:30,2:25,1:10},
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Reviews
                    SectionCard(
                      title: l10n.latestCommentsReviews,
                      child: LatestReviewsList(reviews: [
                        Review(
                          user: 'Courtney Henry',
                          rating: 5, timeAgo: '2h',
                          product: 'Wireless Headphones Pro 300',
                          comment: l10n.r1,
                        ),
                        Review(
                          user: 'Jenny Wilson',
                          rating: 4, timeAgo: '1d',
                          product: 'Smartwatch Lite',
                          comment: l10n.r2,
                        ),
                      ]),
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

  Future<void> _loadUserName() async {
    try {
      final customerInfo = await ApiClient().getCustomerInfo();

      if (customerInfo != null) {
        final firstName = customerInfo['firstname'] ?? '';
        final lastName = customerInfo['lastname'] ?? ''; // FIXED: lowercase 'l'
        final email = customerInfo['email'] ?? '';

        setState(() {
          _userName = '$firstName $lastName'.trim(); // FIXED: lowercase 'l'
          if (_userName!.isEmpty) _userName = email;
        });
      } else {
        setState(() {
          _userName = 'Guest';
        });
      }
    } catch (e) {
      print('Error loading user name: $e');
      setState(() {
        _userName = 'Guest';
      });
    }
  }
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

/// Animated painter-based donut with round caps & smooth motion.
class AnimatedDonut extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;
  final double size;
  final Duration duration;
  final Curve curve;
  final int? highlightedIndex;

  const AnimatedDonut({
    super.key,
    required this.values,
    required this.colors,
    this.strokeWidth = 16,
    this.size = 160,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOut,
    this.highlightedIndex,
  }) : assert(values.length == colors.length);

  @override
  Widget build(BuildContext context) {
    final total = values.fold<double>(0, (p, c) => p + c);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: curve,
      builder: (_, t, __) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _DonutPainter(
              t: t,
              values: values,
              colors: colors,
              total: total == 0 ? 1 : total,
              strokeWidth: strokeWidth,
              highlightedIndex: highlightedIndex,
            ),
          ),
        );
      },
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double t; // 0..1 animation progress
  final List<double> values;
  final List<Color> colors;
  final double total;
  final double strokeWidth;
  final int? highlightedIndex;

  _DonutPainter({
    required this.t,
    required this.values,
    required this.colors,
    required this.total,
    required this.strokeWidth,
    required this.highlightedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2 - strokeWidth / 2;

    // tiny spin-in for a bit of delight
    canvas.translate(center.dx, center.dy);
    canvas.rotate((1 - t) * 0.25);
    canvas.translate(-center.dx, -center.dy);

    // background track
    final bg = Paint()
      ..color = const Color(0xFFF1F3F8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0, 2 * pi, false, bg);

    double start = -pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi * t;
      if (sweep <= 0) continue;

      final p = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + (i == highlightedIndex ? 2.5 : 0) // subtle hover/tap highlight
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, p);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.t != t ||
          old.values != values ||
          old.colors != colors ||
          old.strokeWidth != strokeWidth ||
          old.highlightedIndex != highlightedIndex;
}

/// =============================================================
/// Small stat row
/// =============================================================
class _StatRow extends StatelessWidget {
  const _StatRow();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SizedBox(
      height: kStatCardHeight + 4,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _MiniStatCard(
            iconPath: 'assets/icons/payments_outlined.png',
            label: l.revenue,
            value: l.currencyAmount('AED', '500'),
            delta: '+50% ${l.lastWeek}',
            deltaColor: Colors.green,
          ),
          const SizedBox(width: 12),
          _MiniStatCard(
            iconPath: 'assets/icons/shopping_bag_outlined.png',
            label: l.orders,
            value: '100',
            delta: '-50% ${l.lastWeek}',
            deltaColor: Colors.red,
          ),
          const SizedBox(width: 12),
          _MiniStatCard(
            iconPath: 'assets/icons/people_alt_outlined.png',
            label: l.customers,
            value: '562',
            delta: '+20% ${l.lastWeek}',
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
  final Map<DateTime, double> data;
  final Map<DateTime, double>? compareData;

  const TotalSalesCard({
    super.key,
    required this.rangeKey,
    required this.onRangeChanged,
    required this.data,
    this.compareData,
  });

  @override
  State<TotalSalesCard> createState() => _TotalSalesCardState();
}

class _TotalSalesCardState extends State<TotalSalesCard> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final labels  = xLabelsForRangeKey(context, widget.rangeKey);
    final primary = spotsFromSiteByKey(widget.data, widget.rangeKey);
    final compare = widget.compareData != null ? spotsFromSiteByKey(widget.compareData!, widget.rangeKey) : <FlSpot>[];
    final bounds  = yBounds(primary, compare.isEmpty ? null : compare);

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
          Text(l.currencyAmount('AED', '0.00'), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFE9F7EF), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.arrow_upward_rounded, size: 14, color: Colors.green),
              const SizedBox(width: 4),
              Text(l.percentTotalSales('37.8'), style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
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
                      child: Text('${v.toStringAsFixed(1)}${AppLocalizations.of(context)!.millionsSuffix}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
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
                if (compare.isNotEmpty)
                  LineChartBarData(
                    spots: compare, isCurved: true, barWidth: 2,
                    color: kCompareLine.withOpacity(0.45),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (s, p, bar, i) => FlDotCirclePainter(radius: 2.5, color: kCompareLine.withOpacity(0.9), strokeColor: Colors.white, strokeWidth: 1),
                    ),
                  ),
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
                    return [LineTooltipItem(labels[idx], const TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w700, fontSize: 12))];
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          _LegendSwatch(label: l.legendRangeYear('2022'), color: kPrimaryLine, solid: true),
          const SizedBox(width: 18),
          _LegendSwatch(label: l.legendRangeYear('2023'), color: kCompareLine, solid: false, dimmed: true),
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
  const _CustomersCard();

  @override
  State<_CustomersCard> createState() => _CustomersCardState();
}

class _CustomersCardState extends State<_CustomersCard> {
  // Order matters (arc order)
  late final List<_DonutSegment> segments;

  // UI knobs (keep in sync with painter)
  final double _size = 170;
  final double _stroke = 18;

  int? _hovered; // null = nothing active

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l = AppLocalizations.of(context)!;
    segments = [
      _DonutSegment(label: l.oldCustomer,       value: 65, color: const Color(0xFFB7A6FF)), // purple
      _DonutSegment(label: l.newCustomer,       value: 25, color: const Color(0xFFFFC879)), // peach
      _DonutSegment(label: l.returningCustomer, value: 10, color: const Color(0xFFFF96B5)), // pink
    ];
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
                _localFromGlobal(context, e.position, boxSize: Size(_size, _size)),
              ),
              onExit: (_) => setState(() => _hovered = null),
              child: GestureDetector(
                onTapDown: (e) => _updateFromLocalPos(e.localPosition),
                onPanDown: (e) => _updateFromLocalPos(e.localPosition),
                onPanUpdate: (e) => _updateFromLocalPos(e.localPosition),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Donut itself (highlight the hovered slice a bit thicker)
                    AnimatedDonut(
                      values: segments.map((e) => e.value).toList(),
                      colors: segments.map((e) => e.color).toList(),
                      strokeWidth: _stroke + (_hovered != null ? 1.5 : 0),
                      size: _size,
                      highlightedIndex: _hovered,
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                    ),

                    // Floating info card
                    if (active != null)
                      _FloatingInfoCard(
                        label: active.label,
                        valueText: _formatCount(active.value, total),
                        color: active.color,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Legends
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: [
            _DotLegend(color: segments[1].color, label: segments[1].label), // New
            _DotLegend(color: segments[2].color, label: segments[2].label), // Returning
          ],
        ),

        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: text.bodyMedium?.copyWith(color: const Color(0xFF111827)),
            children: [
              TextSpan(text: '${l.welcome} '),
              TextSpan(text: l.customersCount('291'), style: const TextStyle(fontWeight: FontWeight.w700)),
              TextSpan(text: ' ${l.withPersonalMessage} 🥳'),
            ],
          ),
        ),
      ],
    );
  }
}

class _FloatingInfoCard extends StatelessWidget {
  final String label;
  final String valueText;
  final Color color;

  const _FloatingInfoCard({
    required this.label,
    required this.valueText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      elevation: 16,
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: text.labelLarge?.copyWith(color: const Color(0xFF6B7280))),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 8),
                Text(valueText, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Offset _localFromGlobal(BuildContext context, Offset global, {required Size boxSize}) {
  final box = context.findRenderObject() as RenderBox?;
  if (box == null) return Offset.zero;
  final localTopLeft = box.globalToLocal(global);
  final origin = Offset((box.size.width - boxSize.width) / 2, (box.size.height - boxSize.height) / 2);
  return localTopLeft - origin;
}

int? _hitTestDonut({
  required Offset localPos,
  required Size size,
  required double strokeWidth,
  required List<double> values,
}) {
  final total = values.fold<double>(0, (p, v) => p + v);
  if (total <= 0) return null;

  final center = Offset(size.width / 2, size.height / 2);
  final r = size.width / 2;
  final innerR = r - strokeWidth;
  final d = (localPos - center).distance;

  if (d < innerR || d > r) return null;

  double ang = atan2(localPos.dy - center.dy, localPos.dx - center.dx);
  ang = (ang + 2 * pi) % (2 * pi);
  ang = (ang + pi / 2) % (2 * pi);

  double acc = 0;
  for (var i = 0; i < values.length; i++) {
    final sweep = (values[i] / total) * 2 * pi;
    if (ang >= acc && ang < acc + sweep) return i;
    acc += sweep;
  }
  return values.isEmpty ? null : values.length - 1;
}

String _formatCount(double part, double total) {
  final pct = total == 0 ? 0 : part / total;
  final approx = (pct * 100000).round();
  if (approx >= 1000) return '${(approx / 1000).round()}k';
  return approx.toString();
}

class _DonutSegment {
  final String label;
  final double value;
  final Color color;
  const _DonutSegment({required this.label, required this.value, required this.color});
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
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF6B7280))),
      ],
    );
  }
}

/// =============================================================
/// AOV section (kept simple)
/// =============================================================
class AOVSection extends StatelessWidget {
  final String rangeKey;
  final Map<DateTime, double> siteAov;
  const AOVSection({super.key, required this.rangeKey, required this.siteAov});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final labels = xLabelsForRangeKey(context, rangeKey);
    final series = spotsFromSiteByKey(siteAov, rangeKey);
    final b = yBounds(series);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(l.currencyAmount('AED', '0.00'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFE9F7EF), borderRadius: BorderRadius.circular(8)),
            child: Text(l.percentAov('+37.8'), style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
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
                      child: Text('${v.toStringAsFixed(1)}${l.millionsSuffix}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 0.2,
                verticalInterval: 1,
                getDrawingHorizontalLine: (v) => const FlLine(color: Color(0xFFEDEEF2), strokeWidth: 1),
                getDrawingVerticalLine:   (v) => const FlLine(color: Color(0xFFEDEEF2), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(spots: series, isCurved: true, barWidth: 3, color: kPrimaryLine, dotData: const FlDotData(show: false)),
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
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 14
                    ),
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
                          style: textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280)),
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

  const _InteractiveButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

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
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7280)),
          ),
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