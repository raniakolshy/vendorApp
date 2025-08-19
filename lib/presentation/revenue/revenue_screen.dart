import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  // Pagination variables
  static const int _pageSize = 2;
  int _shown = _pageSize;

  // Fake history data
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
      'orderId': '12345',
      'totalAmount': '\$7,750.88',
      'totalEarning': '\$7,750.88',
      'discount': '20%',
      'commission': '\$7,750.88',
    },
    {
      'interval': 'From 15 / 11 to 01 / 25',
      'orderId': '12345',
      'totalAmount': '\$7,750.88',
      'totalEarning': '\$7,750.88',
      'discount': '20%',
      'commission': '\$7,750.88',
    },
  ];

  void _loadMore() {
    setState(() {
      _shown = (_shown + _pageSize).clamp(0, _historyData.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _historyData.take(_shown).toList();
    final canLoadMore = _shown < _historyData.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title and Icon
            Row(
              children: [
                const Text(
                  'Earning',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Image.asset(
                  'assets/icons/trending_up.png', // Specified image asset
                  width: 38,
                  height: 38,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Earning Metric
            _buildMetricCard(
              label: 'Earning',
              value: '\$128k',
              change: '+37.8% this week',
              isPositive: true,
              iconPath: 'assets/icons/trending_up.png',
              backgroundColor: const Color(0xFFD0E0FF), // Adjusted color
            ),
            const SizedBox(height: 16),

            // Balance Metric
            _buildMetricCard(
              label: 'Balance',
              value: '\$512.64',
              change: '-37.8% this week',
              isPositive: false,
              iconPath: 'assets/icons/balance.png',
              backgroundColor: const Color(0xFFF9D1CF), // Adjusted color
            ),
            const SizedBox(height: 16),

            // Total Value of Sales
            _buildMetricCard(
              label: 'Total value of sales',
              value: '\$64k',
              change: '+37.8% this week',
              isPositive: true,
              iconPath: 'assets/icons/cart.png',
              backgroundColor: const Color(0xFFD6F6E6), // Adjusted color
            ),
            const SizedBox(height: 24),

            // Product Views Chart Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  )
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Product views',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: 'All time',
                              items: const [
                                DropdownMenuItem(
                                  value: 'All time',
                                  child: Text('All time'),
                                ),
                              ],
                              onChanged: (_) {},
                              underline: Container(),
                              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image.asset(
                              'assets/icons/download.png', // Specified image asset
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
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
                          dataSource: [
                            ChartData('Jan', 8.2, 50),
                            ChartData('Feb', 8.4, 70),
                            ChartData('Mar', 8.3, 60),
                            ChartData('Apr', 8.1, 40),
                            ChartData('May', 8.7, 120),
                            ChartData('Jun', 8.3, 55),
                          ],
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y1,
                          name: 'Lifetime Value',
                          color: const Color(0xFF4285F4),
                          width: 0.6,
                          spacing: 0.1,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8)),
                        ),
                        ColumnSeries<ChartData, String>(
                          dataSource: [
                            ChartData('Jan', 8.2, 50),
                            ChartData('Feb', 8.4, 70),
                            ChartData('Mar', 8.3, 60),
                            ChartData('Apr', 8.1, 40),
                            ChartData('May', 8.7, 120),
                            ChartData('Jun', 8.3, 55),
                          ],
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y2,
                          name: 'Customer Cost',
                          color: const Color(0xFFFBBC05),
                          width: 0.6,
                          spacing: 0.1,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8)),
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
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Earning History Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  )
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Earning history',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...visible.map((item) => _buildHistoryItem(item)),
                  const SizedBox(height: 12),
                  if (_historyData.isNotEmpty)
                    Center(
                      child: Opacity(
                        opacity: canLoadMore ? 1 : 0.6,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: canLoadMore ? _loadMore : null,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: const Color(0x44000000)), // Adjusted border color
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0C000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/icons/loading.png',
                                    width: 18,
                                    height: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Load more',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildHistoryItem(Map<String, String> item) {
    return Column(
      children: [
        _buildHistoryRow('Interval', item['interval']!),
        _buildHistoryRow('Order ID', item['orderId']!),
        _buildHistoryRow('Total Amount', item['totalAmount']!),
        _buildHistoryRow('Total Earning', item['totalEarning']!),
        _buildHistoryRow('Discount Amount', item['discount']!),
        _buildHistoryRow('Admin Commission', item['commission']!),
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
          Text(label,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.65), fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.6), fontSize: 14)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
                child: Image.asset(
                  iconPath,
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style:
              const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive
                    ? const Color(0xFF34A853)
                    : const Color(0xFFEA4335),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(change,
                  style: TextStyle(
                    color: isPositive
                        ? const Color(0xFF34A853)
                        : const Color(0xFFEA4335),
                    fontSize: 12,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String x;
  final double y1;
  final double y2;

  ChartData(this.x, this.y1, this.y2);
}