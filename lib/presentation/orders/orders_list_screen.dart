import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_client.dart';
import 'order_model.dart' hide MagentoOrder;
import 'order_utils.dart';
import 'order_widgets.dart';

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
  final VendorApiClient _apiClient = VendorApiClient();
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
      final magentoOrdersDynamic = await _apiClient.getVendorOrders();
      final magentoOrders = List<MagentoOrder>.from(magentoOrdersDynamic.map((json) => MagentoOrder.fromJson(json)));

      final convertedOrders = await Future.wait(
        magentoOrders.map(_convertMagentoOrderToUiOrder).toList(),
      );

      setState(() {
        _allOrders = convertedOrders;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load orders: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Order> _convertMagentoOrderToUiOrder(MagentoOrder magentoOrder) async {
    final firstItem = magentoOrder.items.isNotEmpty ? magentoOrder.items[0] : null;

    String thumb = 'assets/img_square.jpg';
    if (firstItem != null) {
      try {
        final productData = await _apiClient.getProductDetailsBySku(firstItem.sku);
        thumb = OrderUtils.getProductImageUrl(productData.mediaGalleryEntries);
      } catch (e) {
        debugPrint("Failed to fetch product image for SKU ${firstItem.sku}: $e");
      }
    }

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
        pageSize: _pageSize,
        currentPage: 1, // Start search from the first page
      );

      final convertedOrders = await Future.wait(
        magentoOrders.map(_convertMagentoOrderToUiOrder).toList(),
      );

      setState(() {
        _allOrders = convertedOrders;
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
      final magentoOrdersDynamic = await _apiClient.getVendorOrders();
      final newOrders = List<MagentoOrder>.from(magentoOrdersDynamic.map((json) => MagentoOrder.fromJson(json)));

      final convertedNewOrders = await Future.wait(
        newOrders.map(_convertMagentoOrderToUiOrder).toList(),
      );

      setState(() {
        _allOrders.addAll(convertedNewOrders);
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
                          child: Container(), // Replaced InputSurface with a simple container
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
                        itemBuilder: (context, i) => Container(), // Replaced OrderRow with a simple container
                      ),

                    const SizedBox(height: 24),

                    if (_filtered.isNotEmpty && _filtered.length % _pageSize == 0)
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
