// lib/presentation/products/drafts_list_screen.dart
import 'package:flutter/material.dart';
import 'package:app_vendor/l10n/app_localizations.dart';
import '../../services/api_client.dart';

class DraftsListScreen extends StatefulWidget {
  const DraftsListScreen({super.key});

  @override
  State<DraftsListScreen> createState() => _DraftsListScreenState();
}

class _DraftsListScreenState extends State<DraftsListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isLoading = true;
  final List<_Draft> _allDrafts = [];
  final VendorApiClient _vendorApiClient = VendorApiClient();

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _loadDrafts();
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDrafts() async {
    setState(() => _isLoading = true);
    try {
      // Get all products and filter for drafts client-side
      final products = await _vendorApiClient.getProducts(pageSize: 100);

      _allDrafts.clear();
      for (var product in products) {
        // Check if product is a draft (status = 0 or other indicator)
        final status = product['status']?.toString();
        if (status == '0' || status == '2') { // Assuming 0 or 2 means draft
          _allDrafts.add(_Draft.fromMagentoProduct(product));
        }
      }
    } catch (e) {
      print('Failed to load drafts: $e');
      // Show empty state
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    setState(() {});
  }

  List<_Draft> get _filtered {
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return _allDrafts;

    return _allDrafts.where((draft) {
      return draft.name.toLowerCase().contains(query) ||
          draft.sku.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.draftsTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDrafts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: l10n.searchDraft,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.drafts, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    _searchCtrl.text.isEmpty
                        ? l10n.noDraftsAvailable
                        : l10n.noDraftsMatchSearch,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final draft = _filtered[index];
                return _DraftCard(draft: draft);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftCard extends StatelessWidget {
  final _Draft draft;

  const _DraftCard({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image and basic info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: draft.thumbnail != null
                      ? Image.network(
                    draft.thumbnail!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.error),
                  )
                      : Icon(Icons.image, size: 40, color: Colors.grey),
                ),
                SizedBox(width: 16),

                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'SKU: ${draft.sku}',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '\$${draft.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Additional details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoChip(
                  icon: Icons.inventory,
                  label: 'Qty: ${draft.qty}',
                ),
                _InfoChip(
                  icon: Icons.calendar_today,
                  label: _formatDate(draft.created),
                ),
                _StatusChip(status: draft.status),
              ],
            ),

            SizedBox(height: 16),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    // Edit action
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Delete action
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final DraftStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, text) = _getStatusInfo(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  (Color, String) _getStatusInfo(DraftStatus status) {
    switch (status) {
      case DraftStatus.draft:
        return (Colors.orange, 'DRAFT');
      case DraftStatus.pendingReview:
        return (Colors.blue, 'PENDING');
    }
  }
}

enum DraftStatus { draft, pendingReview }

class _Draft {
  _Draft({
    required this.id,
    required this.name,
    required this.sku,
    required this.qty,
    required this.price,
    required this.created,
    required this.status,
    this.thumbnail,
  });

  final int id;
  final String name;
  final String sku;
  final int qty;
  final double price;
  final DateTime created;
  final DraftStatus status;
  final String? thumbnail;

  factory _Draft.fromMagentoProduct(Map<String, dynamic> product) {
    return _Draft(
      id: product['id'] ?? 0,
      name: product['name'] ?? 'No Name',
      sku: product['sku'] ?? 'No SKU',
      qty: product['extension_attributes']?['stock_item']?['qty']?.toInt() ?? 0,
      price: (product['price'] ?? 0.0).toDouble(),
      created: DateTime.parse(product['created_at'] ?? DateTime.now().toString()),
      status: _parseStatus(product['status']),
      thumbnail: product['media_gallery_entries']?[0]?['file'],
    );
  }

  static DraftStatus _parseStatus(dynamic status) {
    if (status == null) return DraftStatus.draft;
    final statusStr = status.toString();
    if (statusStr == '2') return DraftStatus.draft;
    if (statusStr == '1') return DraftStatus.pendingReview;
    return DraftStatus.draft;
  }
}
