import 'dart:async';
import 'package:kolshy_vendor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../services/api_client.dart';

void main() => runApp(const CustomerAnalyticsApp());

class CustomerAnalyticsApp extends StatelessWidget {
  const CustomerAnalyticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF111111),
      fontFamily: 'Roboto',
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: baseTheme.copyWith(
        scaffoldBackgroundColor: const Color(0xFFF3F3F4),
        textTheme: baseTheme.textTheme.apply(
          bodyColor: const Color(0xFF1B1B1B),
          displayColor: const Color(0xFF1B1B1B),
        ),
      ),
      home: const CustomerAnalyticsScreen(),
    );
  }
}

class CustomerAnalyticsScreen extends StatefulWidget {
  const CustomerAnalyticsScreen({super.key});

  @override
  State<CustomerAnalyticsScreen> createState() => _CustomerAnalyticsScreenState();
}

class _CustomerAnalyticsScreenState extends State<CustomerAnalyticsScreen> {
  // ---- CONFIG ----
  static const int _pageSize = 20; // page size for Magento customers

  final TextEditingController _searchCtrl = TextEditingController();

  // Time filter values (localized labels used in UI; we’ll map to periods)
  String _timeFilter = ''; // set in didChangeDependencies
  int _shown = 2; // list pagination inside the card (keep your original UX)
  bool _loadingMore = false;

  // Magento data
  bool _loading = true;
  bool _loadingAgg = true;
  String? _currency; // from orders
  List<Map<String, dynamic>> _allVendorOrders = []; // raw orders for the vendor
  Map<String, _Agg> _aggByEmail = {};           // aggregated orders by email for current period
  Map<String, _Agg> _prevAggByEmail = {};       // aggregated orders for previous period (for % change)

