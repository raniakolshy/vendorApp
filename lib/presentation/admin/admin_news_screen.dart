

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:kolshy_vendor/l10n/app_localizations.dart';
import 'package:kolshy_vendor/services/api_client.dart' as api;
import 'package:kolshy_vendor/data/models/review_model.dart'; // Correct import for MagentoReview

class AdminNewsScreen extends StatefulWidget {
  const AdminNewsScreen({super.key});

  @override
  State<AdminNewsScreen> createState() => _AdminNewsScreenState();
}

class _AdminNewsScreenState extends State<AdminNewsScreen> {
  final List<Map<String, dynamic>> _newsItems = [];
  bool _loading = false;
  final api.VendorApiClient _apiClient = api.VendorApiClient();

  @override
  void initState() {
    super.initState();
    _loadFromMagento();
  }

  Future<void> _loadFromMagento() async {
    if (_loading) return;
    setState(() => _loading = true);

    final List<Map<String, dynamic>> aggregated = [];

    // ---------------- ORDERS (Admin) ----------------
    try {
      final dynamic responseData = await _apiClient.getOrdersAdmin();
      final List<dynamic> latestOrders;
      if (responseData is Map<String, dynamic>) {
        final dynamic items = responseData['items'];
        latestOrders = (items is List) ? items : const [];
      } else if (responseData is List) {
        latestOrders = responseData;
      } else {
        latestOrders = const [];
      }

      for (final o in latestOrders) {
        final Map<String, dynamic> order = (o is Map) ? o.cast<String, dynamic>() : <String, dynamic>{};
        final id = (order['increment_id'] ?? order['entity_id'] ?? '').toString();
        final totalNum = double.tryParse((order['grand_total'] ?? order['base_grand_total'] ?? 0).toString()) ?? 0.0;
        final total = totalNum.toStringAsFixed(2);
        final created = (order['created_at'] ?? '').toString();

        aggregated.add({
          'title': 'Order #$id',
          'content': 'New order placed • Total: AED $total',
          'time': _friendlyTime(created),
          'type': 'delivery',
        });
      }
    } on DioException catch (e) {
      _toastError(context, 'Orders: ${_extractDioMessage(e)}');
    } catch (e) {
      _toastError(context, 'Orders: $e');
    }

    // ---------------- REVIEWS (Admin) ----------------
    try {
      final api.ReviewPage reviewPage = await _apiClient.getProductReviewsAdmin(currentPage: 1, pageSize: 20);

      // Explicitly map the dynamic list to MagentoReview objects
      final List<MagentoReview> reviews = (reviewPage.items as List)
          .map((json) => MagentoReview.fromJson(json as Map<String, dynamic>))
          .toList();

      for (final r in reviews) {
        final String title = (r.title ?? '').toString();
        final int statusId = r.status ?? 0;
        String statusTxt = 'Pending';
        if (statusId == 1) statusTxt = 'Approved';
        if (statusId == 3) statusTxt = 'Rejected';

        aggregated.add({
          'title': title.isNotEmpty ? title : 'Product review',
          'content': 'Status: $statusTxt',
          'time': '—',
          'type': 'fix',
        });
      }
    } on DioException catch (e) {
      _toastError(context, 'Reviews: ${_extractDioMessage(e)}');
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

  // ---------------- helpers ----------------

  String _friendlyTime(String iso) {
    if (iso.isEmpty) return '—';
    final t = DateTime.tryParse(iso);
    if (t == null) return '—';
    final diff = DateTime.now().toUtc().difference(t.toUtc());
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _extractDioMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
      return e.message ?? 'Unknown error';
    } catch (_) {
      return e.message ?? 'Unknown error';
    }
  }

  void _refreshNews() async {
    await _loadFromMagento();
    if (!mounted) return;
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc?.newsRefreshed ?? 'News refreshed'),
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

    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc?.newsDeleted ?? 'News deleted'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        action: SnackBarAction(
          label: loc?.undo ?? 'Undo',
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
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc?.adminNews ?? 'Admin News',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
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
                            loc?.recentUpdates ?? 'Recent Updates',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          IconButton(
                            icon: _loading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                                : const Icon(Icons.refresh, color: Colors.grey),
                            onPressed: _loading ? null : _refreshNews,
                            tooltip: loc?.refreshNews ?? 'Refresh news',
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
                            loc?.noNews ?? 'No news',
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
                              onDismissed: (direction) =>
                                  _deleteNewsItem(index),
                              child: _buildNewsItem(
                                title: (newsItem['title'] ?? '').toString(),
                                content:
                                (newsItem['content'] ?? '').toString(),
                                time: (newsItem['time'] ?? '—').toString(),
                                icon: _getIconForType(
                                    (newsItem['type'] ?? '').toString()),
                                color: _getColorForType(
                                    (newsItem['type'] ?? '').toString()),
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
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
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