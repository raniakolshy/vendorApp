import 'package:flutter/material.dart';

import '../../services/api_client.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final VendorApiClient _apiClient = VendorApiClient();
  bool _isLoading = true;
  String _errorMessage = '';

  // Dashboard Data Models
  Map<String, dynamic> _dashboardMetrics = {};
  List<dynamic> _products = [];
  List<dynamic> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Use Future.wait to fetch all data concurrently for efficiency
      final results = await Future.wait([
        _apiClient.getDashboardMetrics(),
        _apiClient.getVendorProducts(),
        _apiClient.getVendorReviews(),
      ]);

      setState(() {
        _dashboardMetrics = results[0] as Map<String, dynamic>;
        _products = results[1] as List<dynamic>;
        _reviews = results[2] as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load dashboard data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendor Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetricCards(),
            const SizedBox(height: 24),
            _buildTopSellingProducts(),
            const SizedBox(height: 24),
            _buildLatestReviews(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMetricCard(
              title: 'Total Sales',
              value: '\$${_dashboardMetrics['total_sales']?.toStringAsFixed(2) ?? '0.00'}',
              icon: Icons.attach_money,
              color: Colors.green,
            ),
            _buildMetricCard(
              title: 'Total Orders',
              value: '${_dashboardMetrics['total_orders'] ?? '0'}',
              icon: Icons.shopping_cart,
              color: Colors.blue,
            ),
            _buildMetricCard(
              title: 'Total Products',
              value: '${_products.length}',
              icon: Icons.inventory,
              color: Colors.orange,
            ),
            _buildMetricCard(
              title: 'New Customers',
              value: '${_dashboardMetrics['new_customers'] ?? '0'}',
              icon: Icons.person_add,
              color: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingProducts() {
    // Assuming API provides a list of products with a 'sales_count' key
    final sortedProducts = List.from(_products)
      ..sort((a, b) => (b['sales_count'] ?? 0).compareTo(a['sales_count'] ?? 0));
    final topProducts = sortedProducts.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Selling Products',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (topProducts.isEmpty)
          const Center(child: Text('No products available.'))
        else
          ...topProducts.map((product) {
            final name = product['name'] ?? 'No Name';
            final salesCount = product['sales_count'] ?? 0;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: const Icon(Icons.shopping_bag, color: Colors.blue),
                title: Text(name),
                trailing: Text('$salesCount sold', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildLatestReviews() {
    final latestReviews = List.from(_reviews)
      ..sort((a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''));
    final topReviews = latestReviews.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latest Reviews',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (topReviews.isEmpty)
          const Center(child: Text('No reviews available.'))
        else
          ...topReviews.map((review) {
            final reviewText = review['detail'] ?? 'No review text';
            final rating = review['rating'] ?? 0;
            final customerName = review['nickname'] ?? 'Anonymous';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: const Icon(Icons.rate_review, color: Colors.grey),
                title: Text(
                  customerName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  reviewText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$rating'),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}
