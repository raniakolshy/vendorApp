import 'package:flutter/material.dart';

void main() => runApp(const OrdersApp());

class OrdersApp extends StatelessWidget {
  const OrdersApp({super.key});

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
      home: const OrdersListScreen(),
    );
  }
}

/// Keep this name as requested
class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  // ----- UI state
  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = 'All Orders';
  static const int _pageSize = 2;
  int _shown = _pageSize;

  // ----- Data
  final List<Order> _allOrders = [
    Order(
      thumbnailAsset: 'assets/img_square.jpg',
      name: 'Gray vintage 3D computer',
      price: 14.88,
      type: '3D Product',
      status: OrderStatus.delivered,
      orderId: '11',
      purchasedOn: '10 / 10 / 2025',
      baseTotal: '21',
      purchasedTotal: '21',
      customer: 'Omar Omar',
    ),
    Order(
      thumbnailAsset: 'assets/img_square.jpg',
      name: '3D computer improved version',
      price: 8.99,
      type: '3D Product',
      status: OrderStatus.delivered,
      orderId: '11',
      purchasedOn: '10 / 10 / 2025',
      baseTotal: '21',
      purchasedTotal: '21',
      customer: 'Omar Omar',
    ),
    Order(
      thumbnailAsset: 'assets/img_square.jpg',
      name: '3D dark mode wallpaper',
      price: 213.99,
      type: 'Wallpaper',
      status: OrderStatus.delivered,
      orderId: '11',
      purchasedOn: '10 / 10 / 2025',
      baseTotal: '21',
      purchasedTotal: '21',
      customer: 'Omar Omar',
    ),
    Order(
      thumbnailAsset: 'assets/img_square.jpg',
      name: 'Retro CRT display',
      price: 19.99,
      type: '3D Product',
      status: OrderStatus.processing,
      orderId: '12',
      purchasedOn: '11 / 10 / 2025',
      baseTotal: '21',
      purchasedTotal: '21',
      customer: 'Omar Omar',
    ),
  ];

  List<Order> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    final byText = _allOrders.where((o) => o.name.toLowerCase().contains(q));
    switch (_filter) {
      case 'Delivered':
        return byText.where((o) => o.status == OrderStatus.delivered).toList();
      case 'Processing':
        return byText.where((o) => o.status == OrderStatus.processing).toList();
      case 'Cancelled':
        return byText.where((o) => o.status == OrderStatus.cancelled).toList();
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
                      'Orders Details',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800, fontSize: 22),
                    ),
                    const SizedBox(height: 16),

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
                        'All Orders',
                        'Delivered',
                        'Processing',
                        'Cancelled',
                      ].map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: _onFilterChanged,
                    ),

                    const SizedBox(height: 18),

                    // Orders list with soft dividers
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: visible.length,
                      itemBuilder: (context, i) => _OrderRow(order: visible[i]),
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
                            'No orders match your search.',
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

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});
  final Order order;

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
                child: Image.asset(order.thumbnailAsset, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  _PriceChip('\$${order.price.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  Text(
                    order.type,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  _RowKVText(
                    k: 'Status',
                    v: _StatusPill(status: order.status),
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                    isWidgetValue: true,
                  ),
                  const SizedBox(height: 12),
                  _RowKVText(
                      k: 'Order Id',
                      vText: order.orderId,
                      keyStyle: keyStyle,
                      valStyle: valStyle),
                  const SizedBox(height: 12),
                  _RowKVText(
                      k: 'Purchased on',
                      vText: order.purchasedOn,
                      keyStyle: keyStyle,
                      valStyle: valStyle),
                  const SizedBox(height: 12),
                  _RowKVText(
                      k: 'Base Total',
                      vText: order.baseTotal,
                      keyStyle: keyStyle,
                      valStyle: valStyle),
                  const SizedBox(height: 12),
                  _RowKVText(
                      k: 'Purchased Total',
                      vText: order.purchasedTotal,
                      keyStyle: keyStyle,
                      valStyle: valStyle),
                  const SizedBox(height: 12),
                  _RowKVText(
                      k: 'Customer',
                      vText: order.customer,
                      keyStyle: keyStyle,
                      valStyle: valStyle),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, thickness: 1, color: Color(0x11000000)),
      ],
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
  final OrderStatus status;

  Color get _bg {
    switch (status) {
      case OrderStatus.delivered:
        return const Color(0xFFDFF7E3);
      case OrderStatus.processing:
        return const Color(0xFFFFF4CC);
      case OrderStatus.cancelled:
        return const Color(0xFFFFE0E0);
      case OrderStatus.onHold:
        return const Color(0xFFEDE7FE); // soft purple
      case OrderStatus.closed:
        return const Color(0xFFECEFF1); // neutral gray
      case OrderStatus.pending:
        return const Color(0xFFE7F0FF); // soft blue
    }
  }

  String get _label {
    switch (status) {
      case OrderStatus.delivered:
        return 'Deliverd';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.onHold:
        return 'On Hold';
      case OrderStatus.closed:
        return 'Closed';
      case OrderStatus.pending:
        return 'Pending';
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
              ?.copyWith(fontWeight: FontWeight.w700),
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

enum OrderStatus { delivered, processing, cancelled, onHold, closed, pending }

class Order {
  Order({
    required this.thumbnailAsset,
    required this.name,
    required this.price,
    required this.type,
    required this.status,
    required this.orderId,
    required this.purchasedOn,
    required this.baseTotal,
    required this.purchasedTotal,
    required this.customer,
  });

  final String thumbnailAsset;
  final String name;
  final double price;
  final String type;
  final OrderStatus status;
  final String orderId;
  final String purchasedOn;
  final String baseTotal;
  final String purchasedTotal;
  final String customer;
}
