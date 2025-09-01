import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  late String _filter;
  static const int _pageSize = 2;
  int _shown = _pageSize;

  final List<Review> _allReviews = [
    Review(
      productImage: 'assets/img_square.jpg',
      productName: '3D brush marks',
      productType: 'Art Wallpaper',
      priceRating: 4.8,
      valueRating: 4.5,
      qualityRating: 4.9,
      reviewCount: 87,
      feedSummary: 'Lorem ipsum dolor sit amet',
      feedReview: 'Consectetur adipiscing elit. Sed do eiusmod tempor.',
      status: ReviewStatus.approved,
    ),
    Review(
      productImage: 'assets/img_square.jpg',
      productName: 'Vintage computer',
      productType: '3D Model',
      priceRating: 4.2,
      valueRating: 4.7,
      qualityRating: 4.8,
      reviewCount: 42,
      feedSummary: 'Sed ut perspiciatis unde',
      feedReview: 'Omnis iste natus error sit voluptatem.',
      status: ReviewStatus.pending,
    ),
    Review(
      productImage: 'assets/img_square.jpg',
      productName: 'Dark mode wallpaper',
      productType: 'Digital Art',
      priceRating: 4.9,
      valueRating: 4.8,
      qualityRating: 5.0,
      reviewCount: 125,
      feedSummary: 'At vero eos et accusamus',
      feedReview: 'Et iusto odio dignissimos ducimus.',
      status: ReviewStatus.approved,
    ),
    Review(
      productImage: 'assets/img_square.jpg',
      productName: 'Retro CRT display',
      productType: '3D Model',
      priceRating: 3.9,
      valueRating: 4.1,
      qualityRating: 4.3,
      reviewCount: 56,
      feedSummary: 'Temporibus autem quibusdam',
      feedReview: 'Et aut officiis debitis aut rerum.',
      status: ReviewStatus.rejected,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize filter after localizations are loaded
    _filter = AppLocalizations.of(context)!.allReviews;
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Review> get _filtered {
    final l10n = AppLocalizations.of(context)!;
    final q = _searchCtrl.text.trim().toLowerCase();
    final byText = _allReviews.where((r) => r.productName.toLowerCase().contains(q));
    switch (_filter) {
      case 'Approved':
      case 'Approved': // Fallback for old key, remove later
        return byText.where((r) => r.status == ReviewStatus.approved).toList();
      case 'Pending':
      case 'Pending': // Fallback for old key, remove later
        return byText.where((r) => r.status == ReviewStatus.pending).toList();
      case 'Rejected':
      case 'Rejected': // Fallback for old key, remove later
        return byText.where((r) => r.status == ReviewStatus.rejected).toList();
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                      l10n.reviews,
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
                          hintText: l10n.searchReviews,
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
                      items: [
                        l10n.allReviews,
                        l10n.approved,
                        l10n.pending,
                        l10n.rejected,
                      ].map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: _onFilterChanged,
                    ),

                    const SizedBox(height: 18),

                    // Reviews list
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: visible.length,
                      itemBuilder: (context, i) => _ReviewRow(review: visible[i]),
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
                                    Image.asset(
                                      'assets/icons/loading.png',
                                      width: 18,
                                      height: 18,
                                    ),
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

                    if (_filtered.isEmpty)
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

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                review.productImage,
                width: 86,
                height: 86,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),

            // Review Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Type
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

                  // Ratings
                  Row(
                    children: [
                      Expanded(child: _RatingItem(l10n.priceRating, review.priceRating, review.reviewCount)),
                      Expanded(child: _RatingItem(l10n.valueRating, review.valueRating, review.reviewCount)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _RatingItem(l10n.qualityRating, review.qualityRating, review.reviewCount)),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Review Sections
                  _ReviewSection(l10n.feedSummary, review.feedSummary),
                  const SizedBox(height: 12),
                  _ReviewSection(l10n.feedReview, review.feedReview),
                  const SizedBox(height: 12),
                  _ReviewSection(l10n.status, l10n.reviewStatus(review.status.toString().split('.').last),
                      isStatus: true, status: review.status),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24), // Increased space before the divider
        const Divider(height: 1, thickness: 1, color: Color(0x11000000)),
        const SizedBox(height: 16), // Added space after the divider
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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
            const SizedBox(width: 4),
            Text(
              '${rating.toStringAsFixed(1)} ($count)',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
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

  const _ReviewSection(this.label, this.text, {this.isStatus = false, this.status});

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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: child,
      ),
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