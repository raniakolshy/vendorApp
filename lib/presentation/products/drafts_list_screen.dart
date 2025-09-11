import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:app_vendor/services/api_client.dart';

// ===== Models =====

enum DraftStatus {
  draft,
  pendingReview,
}

enum Gender {
  male,
  female,
}

class _Draft {
  _Draft({
    required this.id,
    required this.name,
    required this.sku,
    required this.qty,
    required this.price,
    required this.created,
    required this.status,
    required this.gender,
    this.thumbnail,
  });

  final int id;
  final String name;
  final String sku;
  final int qty;
  final double price;
  final DateTime created;
  final DraftStatus status;
  final Gender gender;
  final String? thumbnail;

  factory _Draft.fromMagentoProduct(Map<String, dynamic> product) {
    final thumbnailList = product['media_gallery_entries'] as List?;
    final thumbnail = thumbnailList != null && thumbnailList.isNotEmpty
        ? thumbnailList[0]['file']
        : null;

    return _Draft(
      id: product['id'] ?? 0,
      name: product['name'] ?? 'No Name',
      sku: product['sku'] ?? 'No SKU',
      qty: product['extension_attributes']?['stock_item']?['qty']?.toInt() ?? 0,
      price: (product['price'] ?? 0.0).toDouble(),
      created: DateTime.tryParse(product['created_at'] ?? '') ?? DateTime.now(),
      status: _parseStatus(product['status']),
      gender: Gender.male, // Needs mapping from custom attributes
      thumbnail: thumbnail,
    );
  }

  static DraftStatus _parseStatus(dynamic status) {
    if (status == null) return DraftStatus.draft;
    if (status == 1) return DraftStatus.pendingReview;
    if (status == 2) return DraftStatus.draft;
    return DraftStatus.draft;
  }
}

// Product model for passing to AddProductScreen
class Product {
  Product({
    required this.name,
    required this.sku,
    required this.quantity,
    required this.price,
  });

  final String name;
  final String sku;
  final int quantity;
  final double price;
}

// ===== Utils =====

String _fmtDate(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString();
  return '$dd / $mm / $yyyy';
}

// Main Screen Widget
class DraftsListScreen extends StatefulWidget {
  const DraftsListScreen({super.key});

  @override
  State<DraftsListScreen> createState() => _DraftsListScreenState();
}

