import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  // Pagination variables
  static const int _pageSize = 2;
  int _shown = _pageSize;

  // Fake history data
  final List<Map<String, String>> _historyData = [
    {
      'interval': 'Today, 10:30 AM',
      'orderId': '#12345',
      'totalAmount': '\$128.00',
      'totalEarning': '\$112.00',
      'discount': '\$16.00',
      'commission': '\$5.60',
    },
    {
      'interval': 'Today, 09:15 AM',
      'orderId': '#12344',
      'totalAmount': '\$85.50',
      'totalEarning': '\$75.00',
      'discount': '\$10.50',
      'commission': '\$3.75',
    },
    {
      'interval': 'Yesterday, 4:30 PM',
      'orderId': '#12343',
      'totalAmount': '\$210.00',
      'totalEarning': '\$185.00',
      'discount': '\$25.00',
      'commission': '\$9.25',
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
            // Page Title
            const Text(
              'Earnings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),

            // Key Metrics Cards
            Row(
              children: [
                _buildMetricCard(
                  icon: Icons.trending_up,
                  color: const Color(0xFFEAF3FF),
                  accentColor: const Color(0xFF4285F4),
                  label: 'Earning',
                  value: '\$128k',
                  change: '+37.8% this week',
                  isPositive: true,
                ),
                const SizedBox(width: 12),
                _buildMetricCard(
                  icon: Icons.account_balance_wallet,
                  color: const Color(0xFFFEEAE6),
                  accentColor: const Color(0xFFEA4335),
                  label: 'Balance',
                  value: '\$512.64',
                  change: '-2.1% this week',
                  isPositive: false,
                ),
                const SizedBox(width: 12),
                _buildMetricCard(
                  icon: Icons.shopping_bag,
                  color: const Color(0xFFE6F4EA),
                  accentColor: const Color(0xFF34A853),
                  label: 'Total Sales',
                  value: '\$64k',
                  change: '+12.4% this week',
                  isPositive: true,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Product Sales Chart Card
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
                  // Chart Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Product Sales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      DropdownButton<String>(
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
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 220,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(
                        labelStyle: const TextStyle(fontSize: 12),
                      ),
                      primaryYAxis: NumericAxis(
                        labelStyle: const TextStyle(fontSize: 12),
                        numberFormat: NumberFormat.compactCurrency(
                          decimalDigits: 0,
                          symbol: '\$',
                        ),
                      ),
                      series: <CartesianSeries<ChartData, String>>[
                        ColumnSeries<ChartData, String>(
                          dataSource: [
                            ChartData('Jan', 35, 20),
                            ChartData('Feb', 28, 15),
                            ChartData('Mar', 34, 18),
                            ChartData('Apr', 32, 22),
                            ChartData('May', 40, 25),
                            ChartData('Jun', 38, 20),
                          ],
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y1,
                          name: 'Lifetime Value',
                          color: const Color(0xFF4285F4),
                        ),
                        ColumnSeries<ChartData, String>(
                          dataSource: [
                            ChartData('Jan', 35, 20),
                            ChartData('Feb', 28, 15),
                            ChartData('Mar', 34, 18),
                            ChartData('Apr', 32, 22),
                            ChartData('May', 40, 25),
                            ChartData('Jun', 38, 20),
                          ],
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y2,
                          name: 'Customer Cost',
                          color: const Color(0xFFFBBC05),
                        ),
                      ],
                      legend: Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        textStyle: const TextStyle(fontSize: 12),
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
                    'Earning History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Show only visible items
                  ...visible.map((item) => _buildHistoryItem(item)),

                  const SizedBox(height: 12),

                  // Load more button
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
                              border: Border.all(color: const Color(0x22000000)),
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
    required IconData icon,
    required Color color,
    required Color accentColor,
    required String label,
    required String value,
    required String change,
    required bool isPositive,
  }) {
    return Expanded(
      child: Container(
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(label,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.6), fontSize: 12)),
            const SizedBox(height: 8),
            Text(value,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
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
