// lib/presentation/reviews/reviews_screen.dart
import 'package:flutter/material.dart';
import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:app_vendor/services/api_client.dart' as api;

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({
    super.key,
    this.adminToken = '87igct1wbbphdok6dk1roju4i83kyub9',
    this.pageSize = 10,
  });

  final String adminToken;
  final int pageSize;

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  late String _filter;

  static const int _pageSizeClient = 2;
  int _shown = _pageSizeClient;

  int _page = 1;
  int _totalCount = 0;
  bool _loading = false;

  final List<Review> _allReviews = [];
  final Map<String, _ProductLite> _productCache = {};

  String get _mediaBase => api.VendorApiClient().mediaBaseUrlForCatalog;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filter = AppLocalizations.of(context)!.allReviews;
    _refreshFromServer();
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refreshFromServer() async {
    setState(() {
      _loading = false;
      _page = 1;
      _totalCount = 0;
      _allReviews.clear();
      _shown = _pageSizeClient;
    });
    await _fetchNextPage();
  }

  Future<void> _fetchNextPage() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final l10n = AppLocalizations.of(context)!;
      final int? statusEq = _statusToMagento(_filter, l10n);

      final api.ReviewPage pageData =
      await api.VendorApiClient().getProductReviewsAdmin(
        page: _page,
        pageSize: widget.pageSize,
        statusEq: statusEq,
      );

      _totalCount = pageData.totalCount;
      final List<api.MagentoReview> items = pageData.items;

      for (final r in items) {
        final String sku = _extractSkuFromReview(r) ?? '';

        _ProductLite? p = _productCache[sku];
        if (p == null && sku.isNotEmpty) {
          final Map<String, dynamic> pj =
          await api.VendorApiClient().getProductLiteBySku(sku: sku);
          p = _ProductLite.fromJson(pj);
          _productCache[sku] = p;
        }

        _allReviews.add(_mapMagentoToReview(r, p));
      }
      _page += 1;

      _shown = (_shown.clamp(0, _filtered.length)) as int;
      if (_shown == 0 && _filtered.isNotEmpty) {
        _shown = _pageSizeClient;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text('${AppLocalizations.of(context)!.failedToExport} $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _extractSkuFromReview(dynamic r) {
    if (r is api.MagentoReview) {
      if ((r.productSku ?? '').isNotEmpty) return r.productSku!;
    }
    try {
      if (r is Map<String, dynamic>) {
        final ext = r['extension_attributes'];
        if (ext is Map && ext['sku'] is String) return ext['sku'] as String;
        if (r['product_sku'] is String) return r['product_sku'] as String;
      }
    } catch (_) {}
    return null;
  }

  Review _mapMagentoToReview(dynamic r, _ProductLite? p) {
    int? statusCode;
    if (r is api.MagentoReview) {
      statusCode = r.status;
    } else if (r is Map && r['status_id'] is num) {
      statusCode = (r['status_id'] as num).toInt();
    }

    double? price, value, quality;
    int votesCount = 0;

    List ratingsList = const [];
    if (r is api.MagentoReview) {
      ratingsList = r.ratings ?? const [];
    } else if (r is Map<String, dynamic>) {
      if (r['ratings'] is List) {
        ratingsList = r['ratings'] as List;
      } else if (r['rating_votes'] is List) {
        ratingsList = r['rating_votes'] as List;
      }
    }

    if (ratingsList.isNotEmpty) {
      for (final v in ratingsList) {
        final name = (v is Map && v['rating_name'] != null)
            ? v['rating_name'].toString().toLowerCase()
            : (v is Map && v['rating_code'] != null)
            ? v['rating_code'].toString().toLowerCase()
            : '';
        final percent = (v is Map && v['percent'] is num)
            ? (v['percent'] as num).toDouble()
            : null;
        final val = (v is Map && v['value'] is num)
            ? (v['value'] as num).toDouble()
            : null;
        final double? stars =
        percent != null ? (percent / 20.0) : (val != null ? val : null);
        if (name.contains('price')) price = stars;
        if (name.contains('value')) value = stars;
        if (name.contains('quality')) quality = stars;
      }
      votesCount = ratingsList.length;
      final all = <double>[
        if (price != null) price!,
        if (value != null) value!,
        if (quality != null) quality!,
      ];
      final avg =
      all.isNotEmpty ? (all.reduce((a, b) => a + b) / all.length) : 0.0;
      price ??= avg;
      value ??= avg;
      quality ??= avg;
    }

    String title = '';
    String detail = '';
    if (r is api.MagentoReview) {
      title = (r.title ?? '').toString();
      detail = (r.detail ?? '').toString();
    } else if (r is Map<String, dynamic>) {
      title = (r['title'] ?? '').toString();
      detail = (r['detail'] ?? '').toString();
    }

    final st = _statusFromMagento(statusCode);

    String productImagePath = p?.image ?? '';
    if (productImagePath.startsWith('/')) {
      productImagePath = productImagePath.substring(1);
    }
    final imageUrl = (_mediaBase.isNotEmpty && productImagePath.isNotEmpty)
        ? '$_mediaBase/$productImagePath'
        : '';

    return Review(
      productImage: imageUrl.isEmpty ? 'assets/img_square.jpg' : imageUrl,
      productName: p?.name ?? (title.isNotEmpty ? title : '—'),
      productType: p?.typeId ?? 'simple',
      priceRating: (price ?? 0).clamp(0, 5),
      valueRating: (value ?? 0).clamp(0, 5),
      qualityRating: (quality ?? 0).clamp(0, 5),
      reviewCount: votesCount,
      feedSummary: title,
      feedReview: detail,
      status: st,
    );
  }

  // client-side filter
  List<Review> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    final all =
    _allReviews.where((r) => r.productName.toLowerCase().contains(q));
    return all.toList();
  }

  void _onSearchChanged() {
    setState(() => _shown = _pageSizeClient);
  }

  void _onFilterChanged(String? v) async {
    if (v == null) return;
    setState(() {
      _filter = v;
      _shown = _pageSizeClient;
    });
    await _refreshFromServer();
  }

  void _loadMoreClient() {
    _shown = (_shown + _pageSizeClient).clamp(0, _filtered.length) as int;
    setState(() {});
  }

  Future<void> _loadMoreServer() async {
    if (_allReviews.length < _totalCount && !_loading) {
      await _fetchNextPage();
    } else {
      _loadMoreClient();
    }
  }

  ReviewStatus _statusFromMagento(int? code) {
    switch (code) {
      case 1:
        return ReviewStatus.approved;
      case 2:
        return ReviewStatus.pending;
      case 3:
        return ReviewStatus.rejected;
      default:
        return ReviewStatus.pending;
    }
  }

  int? _statusToMagento(String filterTxt, AppLocalizations l10n) {
    if (filterTxt == l10n.approved) return 1;
    if (filterTxt == l10n.pending) return 2;
    if (filterTxt == l10n.rejected) return 3;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visible = _filtered.take(_shown).toList();
    final canLoadMoreServer = _allReviews.length < _totalCount;

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
                      l10n.reviews,
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
                          hintText: l10n.searchReviews,
                          hintStyle:
                          TextStyle(color: Colors.black.withOpacity(.35)),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search,
                              size: 22, color: Colors.black54),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 14),
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
                      style:
                      const TextStyle(color: Colors.black, fontSize: 16),
                      items: [
                        l10n.allReviews,
                        l10n.approved,
                        l10n.pending,
                        l10n.rejected,
                      ]
                          .map((v) =>
                          DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: _onFilterChanged,
                    ),
                    const SizedBox(height: 18),
                    if (_loading && _allReviews.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: visible.length,
                        itemBuilder: (context, i) =>
                            _ReviewRow(review: visible[i]),
                      ),
                    const SizedBox(height: 22),
                    if (_filtered.isNotEmpty)
                      Center(
                        child: Opacity(
                          opacity: (canLoadMoreServer || _loading) ? 1 : .6,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: _loading ? null : _loadMoreServer,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border:
                                Border.all(color: const Color(0x22000000)),
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
                                    if (_loading)
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    else
                                      Image.asset('assets/icons/loading.png',
                                          width: 18, height: 18),
                                    const SizedBox(width: 10),
                                    Text(
                                      l10n.loadMore,
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
                    if (!_loading && _filtered.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Center(
                          child: Text(
                            l10n.noReviewsFound,
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

// --- small UI pieces ---
class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final image = review.productImage.startsWith('http')
        ? Image.network(review.productImage,
        width: 86, height: 86, fit: BoxFit.cover)
        : Image.asset(review.productImage,
        width: 86, height: 86, fit: BoxFit.cover);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(14), child: image),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.productName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review.productType,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _RatingItem(l10n.priceRating,
                              review.priceRating, review.reviewCount)),
                      Expanded(
                          child: _RatingItem(l10n.valueRating,
                              review.valueRating, review.reviewCount)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                          child: _RatingItem(l10n.qualityRating,
                              review.qualityRating, review.reviewCount)),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ReviewSection(l10n.feedSummary, review.feedSummary),
                  const SizedBox(height: 12),
                  _ReviewSection(l10n.feedReview, review.feedReview),
                  const SizedBox(height: 12),
                  _ReviewSection(
                    l10n.status,
                    l10n.reviewStatus(review.status.toString().split('.').last),
                    isStatus: true,
                    status: review.status,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(height: 1, thickness: 1, color: Color(0x11000000)),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _RatingItem extends StatelessWidget {
  final String label;
  final double rating;
  final int count;

  const _RatingItem(this.label, this.rating, this.count);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
            TextStyle(fontSize: 12, color: Colors.black.withOpacity(.65))),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
            const SizedBox(width: 4),
            Text(
              '${rating.toStringAsFixed(1)} ($count)',
              style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String label;
  final String text;
  final bool isStatus;
  final ReviewStatus? status;

  const _ReviewSection(this.label, this.text,
      {this.isStatus = false, this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor = const Color(0xFFF7F7F8);
    Color textColor = Colors.black;
    if (isStatus) {
      switch (status) {
        case ReviewStatus.approved:
          bgColor = const Color(0xFFDFF7E3);
          textColor = const Color(0xFF34A853);
          break;
        case ReviewStatus.pending:
          bgColor = const Color(0xFFFFF4CC);
          textColor = const Color(0xFFFBBC05);
          break;
        case ReviewStatus.rejected:
          bgColor = const Color(0xFFFFE0E0);
          textColor = const Color(0xFFEA4335);
          break;
        default:
          bgColor = const Color(0xFFF7F7F8);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
            TextStyle(fontSize: 12, color: Colors.black.withOpacity(.65))),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: bgColor, borderRadius: BorderRadius.circular(20)),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: isStatus ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
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
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: child),
    );
  }
}

enum ReviewStatus { approved, pending, rejected }

class Review {
  Review({
    required this.productImage,
    required this.productName,
    required this.productType,
    required this.priceRating,
    required this.valueRating,
    required this.qualityRating,
    required this.reviewCount,
    required this.feedSummary,
    required this.feedReview,
    required this.status,
  });

  final String productImage;
  final String productName;
  final String productType;
  final double priceRating;
  final double valueRating;
  final double qualityRating;
  final int reviewCount;
  final String feedSummary;
  final String feedReview;
  final ReviewStatus status;
}

class _ProductLite {
  final String sku;
  final String name;
  final String typeId;
  final String? image;

  _ProductLite({
    required this.sku,
    required this.name,
    required this.typeId,
    required this.image,
  });

  factory _ProductLite.fromJson(Map<String, dynamic> j) {
    String? image;
    if (j['custom_attributes'] is List) {
      for (final ca in (j['custom_attributes'] as List)) {
        if (ca is Map &&
            ca['attribute_code'] == 'image' &&
            ca['value'] is String) {
          image = ca['value'] as String;
          break;
        }
      }
    }
    if (image == null &&
        j['media_gallery_entries'] is List &&
        (j['media_gallery_entries'] as List).isNotEmpty) {
      final first = (j['media_gallery_entries'] as List).first;
      if (first is Map && first['file'] is String) {
        image = first['file'] as String;
      }
    }
    return _ProductLite(
      sku: (j['sku'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      typeId: (j['type_id'] ?? '').toString(),
      image: image,
    );
  }
}