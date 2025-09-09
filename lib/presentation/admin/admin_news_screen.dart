import 'dart:async';
import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import 'package:dio/dio.dart';

class AdminNewsScreen extends StatefulWidget {
  const AdminNewsScreen({super.key});

  @override
  State<AdminNewsScreen> createState() => _AdminNewsScreenState();
}

class _AdminNewsScreenState extends State<AdminNewsScreen> {
  final List<Map<String, dynamic>> _newsItems = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadFromMagento();
  }

  Future<void> _loadFromMagento() async {
    setState(() => _loading = true);

    final List<Map<String, dynamic>> aggregated = [];

    try {
      final List<Map<String, dynamic>> latestOrders = await VendorApiClient().getOrdersAdmin(
        pageSize: 5,
        currentPage: 1,
      );
      for (final o in latestOrders) {
        final id = (o['increment_id'] ?? o['entity_id'] ?? '').toString();
        final total = (o['grand_total'] ?? o['base_grand_total'] ?? 0).toStringAsFixed(2);
        final created = (o['created_at'] ?? '').toString();
        aggregated.add({
          'title': 'Order #$id',
          'content': 'New order placed • Total: AED $total',
          'time': _friendlyTime(created),
          'type': 'delivery',
        });
      }
    } on DioException catch (e) {
      _toastError(context, 'Orders: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      _toastError(context, 'Orders: $e');
    }

    try {
      final List<Map<String, dynamic>> latestProducts = await VendorApiClient().getProductsAdmin(
        pageSize: 5,
        currentPage: 1,
      );
      for (final p in latestProducts) {
        final sku = (p['sku'] ?? '').toString();
        final name = (p['name'] ?? '').toString();
        final created = (p['created_at'] ?? '').toString();
        aggregated.add({
          'title': name.isNotEmpty ? name : 'New product',
          'content': 'SKU: $sku',
          'time': _friendlyTime(created),
          'type': 'feature',
        });
      }
    } on DioException catch (e) {
      _toastError(context, 'Products: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      _toastError(context, 'Products: $e');
    }

    try {
      final ReviewPage reviewPage = await VendorApiClient().getProductReviewsAdmin(
        pageSize: 5,
      );
      for (final r in reviewPage.items) {
        final title = r.title ?? '';
        final created = '';
        final status = r.status?.toString() ?? '';
        String statusTxt = 'Pending';
        if (status == '1') statusTxt = 'Approved';
        if (status == '3') statusTxt = 'Rejected';

        aggregated.add({
          'title': title.isNotEmpty ? title : 'Product review',
          'content': 'Status: $statusTxt',
          'time': _friendlyTime(created),
          'type': 'fix',
        });
      }
    } on DioException catch (e) {
      _toastError(context, 'Reviews: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      _toastError(context, 'Reviews: $e');
    }

    if (!mounted) return;
    setState(() {
      _newsItems
        ..clear()
        ..addAll(aggregated);
      _loading = false;
    });
  }

  String _friendlyTime(String iso) {
    if (iso.isEmpty) return '—';
    DateTime? t = DateTime.tryParse(iso);
    if (t == null) return iso;
    final diff = DateTime.now().toUtc().difference(t.toUtc());
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _refreshNews() async {
    await _loadFromMagento();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.newsRefreshed),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  void _deleteNewsItem(int index) {
    final deletedItem = _newsItems[index];
    setState(() {
      _newsItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.newsDeleted),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.undo,
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _newsItems.insert(index, deletedItem);
            });
          },
        ),
      ),
    );
  }

  void _toastError(BuildContext ctx, String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'fix':
        return Icons.check_circle;
      case 'feature':
        return Icons.new_releases;
      case 'maintenance':
        return Icons.build;
      case 'delivery':
        return Icons.local_shipping;
      case 'payment':
        return Icons.payment;
      case 'security':
        return Icons.security;
      default:
        return Icons.info;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'fix':
        return Colors.green;
      case 'feature':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'delivery':
        return Colors.purple;
      case 'payment':
        return Colors.teal;
      case 'security':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.adminNews,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.recentUpdates,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          IconButton(
                            icon: _loading
                                ? const SizedBox(
                                width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.refresh, color: Colors.grey),
                            onPressed: _loading ? null : _refreshNews,
                            tooltip: loc.refreshNews,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : _newsItems.isEmpty
                            ? Center(
                          child: Text(
                            loc.noNews,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                            : ListView.builder(
                          itemCount: _newsItems.length,
                          itemBuilder: (context, index) {
                            final newsItem = _newsItems[index];
                            return Dismissible(
                              key: Key('news_${newsItem['title']}_$index'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: Colors.red,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              onDismissed: (direction) => _deleteNewsItem(index),
                              child: _buildNewsItem(
                                title: newsItem['title'] as String,
                                content: newsItem['content'] as String,
                                time: newsItem['time'] as String,
                                icon: _getIconForType(newsItem['type'] as String),
                                color: _getColorForType(newsItem['type'] as String),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsItem({
    required String title,
    required String content,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}