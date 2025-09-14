class MagentoOrder {
  final String entityId;
  final String incrementId;
  final String createdAt;
  final String status;
  final String grandTotal;
  final String subtotal;
  final String customerName;
  final String customerEmail;
  final List<MagentoOrderItem> items;
  final MagentoOrderAddress? billingAddress;
  final MagentoOrderAddress? shippingAddress;

  MagentoOrder({
    required this.entityId,
    required this.incrementId,
    required this.createdAt,
    required this.status,
    required this.grandTotal,
    required this.subtotal,
    required this.customerName,
    required this.customerEmail,
    required this.items,
    this.billingAddress,
    this.shippingAddress,
  });

  factory MagentoOrder.fromJson(Map<String, dynamic> json) {
    return MagentoOrder(
      entityId: json['entity_id']?.toString() ?? '',
      incrementId: json['increment_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      grandTotal: json['grand_total']?.toString() ?? '0',
      subtotal: json['subtotal']?.toString() ?? '0',
      customerName: _getCustomerName(json),
      customerEmail: json['customer_email']?.toString() ?? '',
      items: _parseOrderItems(json['items']),
      billingAddress: json['billing_address'] != null
          ? MagentoOrderAddress.fromJson(json['billing_address'])
          : null,
      shippingAddress: json['shipping_address'] != null
          ? MagentoOrderAddress.fromJson(json['shipping_address'])
          : null,
    );
  }

  static String _getCustomerName(Map<String, dynamic> json) {
    if (json['customer_firstname'] != null && json['customer_lastname'] != null) {
      return '${json['customer_firstname']} ${json['customer_lastname']}';
    }
    return json['customer_name']?.toString() ?? 'Guest Customer';
  }

  static List<MagentoOrderItem> _parseOrderItems(dynamic items) {
    if (items is List) {
      return items.map((item) => MagentoOrderItem.fromJson(item)).toList();
    }
    return [];
  }
}

class MagentoOrderItem {
  final String itemId;
  final String sku;
  final String name;
  final String price;
  final String qtyOrdered;
  final String rowTotal;

  MagentoOrderItem({
    required this.itemId,
    required this.sku,
    required this.name,
    required this.price,
    required this.qtyOrdered,
    required this.rowTotal,
  });

  factory MagentoOrderItem.fromJson(Map<String, dynamic> json) {
    return MagentoOrderItem(
      itemId: json['item_id']?.toString() ?? '',
      sku: json['sku']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      qtyOrdered: json['qty_ordered']?.toString() ?? '0',
      rowTotal: json['row_total']?.toString() ?? '0',
    );
  }
}

class MagentoOrderAddress {
  final String firstname;
  final String lastname;
  final String street;
  final String city;
  final String region;
  final String postcode;
  final String countryId;
  final String telephone;

  MagentoOrderAddress({
    required this.firstname,
    required this.lastname,
    required this.street,
    required this.city,
    required this.region,
    required this.postcode,
    required this.countryId,
    required this.telephone,
  });

  factory MagentoOrderAddress.fromJson(Map<String, dynamic> json) {
    final street = json['street'] is List ? (json['street'] as List).join(', ') : json['street']?.toString() ?? '';

    return MagentoOrderAddress(
      firstname: json['firstname']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      street: street,
      city: json['city']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      postcode: json['postcode']?.toString() ?? '',
      countryId: json['country_id']?.toString() ?? '',
      telephone: json['telephone']?.toString() ?? '',
    );
  }
}