import 'package:flutter/material.dart';

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
  final TextEditingController _searchCtrl = TextEditingController();
  String _timeFilter = 'All time';
  static const int _pageSize = 2;
  int _shown = _pageSize;
  bool _loadingMore = false;

  final List<Customer> _allCustomers = [
    Customer(
      name: 'John Doe',
      email: 'john.doe@example.com',
      contact: '+1 234 567 890',
      gender: Gender.male,
      address: '123 Main St, New York',
      baseTotal: '\$1,234.00',
      orders: '5',
      imageAsset: 'assets/male_avatar.png',
    ),
    Customer(
      name: 'Jane Smith',
      email: 'jane.smith@example.com',
      contact: '+1 987 654 321',
      gender: Gender.female,
      address: '456 Oak Ave, Los Angeles',
      baseTotal: '\$2,345.00',
      orders: '8',
      imageAsset: 'assets/female_avatar.png',
    ),
    Customer(
      name: 'Robert Johnson',
      email: 'robert.j@example.com',
      contact: '+1 555 123 4567',
      gender: Gender.male,
      address: '789 Pine Rd, Chicago',
      baseTotal: '\$3,456.00',
      orders: '12',
      imageAsset: 'assets/male_avatar.png',
    ),
    Customer(
      name: 'Emily Wilson',
      email: 'emily.w@example.com',
      contact: '+1 444 789 1234',
      gender: Gender.female,
      address: '321 Elm Blvd, Houston',
      baseTotal: '\$1,987.00',
      orders: '7',
      imageAsset: 'assets/female_avatar.png',
    ),
  ];

  List<Customer> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _allCustomers.where((c) =>
    c.name.toLowerCase().contains(q) ||
        c.email.toLowerCase().contains(q)
    ).toList();
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _shown = (_shown + _pageSize).clamp(0, _filtered.length);
      _loadingMore = false;
    });
  }

  void _onSearchChanged() {
    setState(() => _shown = _pageSize);
  }

  void _onTimeFilterChanged(String? v) {
    if (v == null) return;
    setState(() {
      _timeFilter = v;
      _shown = _pageSize;
    });
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
    final canLoadMore = _shown < _filtered.length && !_loadingMore;

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
                      'Customer Analytics',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800, fontSize: 22),
                    ),
                    const SizedBox(height: 16),

                    // Time filter
                    DropdownButtonFormField<String>(
                      value: _timeFilter,
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
                        'All time',
                        'Last 7 days',
                        'Last 30 days',
                        'Last year',
                      ].map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: _onTimeFilterChanged,
                    ),
                    const SizedBox(height: 16),

                    // Overview card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEDEEEF)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Customers count
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 20, color: Colors.black54),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Customers',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '1,368',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '↓ 37.8%',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Vertical divider
                          Container(
                            width: 1,
                            height: 60,
                            color: const Color(0xFFEDEEEF),
                          ),

                          // Income
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
                                        'Income',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$68,192',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '↑ 37.8%',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Customers section header
                    Row(
                      children: [
                        Text(
                          'Customers',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search
                    _InputSurface(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search customer',
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
                    const SizedBox(height: 16),

                    // Customers list
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: visible.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0x11000000),
                      ),
                      itemBuilder: (context, i) => _CustomerRow(customer: visible[i]),
                    ),

                    const SizedBox(height: 22),

                    // Load more button
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

                    if (_filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Center(
                          child: Text(
                            'No customers match your search.',
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

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.customer});
  final Customer customer;

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
            // Customer avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEDEEEF),
                image: DecorationImage(
                  image: AssetImage(customer.imageAsset),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Customer details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customer.email,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),

                  // Key-value pairs
                  _RowKVText(
                    k: 'Contact',
                    v: _InfoChip(customer.contact),
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                    isWidgetValue: true,
                  ),
                  const SizedBox(height: 12),
                  _RowKVText(
                    k: 'Gender',
                    v: _GenderChip(gender: customer.gender),
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                    isWidgetValue: true,
                  ),
                  const SizedBox(height: 12),
                  _RowKVText(
                    k: 'Address',
                    vText: customer.address,
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  const SizedBox(height: 12),
                  _RowKVText(
                    k: 'Base Total',
                    vText: customer.baseTotal,
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                  const SizedBox(height: 12),
                  _RowKVText(
                    k: 'Orders',
                    vText: customer.orders,
                    keyStyle: keyStyle,
                    valStyle: valStyle,
                  ),
                ],
              ),
            ),
          ],
        ),
        // Only keep this divider if you're NOT using ListView.separated
        // Otherwise remove this divider completely
        // const Divider(height: 1, thickness: 1, color: Color(0x11000000)),
      ],
    );
  }
}

// ===== Reused UI components =====

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

// ===== New UI components =====

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({required this.gender});
  final Gender gender;

  Color get _bg {
    switch (gender) {
      case Gender.male:
        return const Color(0xFFE3F2FD);
      case Gender.female:
        return const Color(0xFFFCE4EC);
    }
  }

  Color get _textColor {
    switch (gender) {
      case Gender.male:
        return const Color(0xFF1565C0);
      case Gender.female:
        return const Color(0xFFC2185B);
    }
  }

  String get _label {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(10)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          _label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(
              fontWeight: FontWeight.w700,
              color: _textColor
          ),
        ),
      ),
    );
  }
}

// ===== Models =====

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
    required this.imageAsset,
  });

  final String name;
  final String email;
  final String contact;
  final Gender gender;
  final String address;
  final String baseTotal;
  final String orders;
  final String imageAsset;
}