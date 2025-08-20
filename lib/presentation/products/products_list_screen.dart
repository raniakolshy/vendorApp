import 'package:flutter/material.dart';

void main() => runApp(const ProductsApp());

class ProductsApp extends StatelessWidget {
  const ProductsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF111111),
      fontFamily: 'Roboto',
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFFF3F3F4),
        textTheme: baseTheme.textTheme.apply(
          bodyColor: const Color(0xFF1B1B1B),
          displayColor: const Color(0xFF1B1B1B),
        ),
      ),
      home: const ProductsListScreen(),
      routes: {
        '/edit_product': (context) => const EditProductScreen(),
      },
    );
  }
}

class EditProductScreen extends StatelessWidget {
  const EditProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: const Center(
        child: Text('Edit Product Screen'),
      ),
    );
  }
}

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  // UI state
  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = 'All Products';
  static const int _pageSize = 2;
  int _shown = _pageSize;

  // Data
  final List<Product> _allProducts = [
    Product(
      thumbnailAsset: 'assets/img_square.jpg',
      name: 'Gray vintage 3D computer',
      price: 14.88,
      type: '3D Product',
      status: ProductStatus.active,
      id: 'PRD-001',
      sku: 'SKU-001',
      createdAt: '10/10/2025',
      quantityPerSource: '100',
      salableQuantity: '95',
      quantitySold: '5 (+10%)',
      quantityConfirmed: '5',
      quantityPending: '0',
      visibility: ProductVisibility.catalogSearch,
    ),
    Product(
      thumbnailAsset: 'assets/img_square.jpg',
      name: '3D computer improved version',
      price: 8.99,
      type: '3D Product',
      status: ProductStatus.active,
      id: 'PRD-002',
      sku: 'SKU-002',
      createdAt: '11/10/2025',
      quantityPerSource: '50',
      salableQuantity: '45',
      quantitySold: '5 (+5%)',
      quantityConfirmed: '5',
      quantityPending: '0',
      visibility: ProductVisibility.catalogSearch,
    ),
    Product(
      thumbnailAsset: 'assets/img_square.jpg',
      name: '3D dark mode wallpaper',
      price: 213.99,
      type: 'Wallpaper',
      status: ProductStatus.disabled,
      id: 'PRD-003',
      sku: 'SKU-003',
      createdAt: '12/10/2025',
      quantityPerSource: '200',
      salableQuantity: '200',
      quantitySold: '0 (0%)',
      quantityConfirmed: '0',
      quantityPending: '0',
      visibility: ProductVisibility.notVisible,
    ),
    Product(
      thumbnailAsset: 'assets/img_square.jpg',
      name: 'Retro CRT display',
      price: 19.99,
      type: '3D Product',
      status: ProductStatus.lowStock,
      id: 'PRD-004',
      sku: 'SKU-004',
      createdAt: '13/10/2025',
      quantityPerSource: '10',
      salableQuantity: '2',
      quantitySold: '8 (+80%)',
      quantityConfirmed: '8',
      quantityPending: '0',
      visibility: ProductVisibility.catalogOnly,
    ),
  ];

  List<Product> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    final byText = _allProducts.where((p) => p.name.toLowerCase().contains(q));
    switch (_filter) {
      case 'Enabled Products':
        return byText.where((p) => p.status == ProductStatus.active).toList();
      case 'Disabled Products':
        return byText.where((p) => p.status == ProductStatus.disabled).toList();
      case 'Low Stock':
        return byText.where((p) => p.status == ProductStatus.lowStock).toList();
      case 'Out of Stock':
        return byText.where((p) => p.status == ProductStatus.outOfStock).toList();
      case 'Denied Product':
        return byText.where((p) => p.status == ProductStatus.denied).toList();
      default:
        return byText.toList();
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

  void _loadMore() {
    setState(() => _shown = (_shown + _pageSize).clamp(0, _filtered.length));
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _allProducts.remove(product);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${product.name}" has been deleted')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _editProduct(Product product) {
    Navigator.pushNamed(context, '/edit_product');
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filtered.take(_shown).toList();
    final canLoadMore = _shown < _filtered.length;

    return Scaffold(
      body: Column(
        children: [
          // Main card
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
                    // Title
                    Text(
                      'List of Products',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800, fontSize: 22),
                    ),
                    const SizedBox(height: 16),

                    // Search and Filter in a column (stacked vertically)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Search
                        _InputSurface(
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                              hintText: 'Search product',
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

                        // Filter
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
                          items: const [
                            'All Products',
                            'Enabled Products',
                            'Disabled Products',
                            'Low Stock',
                            'Out of Stock',
                            'Denied Product',
                          ].map((v) => DropdownMenuItem(value: v, child: Text(v)))
                              .toList(),
                          onChanged: _onFilterChanged,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Products list with soft dividers
                    ListView.separated(
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

                    // Load more button with static asset icon
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

                    if (_filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Center(
                          child: Text(
                            'No products match your search.',
                            style: TextStyle(color: Colors.black54),
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

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final keyStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: Colors.black.withOpacity(.65));
    final valStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(
        fontWeight: FontWeight.w600, color: Colors.black.withOpacity(.85));

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
                child: Image.asset(product.thumbnailAsset, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  _PriceChip('\$${product.price.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  Text(
                    product.type,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),

                  // Product details with consistent spacing
                  _ProductDetailRow(
                    label: 'ID',
                    value: product.id,
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  _ProductDetailRow(
                    label: 'SKU',
                    value: product.sku,
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  _ProductDetailRow(
                    label: 'Status',
                    valueWidget: _StatusPill(status: product.status),
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  _ProductDetailRow(
                    label: 'Created at',
                    value: product.createdAt,
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  _ProductDetailRow(
                    label: 'Quantity Per Source',
                    value: product.quantityPerSource,
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  _ProductDetailRow(
                    label: 'Salable Quantity',
                    value: product.salableQuantity,
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  _ProductDetailRow(
                    label: 'Quantity Sold',
                    valueWidget: Row(
                      children: [
                        Text(product.quantitySold.split(' ')[0],
                            style: valStyle),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_upward,
                            color: Colors.green,
                            size: 16),
                        Text(' ${product.quantitySold.split(' ')[1]}',
                            style: valStyle?.copyWith(color: Colors.green)),
                      ],
                    ),
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  _ProductDetailRow(
                    label: 'Quantity Confirmed',
                    value: product.quantityConfirmed,
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  _ProductDetailRow(
                    label: 'Quantity Pending',
                    value: product.quantityPending,
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  _ProductDetailRow(
                    label: 'Price',
                    value: '\$${product.price.toStringAsFixed(2)}',
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  _ProductDetailRow(
                    label: 'Visibility',
                    valueWidget: _VisibilityPill(visibility: product.visibility),
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  _ProductDetailRow(
                    label: 'Action',
                    valueWidget: Row(
                      children: [
                        IconButton(
                          onPressed: onEdit,
                          icon: Image.asset(
                            'assets/icons/pen.png',
                            width: 20,
                            height: 20,
                            color: Colors.black54,
                          ),
                        ),
                        IconButton(
                          onPressed: onDelete,
                          icon: Image.asset(
                            'assets/icons/trash.png',
                            width: 20,
                            height: 20,
                            color: Colors.black54,
                          ),
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
        // Only one divider - removed the extra divider that was causing the double line
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
      padding: const EdgeInsets.only(bottom: 12), // Consistent spacing
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

  Color get _bg {
    switch (status) {
      case ProductStatus.active:
        return const Color(0xFFDFF7E3);
      case ProductStatus.disabled:
        return const Color(0xFFFFE0E0);
      case ProductStatus.lowStock:
        return const Color(0xFFFFF4CC);
      case ProductStatus.outOfStock:
        return const Color(0xFFFFE0E0);
      case ProductStatus.denied:
        return const Color(0xFFFFCCCC);
    }
  }

  Color get _textColor {
    switch (status) {
      case ProductStatus.active:
        return const Color(0xFF2E7D32);
      case ProductStatus.disabled:
        return const Color(0xFFC62828);
      case ProductStatus.lowStock:
        return const Color(0xFFF9A825);
      case ProductStatus.outOfStock:
        return const Color(0xFFC62828);
      case ProductStatus.denied:
        return const Color(0xFFB71C1C);
    }
  }

  String get _label {
    switch (status) {
      case ProductStatus.active:
        return 'Active';
      case ProductStatus.disabled:
        return 'Disabled';
      case ProductStatus.lowStock:
        return 'Low Stock';
      case ProductStatus.outOfStock:
        return 'Out of Stock';
      case ProductStatus.denied:
        return 'Denied';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration:
      BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          _label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700, color: _textColor),
        ),
      ),
    );
  }
}

class _VisibilityPill extends StatelessWidget {
  const _VisibilityPill({required this.visibility});
  final ProductVisibility visibility;

  Color get _bg {
    switch (visibility) {
      case ProductVisibility.catalogSearch:
        return const Color(0xFFDFF7E3);
      case ProductVisibility.catalogOnly:
        return const Color(0xFFE3F2FD);
      case ProductVisibility.searchOnly:
        return const Color(0xFFE8F5E9);
      case ProductVisibility.notVisible:
        return const Color(0xFFFFEBEE);
    }
  }

  Color get _textColor {
    switch (visibility) {
      case ProductVisibility.catalogSearch:
        return const Color(0xFF2E7D32);
      case ProductVisibility.catalogOnly:
        return const Color(0xFF1565C0);
      case ProductVisibility.searchOnly:
        return const Color(0xFF388E3C);
      case ProductVisibility.notVisible:
        return const Color(0xFFC62828);
    }
  }

  String get _label {
    switch (visibility) {
      case ProductVisibility.catalogSearch:
        return 'Catalog / Search';
      case ProductVisibility.catalogOnly:
        return 'Catalog Only';
      case ProductVisibility.searchOnly:
        return 'Search Only';
      case ProductVisibility.notVisible:
        return 'Not Visible';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration:
      BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          _label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700, color: _textColor),
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

// ===== Models

enum ProductStatus {
  active,
  disabled,
  lowStock,
  outOfStock,
  denied,
}

enum ProductVisibility {
  catalogSearch,
  catalogOnly,
  searchOnly,
  notVisible,
}

class Product {
  Product({
    required this.thumbnailAsset,
    required this.name,
    required this.price,
    required this.type,
    required this.status,
    required this.id,
    required this.sku,
    required this.createdAt,
    required this.quantityPerSource,
    required this.salableQuantity,
    required this.quantitySold,
    required this.quantityConfirmed,
    required this.quantityPending,
    required this.visibility,
  });

  final String thumbnailAsset;
  final String name;
  final double price;
  final String type;
  final ProductStatus status;
  final String id;
  final String sku;
  final String createdAt;
  final String quantityPerSource;
  final String salableQuantity;
  final String quantitySold;
  final String quantityConfirmed;
  final String quantityPending;
  final ProductVisibility visibility;
}