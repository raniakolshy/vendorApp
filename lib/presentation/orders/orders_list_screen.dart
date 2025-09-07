import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_client.dart';
import '../../services/order_model.dart';
import '../../services/order_utils.dart';

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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const OrdersListScreen(),
    );
  }
}

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  FilterOption _filter = FilterOption.all;
  static const int _pageSize = 10;
  int _currentPage = 1;
  bool _loadingMore = false;
  bool _isLoading = true;
  List<Order> _allOrders = [];
  final ApiClient _apiClient = ApiClient();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final magentoOrders = await _apiClient.getVendorOrders(
        pageSize: _pageSize,
        currentPage: _currentPage,
      );

      setState(() {
        _allOrders = magentoOrders.map(_convertMagentoOrderToUiOrder).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load orders: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Order _convertMagentoOrderToUiOrder(MagentoOrder magentoOrder) {
    final firstItem = magentoOrder.items.isNotEmpty ? magentoOrder.items[0] : null;

    // We don’t have the product payload here, just the SKU. Use a safe asset placeholder;
    // you can later enhance this to fetch product by SKU for thumbnails.
    final thumb = 'assets/img_square.jpg';

    return Order(
      thumbnailAsset: thumb,
      name: firstItem?.name ?? 'Multiple Products',
      price: firstItem != null ? double.tryParse(firstItem.price) ?? 0.0 : 0.0,
      type: firstItem != null ? 'Product' : 'Order',
      status: OrderUtils.mapMagentoStatusToOrderStatus(magentoOrder.status),
      orderId: magentoOrder.incrementId,
      purchasedOn: OrderUtils.formatOrderDate(magentoOrder.createdAt),
      baseTotal: magentoOrder.subtotal,
      purchasedTotal: magentoOrder.grandTotal,
      customer: magentoOrder.customerName,
      magentoOrder: magentoOrder,
    );
  }

  Future<void> _searchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final statusFilter = _getMagentoStatusFromFilter(_filter);
      final magentoOrders = await _apiClient.searchVendorOrders(
        _searchCtrl.text.trim(),
        status: statusFilter,
      );

      setState(() {
        _allOrders = magentoOrders.map(_convertMagentoOrderToUiOrder).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to search orders: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _getMagentoStatusFromFilter(FilterOption filter) {
    switch (filter) {
      case FilterOption.delivered:
        return 'complete';
      case FilterOption.processing:
        return 'processing';
      case FilterOption.cancelled:
        return 'canceled';
      case FilterOption.all:
      default:
        return null;
    }
  }

  List<Order> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    final byText = _allOrders.where((o) =>
    o.name.toLowerCase().contains(q) ||
        o.orderId.toLowerCase().contains(q) ||
        o.customer.toLowerCase().contains(q));

    switch (_filter) {
      case FilterOption.delivered:
        return byText.where((o) => o.status == OrderStatus.delivered).toList();
      case FilterOption.processing:
        return byText.where((o) => o.status == OrderStatus.processing).toList();
      case FilterOption.cancelled:
        return byText.where((o) => o.status == OrderStatus.cancelled).toList();
      case FilterOption.all:
      default:
        return byText.toList();
    }
  }

  void _onSearchChanged() {
    if (_searchCtrl.text.isEmpty) {
      _loadOrders();
    } else {
      _searchOrders();
    }
  }

  void _onFilterChanged(FilterOption? v) {
    if (v == null) return;
    setState(() {
      _filter = v;
      _currentPage = 1;
    });
    _searchOrders();
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;

    setState(() => _loadingMore = true);
    try {
      _currentPage++;
      final magentoOrders = await _apiClient.getVendorOrders(
        pageSize: _pageSize,
        currentPage: _currentPage,
      );

      final newOrders = magentoOrders.map(_convertMagentoOrderToUiOrder).toList();
      setState(() {
        _allOrders.addAll(newOrders);
        _loadingMore = false;
      });
    } catch (e) {
      setState(() => _loadingMore = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  String _localizeFilter(FilterOption option, AppLocalizations l10n) {
    switch (option) {
      case FilterOption.all:
        return l10n.allOrders;
      case FilterOption.delivered:
        return l10n.delivered;
      case FilterOption.processing:
        return l10n.processing;
      case FilterOption.cancelled:
        return l10n.cancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    final visible = _filtered;
    final canLoadMore = !_loadingMore && _allOrders.length % _pageSize == 0 && _allOrders.isNotEmpty;

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadOrders,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading && _allOrders.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orders Details',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800, fontSize: 24),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _InputSurface(
                            child: TextField(
                              controller: _searchCtrl,
                              decoration: InputDecoration(
                                hintText: 'Search orders',
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<FilterOption>(
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
                            items: FilterOption.values
                                .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(_localizeFilter(e, _localizations)),
                            ))
                                .toList(),
                            onChanged: _onFilterChanged,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    if (_isLoading && _allOrders.isNotEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: visible.length,
                        separatorBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1, thickness: 1, color: Color(0x11000000)),
                        ),
                        itemBuilder: (context, i) => _OrderRow(order: visible[i]),
                      ),

                    const SizedBox(height: 24),

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

                    if (_filtered.isEmpty && !_isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Center(
                          child: Text(
                            'No orders match your search.',
                            style: TextStyle(color: Colors.black54, fontSize: 16),
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

enum FilterOption { all, delivered, processing, cancelled }

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final _localizations = AppLocalizations.of(context)!;
    final keyStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: Colors.black.withOpacity(.65));
    final valStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(
        fontWeight: FontWeight.w600, color: Colors.black.withOpacity(.85));

    final isRTL = Directionality.of(context) == TextDirection.rtl;

    final imageWidget = order.thumbnailAsset.startsWith('http')
        ? Image.network(order.thumbnailAsset, fit: BoxFit.cover)
        : Image.asset(order.thumbnailAsset, fit: BoxFit.cover);

    final children = [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 90,
          height: 90,
          color: const Color(0xFFEDEEEF),
          child: imageWidget,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              order.name,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
            ),
            const SizedBox(height: 8),
            _PriceChip('\$${order.price.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text(
              order.type,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black54),
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
            ),
            const SizedBox(height: 16),
            _RowKVText(
              k: _localizations.status,
              v: _StatusPill(status: order.status),
              keyStyle: keyStyle,
              valStyle: valStyle,
              isWidgetValue: true,
            ),
            const SizedBox(height: 10),
            _RowKVText(
                k: _localizations.orderId,
                vText: order.orderId,
                keyStyle: keyStyle,
                valStyle: valStyle),
            const SizedBox(height: 10),
            _RowKVText(
                k: _localizations.purchasedOn,
                vText: order.purchasedOn,
                keyStyle: keyStyle,
                valStyle: valStyle),
            const SizedBox(height: 10),
            _RowKVText(
                k: _localizations.baseTotal,
                vText: order.baseTotal,
                keyStyle: keyStyle,
                valStyle: valStyle),
            const SizedBox(height: 10),
            _RowKVText(
                k: _localizations.purchasedTotal,
                vText: order.purchasedTotal,
                keyStyle: keyStyle,
                valStyle: valStyle),
            const SizedBox(height: 10),
            _RowKVText(
                k: _localizations.customer,
                vText: order.customer,
                keyStyle: keyStyle,
                valStyle: valStyle),
          ],
        ),
      ),
    ];

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: isRTL ? children.reversed.toList() : children,
        ),
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
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Row(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            k,
            style: keyStyle,
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: isWidgetValue && v != null
              ? v!
              : Text(
            vText ?? '',
            style: valStyle,
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
          ),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        return const Color(0xFFEDE7FE);
      case OrderStatus.closed:
        return const Color(0xFFECEFF1);
      case OrderStatus.pending:
        return const Color(0xFFE7F0FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final String label = () {
      switch (status) {
        case OrderStatus.delivered:
          return l10n.delivered;
        case OrderStatus.processing:
          return l10n.processing;
        case OrderStatus.cancelled:
          return l10n.cancelled;
        case OrderStatus.onHold:
          return l10n.onHold;
        case OrderStatus.closed:
          return l10n.closed;
        case OrderStatus.pending:
          return l10n.pending;
      }
    }();

    return DecoratedBox(
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label, // FIX: show localized label
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

/// Keep OrderStatus in a non-UI place (order_utils.dart exports it)
/// (no enum here)
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
    this.magentoOrder,
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
  final MagentoOrder? magentoOrder;
}
