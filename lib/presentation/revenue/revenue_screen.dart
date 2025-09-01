import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  // Pagination for history
  static const int _pageSize = 2;
  int _shown = _pageSize;
  bool _isLoading = false;

  // History dummy data
  final List<Map<String, String>> _historyData = [
    {
      'interval': 'From 15 / 11 to 01 / 25',
      'orderId': '12345',
      'totalAmount': '\$7,750.88',
      'totalEarning': '\$7,750.88',
      'discount': '20%',
      'commission': '\$7,750.88',
    },
    {
      'interval': 'From 15 / 11 to 01 / 25',
      'orderId': '12346',
      'totalAmount': '\$6,120.20',
      'totalEarning': '\$6,120.20',
      'discount': '10%',
      'commission': '\$820.00',
    },
    {
      'interval': 'From 15 / 11 to 01 / 25',
      'orderId': '12347',
      'totalAmount': '\$5,010.90',
      'totalEarning': '\$5,010.90',
      'discount': '0%',
      'commission': '\$610.00',
    },
  ];

  Future<void> _loadMore() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // fake delay for loading
    setState(() {
      _shown = (_shown + _pageSize).clamp(0, _historyData.length);
      _isLoading = false;
    });
  }

  // ----- FILTER + CHART DATA -----
  final List<String> _filters = ['allTime', 'last7Days', 'last30Days', 'thisYear'];
  late String _selectedFilter = _filters.first;

  List<ChartData> _dataAllTime = const [
    ChartData('Jan', 8.2, 50),
    ChartData('Feb', 8.4, 70),
    ChartData('Mar', 8.3, 60),
    ChartData('Apr', 8.1, 40),
    ChartData('May', 8.7, 120),
    ChartData('Jun', 8.3, 55),
  ];

  List<ChartData> _getFilteredData() {
    switch (_selectedFilter) {
      case 'last7Days':
        return const [
          ChartData('Mon', 5.0, 20),
          ChartData('Tue', 6.2, 30),
          ChartData('Wed', 4.8, 25),
          ChartData('Thu', 7.0, 40),
          ChartData('Fri', 6.5, 35),
          ChartData('Sat', 8.0, 45),
          ChartData('Sun', 7.2, 38),
        ];
      case 'last30Days':
        return List.generate(
          30,
              (i) => ChartData('D${i + 1}', (5 + (i % 4)).toDouble(), 20 + (i % 10)),
        );
      case 'thisYear':
        return const [
          ChartData('Jan', 8.2, 50),
          ChartData('Feb', 8.4, 70),
          ChartData('Mar', 8.3, 60),
          ChartData('Apr', 8.1, 40),
          ChartData('May', 8.7, 120),
          ChartData('Jun', 8.3, 55),
          ChartData('Jul', 8.9, 90),
          ChartData('Aug', 7.9, 65),
          ChartData('Sep', 8.6, 110),
          ChartData('Oct', 8.4, 95),
          ChartData('Nov', 8.2, 70),
          ChartData('Dec', 8.8, 130),
        ];
      default:
        return _dataAllTime;
    }
  }

  // ----- DOWNLOAD (no plugin) -----
  final GlobalKey _chartKey = GlobalKey();

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
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List bytes = byteData!.buffer.asUint8List();
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

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title
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

            // Metrics
            _buildMetricCard(
              label: l10n.earning,
              value: '\$128k',
              change: l10n.positiveChangeThisWeek(37.8),
              isPositive: true,
              iconPath: 'assets/icons/trending_up.png',
              backgroundColor: const Color(0xFFD6F6E6),
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              label: l10n.balance,
              value: '\$512.64',
              change: l10n.negativeChangeThisWeek(37.8),
              isPositive: false,
              iconPath: 'assets/icons/balance.png',
              backgroundColor: const Color(0xFFFFE7D1),
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              label: l10n.totalValueOfSales,
              value: '\$64k',
              change: l10n.positiveChangeThisWeek(37.8),
              isPositive: true,
              iconPath: 'assets/icons/cart.png',
              backgroundColor: const Color(0xFFD0E0FF),
            ),

            const SizedBox(height: 24),

            // Product views card
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
                      // inside your Row with filter + download
                      Row(
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(
                              dropdownMenuTheme: DropdownMenuThemeData(
                                menuStyle: MenuStyle(
                                  backgroundColor: WidgetStateProperty.all(Colors.white), // white menu
                                  elevation: WidgetStateProperty.all(8), // shadow
                                  shape: WidgetStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12), // rounded
                                    ),
                                  ),
                                  side: WidgetStateProperty.all(BorderSide.none), // no border
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
                                  dropdownColor: Colors.white, // just in case
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
                                  onChanged: (v) => setState(() {
                                    _selectedFilter = v!;
                                  }),
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

                  // Chart wrapped with RepaintBoundary for export
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
                            dataSource: _getFilteredData(),
                            xValueMapper: (ChartData d, _) => d.x,
                            yValueMapper: (ChartData d, _) => d.y1,
                            name: l10n.lifetimeValue,
                            color: const Color(0xFF4285F4),
                            width: 0.6,
                            spacing: 0.1,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          ColumnSeries<ChartData, String>(
                            dataSource: _getFilteredData(),
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

            // Earning History Card
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
                        isLoading: _isLoading,
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

  // ----- UI helpers -----
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
}

// Custom Load More Button
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