

class MagentoReview {
  final int id;
  final String? nickname;
  final String? title;
  final String? detail;
  final int? status;
  final String? productSku;
  final List<dynamic>? ratings;

  MagentoReview({
    required this.id,
    this.nickname,
    this.title,
    this.detail,
    this.status,
    this.productSku,
    this.ratings,
  });

  factory MagentoReview.fromJson(Map<String, dynamic> j) {
    int _int(dynamic v) => (v is int) ? v : (v is num) ? v.toInt() : int.tryParse('$v') ?? 0;

    String? _sku() {
      final ext = j['extension_attributes'];
      if (ext is Map && ext['sku'] is String) return ext['sku'] as String;
      if (j['product_sku'] is String) return j['product_sku'] as String;
      return null;
    }

    List<dynamic>? _ratings() {
      if (j['rating_votes'] is List) return j['rating_votes'] as List;
      if (j['ratings'] is List) return j['ratings'] as List;
      return null;
    }

    return MagentoReview(
      id: _int(j['id']),
      nickname: (j['nickname'] ?? j['customer_nickname'])?.toString(),
      title: (j['title'] ?? '').toString(),
      detail: (j['detail'] ?? '').toString(),
      status: (j['status_id'] is num) ? (j['status_id'] as num).toInt() : null,
      productSku: _sku(),
      ratings: _ratings(),
    );
  }
}