  // live search
  void _onSearchChanged() => setState(() => _shown = 2);

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_timeFilter.isEmpty) {
      _timeFilter = AppLocalizations.of(context)!.allTime;
      _bootstrap();
    }
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _loadingAgg = true;
    });
    try {
      final orders = await VendorApiClient().getVendorOrders();
      _allVendorOrders = List<Map<String, dynamic>>.from(orders);
      await _reloadAggregates();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch vendor data: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reloadAggregates() async {
    setState(() => _loadingAgg = true);

    final now = DateTime.now();
    DateTime? from;
    DateTime? to;
    DateTime? prevFrom;
    DateTime? prevTo;

    final l10n = AppLocalizations.of(context)!;
    if (_timeFilter == l10n.allTime) {
      from = null; to = null; prevFrom = null; prevTo = null;
    } else {
      if (_timeFilter == l10n.last7Days) {
        to = now;
        from = now.subtract(const Duration(days: 6));
        prevTo = from.subtract(const Duration(days: 1));
        prevFrom = prevTo!.subtract(const Duration(days: 6));
      } else if (_timeFilter == l10n.last30Days) {
        to = now;
        from = now.subtract(const Duration(days: 29));
        prevTo = from.subtract(const Duration(days: 1));
        prevFrom = prevTo!.subtract(const Duration(days: 29));
      } else if (_timeFilter == l10n.lastYear) {
        to = DateTime(now.year, now.month, now.day);
        from = DateTime(now.year - 1, now.month, now.day);
        prevTo = from.subtract(const Duration(days: 1));
        prevFrom = DateTime(prevTo!.year - 1, prevTo.month, prevTo.day);
      }
    }

    try {
      final filteredOrders = _filterOrdersByDate(_allVendorOrders, from, to);
      final prevFilteredOrders = _filterOrdersByDate(_allVendorOrders, prevFrom, prevTo);

      _currency = (filteredOrders.isNotEmpty
          ? filteredOrders.first['base_currency_code']
          : prevFilteredOrders.isNotEmpty
          ? prevFilteredOrders.first['base_currency_code']
          : null)
          ?.toString();

      _aggByEmail = _aggregateByCustomerEmail(filteredOrders);
      _prevAggByEmail = _aggregateByCustomerEmail(prevFilteredOrders);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch orders: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loadingAgg = false);
    }
  }

  List<Map<String, dynamic>> _filterOrdersByDate(List<Map<String, dynamic>> orders, DateTime? from, DateTime? to) {
    if (from == null && to == null) {
      return orders;
    }
    return orders.where((o) {
      final date = o['created_at'] != null ? DateTime.tryParse(o['created_at'].toString()) : null;
      if (date == null) return false;
      bool afterFrom = from == null || date.isAfter(from);
      bool beforeTo = to == null || date.isBefore(to);
      return afterFrom && beforeTo;
    }).toList();
  }

  Map<String, _Agg> _aggregateByCustomerEmail(List<Map<String, dynamic>> orders) {
    final map = <String, _Agg>{};
    for (final o in orders) {
      final email = (o['customer_email'] ?? '').toString();
      if (email.isEmpty) continue;

      final tot = (o['base_grand_total'] is num)
          ? (o['base_grand_total'] as num).toDouble()
          : double.tryParse('${o['base_grand_total']}') ?? 0.0;

      final curr = (o['base_currency_code'] ?? '').toString();

      final agg = map[email] ?? _Agg.zero(curr);
      map[email] = agg.add(tot, 1);
    }
    return map;
  }

  List<_CustomerSummaryDto> get _filteredCustomers {
    final q = _searchCtrl.text.trim().toLowerCase();
    final customersFromOrders = _aggByEmail.keys.map((email) {
      // Find a corresponding order to get other customer details
      final order = _allVendorOrders.firstWhere((o) => o['customer_email'] == email, orElse: () => {});
      return _CustomerSummaryDto.fromOrder(order, email);
    }).toList();

    if (q.isNotEmpty) {
      return customersFromOrders.where((c) {
        return c.name.toLowerCase().contains(q) || c.email.toLowerCase().contains(q);
      }).toList();
    }
    return customersFromOrders;
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _shown = (_shown + 2).clamp(0, _filteredCustomers.length);
      _loadingMore = false;
    });
  }

  void _onTimeFilterChanged(String? v) async {
    if (v == null || v == _timeFilter) return;
    setState(() {
      _timeFilter = v;
      _shown = 2;
    });
    await _reloadAggregates();
  }

  int get _customersCount => _aggByEmail.keys.length;
  int get _customersPrevCount => _prevAggByEmail.keys.length;
  double get _incomeSum => _aggByEmail.values.fold(0.0, (p, a) => p + a.total);
  double get _incomePrevSum => _prevAggByEmail.values.fold(0.0, (p, a) => p + a.total);

  double _pctChange(num curr, num prev) {
    if (prev == 0) return curr == 0 ? 0 : 100;
    return ((curr - prev) / prev) * 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final visible = _filteredCustomers.take(_shown).toList();
    final canLoadMore = _shown < _filteredCustomers.length && !_loadingMore;
    final customersNow = _customersCount;
    final customersPrev = _customersPrevCount;
    final customersPct = _pctChange(customersNow, customersPrev);

    final incomeNow = _incomeSum;
    final incomePrev = _incomePrevSum;
    final incomePct = _pctChange(incomeNow, incomePrev);

    final currCode = _currency ?? '';

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
                      l10n.customerAnalyticsTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800, fontSize: 22),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _timeFilter,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                      dropdownColor: Colors.white,
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      items: [
                        l10n.allTime,
                        l10n.last7Days,
                        l10n.last30Days,
                        l10n.lastYear,
                      ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (v) => _onTimeFilterChanged(v),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEDEEEF)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Customers
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 20, color: Colors.black54),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.customersLabel,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$customersNow',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      customersPct >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                      color: customersPct >= 0 ? Colors.green : Colors.red,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${customersPct.toStringAsFixed(1)}%',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: customersPct >= 0 ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Container(width: 1, height: 60, color: const Color(0xFFEDEEEF)),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.shopping_cart_outlined, size: 20, color: Colors.black54),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.incomeLabel,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    currCode.isEmpty
                                        ? incomeNow.toStringAsFixed(2)
                                        : '$currCode ${incomeNow.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        incomePct >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                        color: incomePct >= 0 ? Colors.green : Colors.red,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${incomePct.toStringAsFixed(1)}%',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: incomePct >= 0 ? Colors.green : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Text(
                          l10n.customersLabel,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _InputSurface(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: l10n.searchCustomerHint,
                          hintStyle: TextStyle(color: Colors.black.withOpacity(.35)),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search, size: 22, color: Colors.black54),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_loading || _loadingAgg)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: visible.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, i) {
                          final c = visible[i];
                          final stats = _aggByEmail[c.email] ?? _Agg.zero(_currency ?? '');
                          return _CustomerRow(
                            customer: Customer(
                              name: c.name,
                              email: c.email,
                              contact: c.telephone ?? '—',
                              gender: c.gender == 2 ? Gender.female : Gender.male, // Magento: 1=Male,2=Female
                              address: c.prettyAddress ?? '—',
                              baseTotal: (currCode.isEmpty
                                  ? stats.total.toStringAsFixed(2)
                                  : '$currCode ${stats.total.toStringAsFixed(2)}'),
                              orders: '${stats.count}',
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 22),

                      if (_filteredCustomers.isNotEmpty)
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
                                  border: Border.all(color: const Color(0x22000000)),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x0C000000),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                                      SizedBox(width: 10),
                                      Text(
                                        'Load more',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (_filteredCustomers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Center(
                            child: Text(
                              l10n.noCustomersMatch,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                    ],
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

// ---------------- helper DTOs/structs ----------------

class _Agg {
  final String currency;
  final double total;
  final int count;
  const _Agg(this.currency, this.total, this.count);
  factory _Agg.zero(String currency) => _Agg(currency, 0.0, 0);
  _Agg add(double t, int c) => _Agg(currency, total + t, count + c);
}

class _CustomerSummaryDto {
  final String email;
  final String name;
  final int? gender;
  final String? telephone;
  final String? prettyAddress;

  _CustomerSummaryDto({
    required this.email,
    required this.name,
    this.gender,
    this.telephone,
    this.prettyAddress,
  });

  factory _CustomerSummaryDto.fromOrder(Map<String, dynamic> o, String email) {
    // This is a simplified way to get customer details from an order.
    // In a real app, you might fetch full customer details separately.
    final first = (o['customer_firstname'] ?? '').toString();
    final last = (o['customer_lastname'] ?? '').toString();

    final nameCombined = ([first, last]..removeWhere((e) => e.trim().isEmpty)).join(' ');

    return _CustomerSummaryDto(
      email: email,
      name: nameCombined.isEmpty ? email : nameCombined,
      gender: null, // Gender is not available in vendor orders
      telephone: null, // Telephone is not available in vendor orders
      prettyAddress: null, // Address is not available in vendor orders
    );
  }
}


class Gap extends StatelessWidget {
  final double h;
  const Gap(this.h, {super.key});
  @override
  Widget build(BuildContext context) => SizedBox(height: h);
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
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: child),
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
        if (isWidgetValue && v != null) v! else Text(vText ?? '', style: valStyle),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: const Color(0xFFF1F2F4), borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({required this.gender});
  final Gender gender;
  Color get _bg => gender == Gender.male ? const Color(0xFFE3F2FD) : const Color(0xFFFCE4EC);
  Color get _textColor => gender == Gender.male ? const Color(0xFF1565C0) : const Color(0xFFC2185B);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final label = gender == Gender.male ? l10n.maleLabel : l10n.femaleLabel;
    return DecoratedBox(
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: _textColor),
        ),
      ),
    );
  }
}

