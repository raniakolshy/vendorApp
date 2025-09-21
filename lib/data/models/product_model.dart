
enum ProductStatus {
  active,
  disabled,
  draft,
  denied,
  lowStock,
  outOfStock,
  unknown,
}


enum ProductVisibility {
  catalogSearch,
  catalogOnly,
  searchOnly,
  notVisible,
}

class ProductModel {
  final int? id;
  final String? sku;
  final String? name;
  final double? price;
  final ProductStatus status;
  final ProductVisibility? visibility;
  final String? typeId;
  final String? createdAt;
  final String? updatedAt;
  final String? imageUrl;
  final List<dynamic>? customAttributes;

  ProductModel({
    this.id,
    this.sku,
    this.name,
    this.price,
    required this.status,
    this.visibility,
    this.typeId,
    this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.customAttributes,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {

    String? imageUrl;
    if (json['media_gallery_entries'] is List && json['media_gallery_entries'].isNotEmpty) {
      final firstEntry = json['media_gallery_entries'][0];
      if (firstEntry is Map && firstEntry['file'] is String) {
        imageUrl = firstEntry['file'];
      }
    }

    ProductStatus parseStatus(dynamic status) {
      if (status == null) return ProductStatus.unknown;
      final statusString = status.toString();
      switch (statusString) {
        case '1':
          return ProductStatus.active;
        case '2':
          return ProductStatus.draft;
        default:
          return ProductStatus.unknown;
      }
    }


    ProductVisibility? parseVisibility(dynamic visibility) {
      if (visibility == null) return null;
      final visibilityString = visibility.toString();
      switch (visibilityString) {
        case '4':
          return ProductVisibility.catalogSearch;
        case '3':
          return ProductVisibility.catalogOnly;
        case '2':
          return ProductVisibility.searchOnly;
        case '1':
          return ProductVisibility.notVisible;
        default:
          return null;
      }
    }

    return ProductModel(
      id: (json['id'] as num?)?.toInt(),
      sku: json['sku'] as String?,
      name: json['name'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      status: parseStatus(json['status']),
      visibility: parseVisibility(json['visibility']),
      typeId: json['type_id'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      imageUrl: imageUrl,
      customAttributes: json['custom_attributes'] as List<dynamic>?,
    );
  }
}