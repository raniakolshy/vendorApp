import 'package:flutter/material.dart';
import 'add_product_screen.dart';

class DraftsListScreen extends StatefulWidget {
  const DraftsListScreen({super.key});

  @override
  State<DraftsListScreen> createState() => _DraftsListScreenState();
}

class _DraftsListScreenState extends State<DraftsListScreen> {
  // UI state
  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = 'All Drafts';
  static const int _pageSize = 2;
  int _shown = _pageSize;
  bool _loadingMore = false;

  // Data
  final List<_Draft> _all = <_Draft>[
    _Draft(
      name: 'Gray vintage 3D computer',
      sku: '223',
      qty: 100,
      price: 14.88,
      created: DateTime(2025, 10, 10),
      status: DraftStatus.draft,
      gender: Gender.male, // Added gender property
    ),
    _Draft(
      name: '3D computer improved version',
      sku: '224',
      qty: 60,
      price: 8.99,
      created: DateTime(2025, 10, 10),
      status: DraftStatus.draft,
      gender: Gender.female, // Added gender property
    ),
    _Draft(
      name: '3D dark mode wallpaper',
      sku: '225',
      qty: 40,
      price: 213.99,
      created: DateTime(2025, 10, 10),
      status: DraftStatus.pendingReview,
      gender: Gender.male, // Added gender property
    ),
  ];

  List<_Draft> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    final byText = _all.where((d) =>
    d.name.toLowerCase().contains(q) ||
        d.sku.toLowerCase().contains(q)
    );
    switch (_filter) {
      case 'Pending Review':
        return byText.where((d) => d.status == DraftStatus.pendingReview).toList();
      case 'Drafts':
        return byText.where((d) => d.status == DraftStatus.draft).toList();
      default:
        return byText.toList();
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    setState(() {
      _all.addAll(List.generate(3, (i) => _Draft(
        name: 'New draft ${i + 1}',
        sku: 'N${230 + i}',
        qty: 10 + i,
        price: 9.99 + i,
        created: DateTime.now(),
        status: DraftStatus.draft,
        gender: i.isEven ? Gender.male : Gender.female, // Added gender property
      )));
      _loadingMore = false;
      _shown = (_shown + _pageSize).clamp(0, _filtered.length);
    });
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
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddProductScreen()));
  }

  Future<void> _onDelete(_Draft d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete draft?'),
        content: Text('This will delete "${d.name}".'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')
          ),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete')
          ),
        ],
      ),
    );
    if (ok == true && mounted) setState(() => _all.remove(d));
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
                      'Drafts',
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
                          hintText: 'Search draft',
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
                        'All Drafts',
                        'Drafts',
                        'Pending Review',
                      ].map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: _onFilterChanged,
                    ),

                    const SizedBox(height: 18),

                    // Drafts list with soft dividers
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
                            'No drafts match your search.',
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
      margin: const EdgeInsets.only(bottom: 20), // Added space between items
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail with gender-specific avatar
              Container(
                margin: const EdgeInsets.only(right: 20), // Added space between image and content
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 86,
                    height: 86,
                    color: const Color(0xFFEDEEEF),
                    child: draft.gender == Gender.male
                        ? Image.asset('assets/avatar_placeholder.jpg', fit: BoxFit.cover)
                        : Image.asset('assets/female.jpg', fit: BoxFit.cover),
                  ),
                ),
              ),

              // Details
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
                      'Draft',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),

                    // Key-value pairs
                    _RowKVText(
                      k: 'SKU',
                      vText: draft.sku,
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                    ),
                    const SizedBox(height: 12),
                    _RowKVText(
                      k: 'Quantity',
                      vText: draft.qty.toString(),
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                    ),
                    const SizedBox(height: 12),
                    _RowKVText(
                      k: 'Created',
                      vText: _fmtDate(draft.created),
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                    ),
                    const SizedBox(height: 12),
                    _RowKVText(
                      k: 'Status',
                      v: _StatusPill(status: draft.status),
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                      isWidgetValue: true,
                    ),
                    const SizedBox(height: 12),
                    _RowKVText(
                      k: 'Action',
                      v: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: onEdit,
                            color: Colors.black54,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: onDelete,
                            color: Colors.black54,
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

  Color get _bg {
    switch (status) {
      case DraftStatus.draft:
        return const Color(0xFFFFF4CC); // yellow
      case DraftStatus.pendingReview:
        return const Color(0xFFE3F2FD); // blue
    }
  }

  Color get _textColor {
    switch (status) {
      case DraftStatus.draft:
        return const Color(0xFFF57F17); // dark yellow
      case DraftStatus.pendingReview:
        return const Color(0xFF1565C0); // dark blue
    }
  }

  String get _label {
    switch (status) {
      case DraftStatus.draft:
        return 'Draft';
      case DraftStatus.pendingReview:
        return 'Pending Review';
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
    required this.name,
    required this.sku,
    required this.qty,
    required this.price,
    required this.created,
    required this.status,
    required this.gender,
  });

  final String name;
  final String sku;
  final int qty;
  final double price;
  final DateTime created;
  final DraftStatus status;
  final Gender gender; // Added gender property
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