class _DraftsListScreenState extends State<DraftsListScreen> {
  // UI state
  final TextEditingController _searchCtrl = TextEditingController();
  String? _filter;
  static const int _pageSize = 2;
  int _shown = _pageSize;
  bool _loadingMore = false;
  bool _isLoading = true;
  List<_Draft> _all = [];
  late final VendorApiClient _VendorApiClient;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _VendorApiClient = VendorApiClient();
    _loadDrafts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localizations = AppLocalizations.of(context);
    if (_filter == null && localizations != null) {
      _filter = localizations.allDrafts;
    }
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
      final products = await _VendorApiClient.getDraftProducts();
      _all = products.map((product) => _Draft.fromMagentoProduct(product)).toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load drafts: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<_Draft> get _filtered {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return [];

    final q = _searchCtrl.text.trim().toLowerCase();
    final byText = _all.where((d) =>
    d.name.toLowerCase().contains(q) ||
        d.sku.toLowerCase().contains(q)
    );

    if (_filter == localizations.pendingReview) {
      return byText.where((d) => d.status == DraftStatus.pendingReview).toList();
    } else if (_filter == localizations.drafts) {
      return byText.where((d) => d.status == DraftStatus.draft).toList();
    } else {
      return byText.toList();
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;

    setState(() => _loadingMore = true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _shown += _pageSize;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingMore = false);
      }
    }
  }

  void _onSearchChanged() {
    setState(() => _shown = _pageSize);
  }

  void _onFilterChanged(String? v) {
    if (v == null) return;
    setState(() {
      _filter = v;
      _shown = _pageSize;
    });
  }

  void _onEdit(_Draft d) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edit feature not implemented yet.')));
  }

  Future<void> _onDelete(_Draft d) async {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Text(
          localizations.deleteDraftQuestion,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(localizations.deleteDraftConfirmation(d.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                localizations.cancelButton,
                style: TextStyle(color: Colors.grey[700]),
              )),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(
                localizations.deleteButton,
                style: const TextStyle(color: Colors.red),
              )),
        ],
      ),
    );
    if (ok == true && mounted) setState(() => _all.remove(d));
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return const SizedBox();

    final visible = _filtered.take(_shown).toList();
    final canLoadMore = _shown < _filtered.length && !_loadingMore;

    final filters = [
      localizations.allDrafts,
      localizations.drafts,
      localizations.pendingReview,
    ];

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
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
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.draftsTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800, fontSize: 22),
                    ),
                    const SizedBox(height: 16),
                    _InputSurface(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: localizations.searchDraft,
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(.35),
                          ),
                          border: InputBorder.none,
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 22,
                            color: Colors.black54,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _filter,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Colors.black54),
                      dropdownColor: Colors.white,
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      items: filters.map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: _onFilterChanged,
                    ),
                    const SizedBox(height: 18),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Center(
                          child: Text(
                            localizations.noDraftsMatchSearch,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: visible.length,
                            itemBuilder: (context, i) => _DraftRow(
                              draft: visible[i],
                              onEdit: () => _onEdit(visible[i]),
                              onDelete: () => _onDelete(visible[i]),
                            ),
                          ),
                          const SizedBox(height: 22),
                          if (_filtered.length > _pageSize)
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
                                      border: Border.all(
                                        color: const Color(0x22000000),
                                      ),
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
                                          if (_loadingMore)
                                            const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          else
                                            const Icon(Icons.download, size: 18, color: Colors.black54),
                                          const SizedBox(width: 10),
                                          Text(
                                            localizations.loadMore,
                                            style: const TextStyle(
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftRow extends StatelessWidget {
  const _DraftRow({
    required this.draft,
    required this.onEdit,
    required this.onDelete,
  });

  final _Draft draft;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return const SizedBox();

    final keyStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: Colors.black.withOpacity(.65));
    final valStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(
        fontWeight: FontWeight.w600, color: Colors.black.withOpacity(.85));

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 86,
                    height: 86,
                    color: const Color(0xFFEDEEEF),
                    child: (draft.thumbnail != null && draft.thumbnail!.isNotEmpty)
                        ? Image.network(
                      draft.thumbnail!,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.black26),
                    )
                        : const Icon(Icons.image_not_supported, size: 50, color: Colors.black26),
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    _PriceChip('\$${draft.price.toStringAsFixed(2)}'),
                    const SizedBox(height: 6),
                    Text(
                      localizations.drafts,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    _RowKVText(
                      k: localizations.skuLabel,
                      vText: draft.sku,
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                    ),
                    const SizedBox(height: 12),
                    _RowKVText(
                      k: localizations.quantityLabel,
                      vText: draft.qty.toString(),
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                    ),
                    const SizedBox(height: 12),
                    _RowKVText(
                      k: localizations.createdLabel,
                      vText: _fmtDate(draft.created),
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                    ),
                    const SizedBox(height: 12),
                    _RowKVText(
                      k: localizations.statusLabel,
                      v: _StatusPill(status: draft.status),
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                      isWidgetValue: true,
                    ),
                    const SizedBox(height: 12),
                    _RowKVText(
                      k: localizations.actionLabel,
                      v: Row(
                        children: [
                          IconButton(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit, color: Colors.black54, size: 20),
                            tooltip: localizations.editButton,
                          ),
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete, color: Colors.black54, size: 20),
                            tooltip: localizations.deleteButton,
                          ),
                        ],
                      ),
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                      isWidgetValue: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: Color(0x11000000)),
        ],
      ),
    );
  }
}

// ===== Reused UI components from other screens =====

class _InputSurface extends StatelessWidget {
  const _InputSurface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x22000000)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: child,
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xE6EAF3FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x3382A9FF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _RowKVText extends StatelessWidget {
  const _RowKVText({
    required this.k,
    this.vText,
    this.v,
    required this.keyStyle,
    required this.valStyle,
    this.isWidgetValue = false,
  }) : assert((vText != null) ^ (v != null), 'Provide either vText or v');

  final String k;
  final String? vText;
  final Widget? v;
  final TextStyle? keyStyle;
  final TextStyle? valStyle;
  final bool isWidgetValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(k, style: keyStyle)),
        const SizedBox(width: 8),
        if (isWidgetValue && v != null)
          v!
        else
          Text(vText ?? '', style: valStyle),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final DraftStatus status;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return const SizedBox();

    final String label;
    final Color bgColor;
    final Color textColor;

    switch (status) {
      case DraftStatus.draft:
        label = localizations.drafts;
        bgColor = const Color(0xFFFFF4CC);
        textColor = const Color(0xFFF57F17);
        break;
      case DraftStatus.pendingReview:
        label = localizations.pendingReview;
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        break;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor
          ),
        ),
      ),
    );
  }
}