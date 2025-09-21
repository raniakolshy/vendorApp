

import 'package:kolshy_vendor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import 'package:kolshy_vendor/data/models/product_model.dart';



class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String? _filter;
  static const int _pageSize = 20;
  int _shown = _pageSize;
  int _currentPage = 1;
  bool _loadingMore = false;
  bool _isLoading = true;

  final VendorApiClient _apiClient = VendorApiClient();

  List<ProductModel> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final localizations = AppLocalizations.of(context)!;
    _filter ??= localizations.allProducts;
    _loadProducts();
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  String? _statusToMagento(String filter, AppLocalizations l10n) {
    if (filter == l10n.enabledProducts) return '1';
    if (filter == l10n.disabledProducts) return '2';

    return null;
  }

  Future<void> _loadProducts({bool isLoadMore = false}) async {
    if (!_apiClient.hasToken) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (!isLoadMore) {
      if (mounted) setState(() {
        _isLoading = true;
        _currentPage = 1;
        _allProducts.clear();
      });
    }

    try {
      final vendorId = _apiClient.vendorId;
      if (vendorId == null) {
        throw Exception("Vendor ID is not available.");
      }

      final l10n = AppLocalizations.of(context)!;
      final status = _statusToMagento(_filter ?? l10n.allProducts, l10n);

      final productsData = await _apiClient.getVendorProducts(
        vendorId: vendorId,
        pageSize: _pageSize,
        currentPage: _currentPage,
        productStatus: status,
      );

      if (mounted) {
        setState(() {
          if (isLoadMore) {
            _allProducts.addAll(productsData);
          } else {
            _allProducts = productsData;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ProductModel> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    // Arama sadece ürün adı üzerinden yapılıyor
    return _allProducts.where((p) => (p.name?.toLowerCase().contains(q) ?? false)).toList();
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
    _loadProducts(); // Filtre değişince veriyi yeniden çekiyoruz
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    if (!_apiClient.hasToken) return;

    if (mounted) setState(() => _loadingMore = true);
    try {
      _currentPage++;
      final vendorId = _apiClient.vendorId;
      if (vendorId == null) {
        throw Exception("Vendor ID is not available.");
      }

      final l10n = AppLocalizations.of(context)!;
      final status = _statusToMagento(_filter ?? l10n.allProducts, l10n);

      final moreProducts = await _apiClient.getVendorProducts(
        vendorId: vendorId,
        pageSize: _pageSize,
        currentPage: _currentPage,
        productStatus: status,
      );

      if (mounted) {
        setState(() {
          _allProducts.addAll(moreProducts);
          _loadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingMore = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load more: $e')),
        );
      }
    }
  }

  void _deleteProduct(ProductModel product) {
    // ... (Your existing delete logic) ...
  }

  void _editProduct(ProductModel product) {
    // ... (Your existing edit logic) ...
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final visible = _filtered.take(_shown).toList();
    final canLoadMore = _shown < _filtered.length && !_loadingMore;

    final filters = [
      localizations.allProducts,
      localizations.enabledProducts,
      localizations.disabledProducts,
      localizations.lowStock,
      localizations.outOfStock,
      localizations.deniedProduct,
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
                      localizations.productsTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800, fontSize: 22),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _InputSurface(
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                              hintText: localizations.searchProduct,
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
                          items: filters.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                          onChanged: _onFilterChanged,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: visible.length,
                      separatorBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0x11000000),
                        ),
                      ),
                      itemBuilder: (context, i) => _ProductRow(
                        product: visible[i],
                        onEdit: () => _editProduct(visible[i]),
                        onDelete: () => _deleteProduct(visible[i]),
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (_filtered.isNotEmpty)
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
                                      Image.asset(
                                        'assets/icons/loading.png',
                                        width: 18,
                                        height: 18,
                                      ),
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
                    if (_filtered.isEmpty && !_isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Center(
                          child: Text(
                            localizations.noProductsFound, // Mesajı daha genel hale getirdik
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
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
// ===== UI pieces

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final keyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black.withOpacity(.65));
    final valStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black.withOpacity(.85));

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 86,
                height: 86,
                color: const Color(0xFFEDEEEF),
                child: product.imageUrl != null
                    ? Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.error))
                    : const Icon(Icons.image, size: 50, color: Colors.black54),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? 'Untitled Product',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  _PriceChip('\$${product.price?.toStringAsFixed(2) ?? '0.00'}'),
                  const SizedBox(height: 6),
                  Text(
                    product.typeId ?? 'N/A',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),

                  _ProductDetailRow(
                    label: localizations.idLabel,
                    value: product.id?.toString() ?? 'N/A',
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  _ProductDetailRow(
                    label: localizations.skuLabel,
                    value: product.sku ?? 'N/A',
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  _ProductDetailRow(
                    label: localizations.statusLabel,
                    valueWidget: _StatusPill(status: product.status),
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  _ProductDetailRow(
                    label: localizations.createdLabel,
                    value: product.createdAt ?? 'N/A',
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  _ProductDetailRow(
                    label: localizations.priceLabel,
                    value: '\$${product.price?.toStringAsFixed(2) ?? '0.00'}',
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  _ProductDetailRow(
                    label: localizations.actionLabel,
                    valueWidget: Row(
                      children: [
                        IconButton(
                          onPressed: onEdit,
                          icon: Image.asset('assets/icons/pen.png', width: 20, height: 20, color: Colors.black54),
                          tooltip: localizations.editButton,
                        ),
                        IconButton(
                          onPressed: onDelete,
                          icon: Image.asset('assets/icons/trash.png', width: 20, height: 20, color: Colors.black54),
                          tooltip: localizations.deleteButton,
                        ),
                      ],
                    ),
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProductDetailRow extends StatelessWidget {
  const _ProductDetailRow({
    required this.label,
    this.value,
    this.valueWidget,
    required this.keyStyle,
    required this.valStyle,
  }) : assert(value != null || valueWidget != null, 'Provide either value or valueWidget');

  final String label;
  final String? value;
  final Widget? valueWidget;
  final TextStyle? keyStyle;
  final TextStyle? valStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: keyStyle),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: valueWidget ?? Text(value ?? '', style: valStyle),
          ),
        ],
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final ProductStatus status;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final String label;
    final Color bgColor;
    final Color textColor;

    switch (status) {
      case ProductStatus.active:
        label = localizations.statusActive;
        bgColor = const Color(0xFFDFF7E3);
        textColor = const Color(0xFF2E7D32);
        break;
      case ProductStatus.disabled:
        label = localizations.statusDisabled;
        bgColor = const Color(0xFFFFE0E0);
        textColor = const Color(0xFFC62828);
        break;
      case ProductStatus.lowStock:
        label = localizations.statusLowStock;
        bgColor = const Color(0xFFFFF4CC);
        textColor = const Color(0xFFF9A825);
        break;
      case ProductStatus.outOfStock:
        label = localizations.statusOutOfStock;
        bgColor = const Color(0xFFFFE0E0);
        textColor = const Color(0xFFC62828);
        break;
      case ProductStatus.denied:
        label = localizations.statusDenied;
        bgColor = const Color(0xFFFFCCCC);
        textColor = const Color(0xFFB71C1C);
        break;
      case ProductStatus.draft:
        label = localizations.drafts;
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        break;
      case ProductStatus.unknown:
      default:
        label = 'N/A';
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        break;
    }

    return DecoratedBox(
      decoration:
      BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700, color: textColor),
        ),
      ),
    );
  }
}

class _VisibilityPill extends StatelessWidget {
  const _VisibilityPill({required this.visibility});
  final ProductVisibility visibility;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final String label;
    final Color bgColor;
    final Color textColor;

    switch (visibility) {
      case ProductVisibility.catalogSearch:
        label = localizations.visibilityCatalogSearch;
        bgColor = const Color(0xFFDFF7E3);
        textColor = const Color(0xFF2E7D32);
        break;
      case ProductVisibility.catalogOnly:
        label = localizations.visibilityCatalogOnly;
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        break;
      case ProductVisibility.searchOnly:
        label = localizations.visibilitySearchOnly;
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF388E3C);
        break;
      case ProductVisibility.notVisible:
        label = localizations.visibilityNotVisible;
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        break;
    }

    return DecoratedBox(
      decoration:
      BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700, color: textColor),
        ),
      ),
    );
  }
}

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