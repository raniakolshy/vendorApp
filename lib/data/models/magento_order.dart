

class MagentoOrder {
  final int? entityId;
  final String? incrementId;
  final String? state;
  final String? status;
  final double? grandTotal;
  final String? createdAt;
  final String? customerEmail;
  final List<MagentoOrderItem>? items;

  MagentoOrder({
    this.entityId,
    this.incrementId,
    this.state,
    this.status,
    this.grandTotal,
    this.createdAt,
    this.customerEmail,
    this.items,
  });

  factory MagentoOrder.fromJson(Map<String, dynamic> json) {
    return MagentoOrder(
      entityId: json['entity_id'] as int?,
      incrementId: json['increment_id'] as String?,
      state: json['state'] as String?,
      status: json['status'] as String?,
      grandTotal: json['grand_total'] is int
          ? (json['grand_total'] as int).toDouble()
          : json['grand_total'] as double?,
      createdAt: json['created_at'] as String?,
      customerEmail: json['customer_email'] as String?,
      items: (json['items'] as List?)
          ?.map((itemJson) => MagentoOrderItem.fromJson(itemJson))
          .toList(),
    );
  }
}

class MagentoOrderItem {
  final int? itemId;
  final String? sku;
  final String? name;
  final double? price;
  final int? qtyOrdered;

  MagentoOrderItem({
    this.itemId,
    this.sku,
    this.name,
    this.price,
    this.qtyOrdered,
  });

  factory MagentoOrderItem.fromJson(Map<String, dynamic> json) {
    return MagentoOrderItem(
      itemId: json['item_id'] as int?,
      sku: json['sku'] as String?,
      name: json['name'] as String?,
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : json['price'] as double?,
      qtyOrdered: json['qty_ordered'] is int
          ? (json['qty_ordered'] as int)
          : int.tryParse(json['qty_ordered']?.toString() ?? '0'),
    );
  }
}