enum Gender { male, female }

class Customer {
  Customer({
    required this.name,
    required this.email,
    required this.contact,
    required this.gender,
    required this.address,
    required this.baseTotal,
    required this.orders,
  });

  final String name;
  final String email;
  final String contact;
  final Gender gender;
  final String address;
  final String baseTotal;
  final String orders;
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final keyStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: Colors.black.withOpacity(.65));
    final valStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontWeight: FontWeight.w600, color: Colors.black.withOpacity(.85));

    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              right: Directionality.of(context) == TextDirection.ltr ? 20 : 0,
              left: Directionality.of(context) == TextDirection.rtl ? 20 : 0,
            ),
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEDEEEF),
              image: DecorationImage(
                image: AssetImage('assets/avatar_placeholder.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(customer.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(customer.email, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
              const SizedBox(height: 16),
              _RowKVText(k: l10n.contactLabel, v: _InfoChip(customer.contact), keyStyle: keyStyle, valStyle: valStyle, isWidgetValue: true),
              const SizedBox(height: 12),
              _RowKVText(k: l10n.genderLabel, v: _GenderChip(gender: customer.gender), keyStyle: keyStyle, valStyle: valStyle, isWidgetValue: true),
              const SizedBox(height: 12),
              _RowKVText(k: l10n.addressLabel, vText: customer.address, keyStyle: keyStyle, valStyle: valStyle),
              const SizedBox(height: 12),
              _RowKVText(k: l10n.baseTotalLabel, vText: customer.baseTotal, keyStyle: keyStyle, valStyle: valStyle),
              const SizedBox(height: 12),
              _RowKVText(k: l10n.ordersLabel, vText: customer.orders, keyStyle: keyStyle, valStyle: valStyle),
            ]),
          ),
        ],
      ),
    );
  }
}