import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _ranges = const ['All time', 'Last 30 days', 'Last 7 days', 'This year'];

  String _salesRange = 'All time';
  String _customersRange = 'All time';
  String _ordersRange = 'All time';
  String _aovRange = 'All time';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;


    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Hello, Mr Jake', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text("Let's Check Your Store!", style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
            const SizedBox(height: 12),
            _StatRow(),
            const SizedBox(height: 16),

            SectionCard(
              title: 'Total Sales',
              trailing: _RangeDropDown(
                value: _salesRange,
                ranges: _ranges,
                onChanged: (v) => setState(() => _salesRange = v!),
              ),
              child: _SalesSection(range: _salesRange),
            ),
            const SizedBox(height: 16),

            SectionCard(
              title: 'Total customers',
              trailing: _RangeDropDown(
                value: _customersRange,
                ranges: _ranges,
                onChanged: (v) => setState(() => _customersRange = v!),
              ),
              child: _CustomersSection(range: _customersRange),
            ),
            const SizedBox(height: 16),

            SectionCard(
              title: 'Orders views',
              trailing: _RangeDropDown(
                value: _ordersRange,
                ranges: _ranges,
                onChanged: (v) => setState(() => _ordersRange = v!),
              ),
              child: _OrdersSection(range: _ordersRange),
            ),
            const SizedBox(height: 16),

            SectionCard(
              title: 'Average Order Value',
              trailing: _RangeDropDown(
                value: _aovRange,
                ranges: _ranges,
                onChanged: (v) => setState(() => _aovRange = v!),
              ),
              child: const _AOVSection(range: 'All time'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _MiniStatCard(icon: Icons.payments_outlined, label: 'Revenue', value: 'AED 500', delta: '+50% Last Week', deltaColor: Colors.green)),
        SizedBox(width: 12),
        Expanded(child: _MiniStatCard(icon: Icons.shopping_bag_outlined, label: 'Order', value: '100', delta: '-50% Last Week', deltaColor: Colors.red)),
        SizedBox(width: 12),
        Expanded(child: _MiniStatCard(icon: Icons.people_alt_outlined, label: 'Customer', value: '562', delta: '+20% Last Week', deltaColor: Colors.green)),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String delta;
  final Color deltaColor;

  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.delta,
    required this.deltaColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon),
          ),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(delta, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: deltaColor)),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const SectionCard({super.key, required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RangeDropDown extends StatelessWidget {
  final String value;
  final List<String> ranges;
  final ValueChanged<String?> onChanged;
  const _RangeDropDown({required this.value, required this.ranges, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        items: ranges.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _SalesSection extends StatelessWidget {
  final String range;

  const _SalesSection({required this.range});

  @override
  Widget build(BuildContext context) {
    // Data changes based on the selected range
    List<FlSpot> salesData = _getSalesData(range);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('AED 0.00', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE9F7EF), borderRadius: BorderRadius.circular(8)),
              child: const Text('+37.8% Total Sales', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 10,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(['Jan','Mar','May','Jul','Sep','Nov'][v.toInt()], style: const TextStyle(fontSize: 10)),
                    ),
                    interval: 1,
                  ),
                ),
              ),
              gridData: FlGridData(show: true, horizontalInterval: 2),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: salesData,
                  isCurved: true,
                  dotData: const FlDotData(show: false),
                  barWidth: 3,
                ),
              ],
              lineTouchData: LineTouchData(enabled: true),
            ),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getSalesData(String range) {
    // Adjust the data based on the range
    switch (range) {
      case 'Last 7 days':
        return [FlSpot(0, 2.0), FlSpot(1, 3.0), FlSpot(2, 4.0), FlSpot(3, 5.0), FlSpot(4, 6.0), FlSpot(5, 7.0)];
      case 'Last 30 days':
        return [FlSpot(0, 2.5), FlSpot(1, 3.5), FlSpot(2, 4.5), FlSpot(3, 5.5), FlSpot(4, 6.5), FlSpot(5, 7.5)];
      default:
        return [FlSpot(0, 3), FlSpot(1, 4.5), FlSpot(2, 5.5), FlSpot(3, 6.5), FlSpot(4, 6), FlSpot(5, 7.5)];
    }
  }
}

class _CustomersSection extends StatelessWidget {
  final String range;

  const _CustomersSection({required this.range});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.6,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 60,
                  sections: _getCustomerData(range),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: const [
            _LegendDot(label: 'New customer'),
            _LegendDot(label: 'Returning customer'),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                'Welcome 291 customers with a personal message 🥳',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> _getCustomerData(String range) {
    // Adjust the customer data based on the selected range
    switch (range) {
      case 'Last 7 days':
        return [
          PieChartSectionData(value: 20, title: 'New\n5k', radius: 64, titleStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          PieChartSectionData(value: 80, title: '', radius: 64),
        ];
      case 'Last 30 days':
        return [
          PieChartSectionData(value: 30, title: 'New\n15k', radius: 64, titleStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          PieChartSectionData(value: 70, title: '', radius: 64),
        ];
      default:
        return [
          PieChartSectionData(value: 20, title: 'New\n20k', radius: 64, titleStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          PieChartSectionData(value: 80, title: '', radius: 64),
        ];
    }
  }
}

class _AOVSection extends StatelessWidget {
  const _AOVSection({required String range});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('AED 0.00', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFE9F7EF), borderRadius: BorderRadius.circular(8)),
              child: const Text('+37.8% Average Order Value', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 10,
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(['Jan','Mar','May','Jul','Sep','Nov'][v.toInt()], style: const TextStyle(fontSize: 10)),
                    ),
                    interval: 1,
                  ),
                ),
              ),
              gridData: FlGridData(show: true, horizontalInterval: 2),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: const [FlSpot(0, 3.3), FlSpot(1, 3.8), FlSpot(2, 5.9), FlSpot(3, 6.1), FlSpot(4, 6.4), FlSpot(5, 7.0)],
                  isCurved: true,
                  dotData: const FlDotData(show: false),
                  barWidth: 3,
                ),
                LineChartBarData(
                  spots: const [FlSpot(0, 2.0), FlSpot(1, 3.0), FlSpot(2, 4.0), FlSpot(3, 5.0), FlSpot(4, 5.6), FlSpot(5, 6.1)],
                  isCurved: true,
                  dotData: const FlDotData(show: false),
                  barWidth: 3,
                ),
              ],
              lineTouchData: LineTouchData(enabled: true),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            _LegendDot(label: '2022'),
            SizedBox(width: 12),
            _LegendDot(label: '2023'),
          ],
        ),
      ],
    );
  }
}


class _OrdersSection extends StatelessWidget {
  const _OrdersSection({required String range});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 8,
              gridData: FlGridData(show: true, horizontalInterval: 2),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(['Jan','Feb','Mar','Apr','May','Jun'][v.toInt()], style: const TextStyle(fontSize: 10)),
                    ),
                    interval: 1,
                  ),
                ),
              ),
              barGroups: List.generate(6, (i) {
                final ordersValue = [3.2, 2.2, 3.1, 1.3, 4.6, 2.8][i];
                final timeline = [1.2, 1.6, 2.1, 1.7, 3.2, 2.0][i];
                return BarChartGroupData(x: i, barsSpace: 6, barRods: [
                  BarChartRodData(toY: ordersValue, width: 10, borderRadius: BorderRadius.circular(3)),
                  BarChartRodData(toY: timeline, width: 10, borderRadius: BorderRadius.circular(3)),
                ]);
              }),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            _LegendDot(label: 'Orders Value'),
            SizedBox(width: 12),
            _LegendDot(label: 'Time Line'),
          ],
        ),
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

