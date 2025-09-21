

import 'package:flutter/material.dart';
import 'package:kolshy_vendor/l10n/app_localizations.dart';
import 'package:kolshy_vendor/services/api_client.dart';

class ProductsTableShell extends StatefulWidget {
  const ProductsTableShell({super.key, required this.title, required this.l10n});
  final String title;
  final AppLocalizations l10n;

  @override
  State<ProductsTableShell> createState() => _ProductsTableShellState();
}

class EmptyModern extends StatelessWidget {
  const EmptyModern({super.key, required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 56, color: isDark ? Colors.white54 : Colors.black26),
              const SizedBox(height: 14),
              Text(
                l10n.empty_no_linked_products,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.empty_no_linked_products_desc,
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final AppLocalizations l10n;
  const ProductCard({super.key, required this.product, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final border = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE6E6E6);
    final onSurface = isDark ? Colors.white : Colors.black87;
    final onSurfaceMuted = isDark ? Colors.white70 : Colors.black54;

    final bool enabled = (product['enabled'] as bool?) ?? true;
    final statusLabel = enabled ? l10n.status_enabled : l10n.status_disabled;
    final statusColor = enabled ? Colors.green : Colors.orange;

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF161616) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Üst satır: ID + menü
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.id_with_value(product['id'].toString()),
                  style: theme.textTheme.bodySmall?.copyWith(color: onSurfaceMuted)),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 20, color: onSurfaceMuted),
                onSelected: (_) {},
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'Edit', child: Text(l10n.btn_edit)),
                  PopupMenuItem(value: 'Delete', child: Text(l10n.btn_delete)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.shopping_bag_outlined, color: isDark ? Colors.white30 : Colors.black38),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product['name'] ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: onSurface)),
                const SizedBox(height: 4),
                Text('${product['type']} — SKU ${product['sku']}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: onSurfaceMuted)),
                if (product['statusLabel'] != null) ...[
                  const SizedBox(height: 2),
                  Text(l10n.inventory_with_value(product['statusLabel'].toString()),
                      style: theme.textTheme.bodySmall?.copyWith(color: onSurfaceMuted)),
                ],
              ]),
            ),
          ]),
          const SizedBox(height: 16),


          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.lbl_price, style: theme.textTheme.bodySmall?.copyWith(color: onSurfaceMuted)),
              Text(l10n.price_with_currency((product['price'] ?? '—').toString()),
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: onSurface)),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(statusLabel,
                  style: theme.textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.w700)),
            ),
          ]),
        ]),
      ),
    );
  }
}


class _ProductsTableShellState extends State<ProductsTableShell> {
  final _search = TextEditingController();

  bool _showEnabled = true;
  bool _showDisabled = true;

  bool _loading = true;
  String? _error;


  List<Map<String, dynamic>> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {

      final items = await VendorApiClient().getProductsAdmin(pageSize: 1000);

      final mapped = items.map((p) {
        return <String, dynamic>{
          'id': p.sku,
          'sku': p.sku,
          'name': p.name,
          'type': 'simple',
          'price': '—',
          'statusLabel': '',
          'enabled': true,

        };
      }).toList();

      setState(() {
        _allProducts = mapped;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _filtersActive => !(_showEnabled && _showDisabled);

  void _openFilters() async {
    final l10n = widget.l10n;
    final result = await showModalBottomSheet<Map<String, bool>>(
      context: context,
      useSafeArea: true,
      isScrollControlled: false,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF161616) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        bool showEnabled = _showEnabled;
        bool showDisabled = _showDisabled;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final border = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE6E6E6);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Row(
                children: [
                  Text(l10n.filters, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      showEnabled = true;
                      showDisabled = true;
                      Navigator.of(context).pop({'enabled': showEnabled, 'disabled': showDisabled});
                    },
                    child: Text(l10n.btn_reset),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(border: Border.all(color: border), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(l10n.status_enabled),
                      value: showEnabled,
                      onChanged: (v) => showEnabled = v,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text(l10n.status_disabled),
                      value: showDisabled,
                      onChanged: (v) => showDisabled = v,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop({'enabled': showEnabled, 'disabled': showDisabled}),
                      icon: const Icon(Icons.check),
                      label: Text(l10n.btn_apply),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        _showEnabled = result['enabled'] ?? true;
        _showDisabled = result['disabled'] ?? true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE6E6E6);
    final onSurface = isDark ? Colors.white : Colors.black87;
    final onSurfaceMuted = isDark ? Colors.white70 : Colors.black54;
    final l10n = widget.l10n;

    if (_loading) {
      return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ),
      );
    }


    List<Map<String, dynamic>> decorated = List<Map<String, dynamic>>.from(_allProducts);

    final q = _search.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      decorated = decorated.where((p) {
        return p['name'].toString().toLowerCase().contains(q) ||
            p['sku'].toString().toLowerCase().contains(q)  ||
            p['id'].toString().toLowerCase().contains(q);
      }).toList();
    }
    decorated = decorated.where((p) {
      final isEnabled = (p['enabled'] as bool?) ?? true;
      if (isEnabled && !_showEnabled) return false;
      if (!isEnabled && !_showDisabled) return false;
      return true;
    }).toList();

    Widget? activeFilterChip() {
      if (!_filtersActive) return null;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.filter_alt, size: 16), SizedBox(width: 6)],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 640;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(widget.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: onSurface)),
                  SizedBox(
                    width: narrow ? c.maxWidth : 260,
                    child: TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: l10n.hint_search_name_sku,
                        isDense: true,
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border),
                        ),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _openFilters,
                    icon: Icon(
                      Icons.filter_alt_outlined,
                      size: 18,
                      color: _filtersActive ? Theme.of(context).colorScheme.primary : onSurface,
                    ),
                    label: Text(_filtersActive ? l10n.btn_filters_on : l10n.btn_filters),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      side: BorderSide(color: border),
                      foregroundColor: onSurface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: _filtersActive
                          ? (isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF3F3F3))
                          : null,
                    ),
                  ),
                  if (activeFilterChip() != null) activeFilterChip()!,
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: _fetchProducts,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: decorated.isEmpty
              ? EmptyModern(l10n: l10n)
              : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: decorated.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => ProductCard(product: decorated[index], l10n: l10n),
          ),
        ),
      ],
    );
  }
}

