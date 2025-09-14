import 'dart:io';
import 'dart:ui' as ui;
import 'package:kolshy_vendor/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../services/api_client.dart';
enum _Period { day, month }
class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  static const double _COMMISSION_RATE = 0.0;

  static const int _pageSize = 10;
  int _shown = 0;
  bool _isLoadingMore = false;

  final List<String> _filters = ['allTime', 'last7Days', 'last30Days', 'thisYear'];
  late String _selectedFilter = _filters.first;

  List<ChartData> _chartData = const [];
  final GlobalKey _chartKey = GlobalKey();
  bool _isInitLoading = true;
  String? _loadError;


  double _totalRevenue = 0.0;
  double _balance = 0.0;
  double _totalSalesValue = 0.0;



  final List<Map<String, String>> _historyData = [];

  final Map<String, List<ChartData>> _chartCacheByFilter = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isInitLoading = true;
      _loadError = null;
      _historyData.clear();
      _totalRevenue = 0.0;
      _totalSalesValue = 0.0;
      _balance = 0.0;
      _chartData = const [];
      _shown = 0;
    });

    try {
      final orders = await VendorApiClient().getOrdersAdmin(
        pageSize: 200,
      );

      double grandTotalSum = 0.0;
      double discountSum = 0.0;

      final dfDate = DateFormat('dd / MM / yyyy');
      for (final o in orders) {
        final createdAtStr = (o['created_at'] as String?) ?? '';
        DateTime? createdAt;
        try {
          createdAt = DateTime.tryParse(createdAtStr)?.toLocal();
        } catch (_) {
          createdAt = null;
        }

        final intervalLabel =
        createdAt != null ? 'From ${dfDate.format(createdAt)} to ${dfDate.format(createdAt)}' : '—';

        final orderId = (o['increment_id']?.toString() ?? o['entity_id']?.toString() ?? '—');

        final grandTotal = (o['grand_total'] as num?)?.toDouble() ?? 0.0;
        final discountAmount = (o['discount_amount'] as num?)?.toDouble() ?? 0.0;

        grandTotalSum += grandTotal;
        discountSum += discountAmount;

        final commission = grandTotal * _COMMISSION_RATE;

        _historyData.add({
          'interval': intervalLabel,
          'orderId': orderId,
          'totalAmount': _fmtCurrency(grandTotal),
          'totalEarning': _fmtCurrency(grandTotal - commission),
          'discount': _fmtPercentFromAbs(discountAmount, base: grandTotal),
          'commission': _fmtCurrency(commission),
        });
      }

      _totalRevenue = grandTotalSum;
      _totalSalesValue = grandTotalSum;
      _balance = _totalRevenue - (_totalRevenue * _COMMISSION_RATE);

      _chartCacheByFilter['allTime'] = _buildChartFromOrders(orders, period: _Period.month);
      _chartCacheByFilter['last7Days'] =
          _buildChartFromOrders(await _fetchOrdersForLast(days: 7), period: _Period.day);
      _chartCacheByFilter['last30Days'] =
          _buildChartFromOrders(await _fetchOrdersForLast(days: 30), period: _Period.day);
      _chartCacheByFilter['thisYear'] =
          _buildChartFromOrders(await _fetchOrdersForThisYear(), period: _Period.month);
      _chartData = _chartCacheByFilter[_selectedFilter] ?? const [];
      _shown = _historyData.isEmpty ? 0 : (_historyData.length >= _pageSize ? _pageSize : _historyData.length);
    } on DioException catch (e) {
      _loadError = VendorApiClient().parseMagentoError(e);
    } catch (e) {
      _loadError = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isInitLoading = false);
      }
    }
  }

  List<ChartData> _buildChartFromOrders(List<Map<String, dynamic>> orders, {required _Period period}) {
    final Map<String, _Agg> buckets = {}; // key -> Agg
    for (final o in orders) {
      final createdAtStr = (o['created_at'] as String?) ?? '';
      final created = DateTime.tryParse(createdAtStr)?.toLocal();
      if (created == null) continue;

      final key = period == _Period.day
          ? DateFormat('MMM d').format(created)
          : DateFormat('MMM').format(DateTime(created.year, created.month));

      final grandTotal = (o['grand_total'] as num?)?.toDouble() ?? 0.0;
      final discount = (o['discount_amount'] as num?)?.toDouble() ?? 0.0;

      buckets.putIfAbsent(key, () => _Agg());
      buckets[key]!.revenue += grandTotal;
      buckets[key]!.cost += discount.abs();
    }

    final keys = buckets.keys.toList();
    keys.sort((a, b) => _syntheticKeyOrder(a).compareTo(_syntheticKeyOrder(b)));

    return keys
        .map((k) => ChartData(k, buckets[k]!.revenue, buckets[k]!.cost))
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> _fetchOrdersForLast({required int days}) async {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: days));
    return VendorApiClient().getVendorOrders(
      dateFrom: from,
      dateTo: now,
      pageSize: 200,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchOrdersForThisYear() async {
    final now = DateTime.now();
    final from = DateTime(now.year, 1, 1);
    final to = DateTime(now.year, 12, 31, 23, 59, 59);
    return VendorApiClient().getOrdersAdmin(
      dateFrom: from,
      dateTo: to,
      pageSize: 500,
    );
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _shown = (_shown + _pageSize).clamp(0, _historyData.length);
      _isLoadingMore = false;
    });
  }

  Future<void> _downloadChart() async {
    await Future.delayed(Duration.zero);
    final l10n = AppLocalizations.of(context)!;
    try {
      final boundary = _chartKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.chartNotReady)),
        );
        return;
      }
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/product_views_chart.png');
      await file.writeAsBytes(bytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.exportedTo} ${file.path}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.failedToExport} $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visible = _historyData.take(_shown).toList();
    final canLoadMore = _shown < _historyData.length;

    String getFilterText(String filterKey) {
      switch (filterKey) {
        case 'allTime':
          return l10n.allTime;
        case 'last7Days':
          return l10n.last7Days;
        case 'last30Days':
          return l10n.last30Days;
        case 'thisYear':
          return l10n.thisYear;
        default:
          return '';
      }
    }

    void onFilterChanged(String v) {
      setState(() {
        _selectedFilter = v;
        _chartData = _chartCacheByFilter[_selectedFilter] ?? const [];
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _isInitLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _loadError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.earning,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 20),
            _buildMetricCard(
              label: l10n.earning,
              value: _fmtCurrency(_totalRevenue),
              change: l10n.positiveChangeThisWeek(0),
              isPositive: true,
              iconPath: 'assets/icons/trending_up.png',
              backgroundColor: const Color(0xFFD6F6E6),
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              label: l10n.balance,
              value: _fmtCurrency(_balance),
              change: l10n.negativeChangeThisWeek(0),
              isPositive: _balance >= 0,
              iconPath: 'assets/icons/balance.png',
              backgroundColor: const Color(0xFFFFE7D1),
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              label: l10n.totalValueOfSales,
              value: _fmtCurrency(_totalSalesValue),
              change: l10n.positiveChangeThisWeek(0),
              isPositive: true,
              iconPath: 'assets/icons/cart.png',
              backgroundColor: const Color(0xFFD0E0FF),
            ),

            const SizedBox(height: 24),
            Container(
              decoration: _boxDecoration(),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with title + filter + download
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.productViews,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(
                              dropdownMenuTheme: DropdownMenuThemeData(
                                menuStyle: MenuStyle(
                                  backgroundColor: WidgetStateProperty.all(Colors.white),
                                  elevation: WidgetStateProperty.all(8),
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  side: WidgetStateProperty.all(BorderSide.none),
                                ),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F3F4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedFilter,
                                  borderRadius: BorderRadius.circular(12),
                                  dropdownColor: Colors.white,
                                  items: _filters
                                      .map(
                                        (f) => DropdownMenuItem(
                                      value: f,
                                      child: Text(
                                        getFilterText(f),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  )
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) onFilterChanged(v);
                                  },
                                  icon: const Icon(Icons.expand_more),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Download button
                          IconButton(
                            onPressed: _downloadChart,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(const Color(0xFFF3F3F4)),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            icon: const Icon(Icons.download_rounded, color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RepaintBoundary(
                    key: _chartKey,
                    child: SizedBox(
                      height: 220,
                      child: SfCartesianChart(
                        margin: EdgeInsets.zero,
                        primaryXAxis: CategoryAxis(
                          majorGridLines: const MajorGridLines(width: 0),
                          axisLine: const AxisLine(width: 0),
                          labelStyle: const TextStyle(fontSize: 12),
                        ),
                        primaryYAxis: NumericAxis(
                          majorGridLines: const MajorGridLines(
                            width: 1,
                            color: Color(0x11000000),
                          ),
                          axisLine: const AxisLine(width: 0),
                          labelStyle: const TextStyle(fontSize: 12),
                          numberFormat: NumberFormat.compactCurrency(
                            decimalDigits: 0,
                            symbol: '\$',
                          ),
                        ),
                        series: <CartesianSeries<ChartData, String>>[
                          ColumnSeries<ChartData, String>(
                            dataSource: _chartData,
                            xValueMapper: (ChartData d, _) => d.x,
                            yValueMapper: (ChartData d, _) => d.y1,
                            name: l10n.lifetimeValue,
                            color: const Color(0xFF4285F4),
                            width: 0.6,
                            spacing: 0.1,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          ColumnSeries<ChartData, String>(
                            dataSource: _chartData,
                            xValueMapper: (ChartData d, _) => d.x,
                            yValueMapper: (ChartData d, _) => d.y2,
                            name: l10n.customerCost,
                            color: const Color(0xFFFBBC05),
                            width: 0.6,
                            spacing: 0.1,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                        legend: Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                          textStyle: const TextStyle(fontSize: 12),
                          overflowMode: LegendItemOverflowMode.wrap,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Container(
              decoration: _boxDecoration(),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.earningHistory,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...visible.map((item) => _buildHistoryItem(item, l10n)),
                  const SizedBox(height: 12),

                  if (_historyData.isNotEmpty && canLoadMore)
                    Center(
                      child: _LoadMoreButton(
                        onPressed: _loadMore,
                        isLoading: _isLoadingMore,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 20,
        offset: Offset(0, 10),
      ),
    ],
  );

  Widget _buildHistoryItem(Map<String, String> item, AppLocalizations l10n) {
    return Column(
      children: [
        _buildHistoryRow(l10n.interval, item['interval']!),
        _buildHistoryRow(l10n.orderId, item['orderId']!),
        _buildHistoryRow(l10n.totalAmount, item['totalAmount']!),
        _buildHistoryRow(l10n.totalEarning, item['totalEarning']!),
        _buildHistoryRow(l10n.discountAmount, item['discount']!),
        _buildHistoryRow(l10n.adminCommission, item['commission']!),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1, thickness: 1, color: Color(0x11000000)),
        ),
      ],
    );
  }

  Widget _buildHistoryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.black.withOpacity(0.65), fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String change,
    required bool isPositive,
    required String iconPath,
    required Color backgroundColor,
  }) {
    return Container(
      decoration: _boxDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 14)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(iconPath, width: 20, height: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? const Color(0xFF34A853) : const Color(0xFFEA4335),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  color: isPositive ? const Color(0xFF34A853) : const Color(0xFFEA4335),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtCurrency(num v) => NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(v);

  String _fmtPercentFromAbs(double discountAbs, {required double base}) {
    if (base <= 0) return '0%';
    final pct = (discountAbs.abs() / base) * 100.0;
    return '${pct.toStringAsFixed(0)}%';
  }

  int _syntheticKeyOrder(String key) {
    try {
      final dt = DateFormat('MMM d').parse(key);
      return dt.month * 100 + dt.day;
    } catch (_) {}
    try {
      final dt = DateFormat('MMM').parse(key);
      return dt.month * 100;
    } catch (_) {}
    return key.hashCode;
  }
}

class _Agg {
  double revenue = 0.0;
  double cost = 0.0;
}

class _LoadMoreButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const _LoadMoreButton({
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.black.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Image.asset(
                'assets/icons/loading.png',
                width: 18,
                height: 18,
              ),
            const SizedBox(width: 10),
            Text(
              isLoading ? l10n.loading : l10n.loadMore,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  const ChartData(this.x, this.y1, this.y2);
  final String x;
  final double y1;
  final double y2;
}