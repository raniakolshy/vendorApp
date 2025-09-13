// lib/presentation/reviews/reviews_screen.dart
import 'package:flutter/material.dart';
import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:app_vendor/services/api_client.dart' as api;

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isLoading = true;
  final List<Review> _allReviews = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _loadReviews();
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    try {
      // Get all reviews (not vendor-specific since your Magento doesn't support it)
      final reviews = await api.VendorApiClient().getLatestReviews(limit: 50);

      // Convert to simple review format
      _allReviews.clear();
      for (var reviewData in reviews) {
        _allReviews.add(Review(
          productImage: 'assets/img_square.jpg',
          productName: reviewData['title']?.toString() ?? 'No Title',
          productType: 'Product',
          priceRating: 0,
          valueRating: 0,
          qualityRating: (reviewData['rating'] is num)
              ? (reviewData['rating'] as num).toDouble()
              : 0,
          reviewCount: 1,
          feedSummary: reviewData['title']?.toString() ?? '',
          feedReview: reviewData['detail']?.toString() ?? 'No review content',
          status: ReviewStatus.pending,
        ));
      }
    } catch (e) {
      print('Failed to load reviews: $e');
      // Show empty state with error message
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    setState(() {});
  }

  List<Review> get _filtered {
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) return _allReviews;

    return _allReviews.where((review) {
      return review.productName.toLowerCase().contains(query) ||
          review.feedReview.toLowerCase().contains(query) ||
          review.feedSummary.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reviews),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadReviews,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: l10n.searchReviews,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.reviews, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    _searchCtrl.text.isEmpty
                        ? l10n.noReviewsAvailable
                        : l10n.noReviewsFound,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final review = _filtered[index];
                return _ReviewCard(review: review);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    review.productImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.productName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        review.productType,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Rating
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text(
                  review.qualityRating.toStringAsFixed(1),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Review content
            if (review.feedSummary.isNotEmpty) ...[
              Text(
                review.feedSummary,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
            ],

            Text(
              review.feedReview,
              style: TextStyle(fontSize: 14),
            ),

            SizedBox(height: 16),

            // Status
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(review.status),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                review.status.toString().split('.').last.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ReviewStatus status) {
    switch (status) {
      case ReviewStatus.approved:
        return Colors.green;
      case ReviewStatus.pending:
        return Colors.orange;
      case ReviewStatus.rejected:
        return Colors.red;
    }
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