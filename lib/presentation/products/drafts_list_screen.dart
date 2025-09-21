

import 'package:flutter/material.dart';
import 'package:kolshy_vendor/l10n/app_localizations.dart';
import 'package:kolshy_vendor/services/api_client.dart';
import 'package:kolshy_vendor/data/models/product_model.dart';
import 'package:dio/dio.dart';

class DraftsListScreen extends StatefulWidget {
  const DraftsListScreen({super.key});

  @override
  State<DraftsListScreen> createState() => _DraftsListScreenState();
}

class _DraftsListScreenState extends State<DraftsListScreen> {
  final VendorApiClient _apiClient = VendorApiClient();
  late Future<List<ProductModel>> _draftsFuture;

  @override
  void initState() {
    super.initState();
    _draftsFuture = _fetchDrafts();
  }

  Future<List<ProductModel>> _fetchDrafts() async {
    try {
      if (!_apiClient.hasToken) {
        await _apiClient.init();
        await _apiClient.loginVendor('test_vendor@example.com', 'password');
      }

      final vendorId = _apiClient.vendorId;
      if (vendorId == null) {
        throw Exception("Vendor ID is not available.");
      }

      final List<dynamic> draftData = await _apiClient.getVendorProducts(
        vendorId: vendorId,
        productStatus: '2',
      );

      return draftData.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();

    } on DioException catch (e) {
      print('Error fetching drafts: ${e.response?.data}');
      return Future.error('${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      print('An unexpected error occurred: $e');
      return Future.error('An unexpected error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.draftsTitle ?? 'Draft Products'),
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _draftsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${localizations?.errorLoadingDrafts ?? 'Error loading drafts'}: ${snapshot.error}'),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _draftsFuture = _fetchDrafts();
                      });
                    },
                    child: Text(localizations?.retry ?? 'Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(localizations?.noDraftsFound ?? 'No drafts found.'),
            );
          } else {
            final drafts = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: drafts.length,
              itemBuilder: (context, index) {
                final product = drafts[index];
                return _DraftRow(
                  product: product,
                  onEdit: () {
                    // TODO: Implement edit functionality
                  },
                  onDelete: () {
                    // TODO: Implement delete functionality
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

// ===== UI pieces remains the same =====
class _DraftRow extends StatelessWidget {
  const _DraftRow({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final keyStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: Colors.black.withOpacity(.65));
    final valStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(
        fontWeight: FontWeight.w600, color: Colors.black.withOpacity(.85));

    String quantityText = 'N/A';
    if (product.customAttributes != null) {
      final quantityAttr = product.customAttributes?.firstWhere(
            (attr) => attr['attribute_code'] == 'quantity_per_source',
        orElse: () => null,
      );
      if (quantityAttr != null && quantityAttr['value'] != null) {
        quantityText = quantityAttr['value'].toString();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 86,
                    height: 86,
                    color: const Color(0xFFEDEEEF),
                    child: product.imageUrl != null
                        ? Image.network(product.imageUrl!, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => const Icon(Icons.error))
                        : const Icon(Icons.image, size: 50, color: Colors.black54),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? 'Untitled Product',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    _PriceChip('\$${product.price?.toStringAsFixed(2) ?? '0.00'}'),
                    const SizedBox(height: 6),
                    Text(
                      product.typeId ?? 'N/A',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    _RowKVText(
                      k: localizations.skuLabel ?? 'SKU',
                      vText: product.sku ?? 'N/A',
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                    ),
                    const SizedBox(height: 12),
                    _RowKVText(
                      k: localizations.quantityLabel ?? 'Quantity',
                      vText: quantityText,
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                    ),
                    const SizedBox(height: 12),
                    _RowKVText(
                      k: localizations.createdLabel ?? 'Created At',
                      vText: product.createdAt ?? 'N/A',
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                    ),
                    const SizedBox(height: 12),
                    _RowKVText(
                      k: localizations.statusLabel ?? 'Status',
                      v: _StatusPill(status: product.status),
                      keyStyle: keyStyle,
                      valStyle: valStyle,
                      isWidgetValue: true,
                    ),
                    const SizedBox(height: 12),
                    _RowKVText(
                      k: localizations.actionLabel ?? 'Actions',
                      v: Row(
                        children: [
                          IconButton(
                            onPressed: onEdit,
                            icon: Image.asset(
                              'assets/icons/pen.png',
                              width: 20,
                              height: 20,
                              color: Colors.black54,
                            ),
                            tooltip: localizations.editButton ?? 'Edit',
                          ),
                          IconButton(
                            onPressed: onDelete,
                            icon: Image.asset(
                              'assets/icons/trash.png',
                              width: 20,
                              height: 20,
                              color: Colors.black54,
                            ),
                            tooltip: localizations.deleteButton ?? 'Delete',
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final ProductStatus status;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final String label;
    final Color bgColor;
    final Color textColor;

    switch (status) {
      case ProductStatus.active:
        label = localizations.statusActive ?? 'Active';
        bgColor = const Color(0xFFDFF7E3);
        textColor = const Color(0xFF2E7D32);
        break;
      case ProductStatus.disabled:
        label = localizations.statusDisabled ?? 'Disabled';
        bgColor = const Color(0xFFFFE0E0);
        textColor = const Color(0xFFC62828);
        break;
      case ProductStatus.lowStock:
        label = localizations.statusLowStock ?? 'Low Stock';
        bgColor = const Color(0xFFFFF4CC);
        textColor = const Color(0xFFF9A825);
        break;
      case ProductStatus.outOfStock:
        label = localizations.statusOutOfStock ?? 'Out of Stock';
        bgColor = const Color(0xFFFFE0E0);
        textColor = const Color(0xFFC62828);
        break;
      case ProductStatus.denied:
        label = localizations.statusDenied ?? 'Denied';
        bgColor = const Color(0xFFFFCCCC);
        textColor = const Color(0xFFB71C1C);
        break;
      case ProductStatus.draft:
        label = localizations.drafts ?? 'Draft';
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        break;
      case ProductStatus.unknown:
      default:
        label = 'N/A';
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        break;
    }

    return DecoratedBox(
      decoration:
      BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700, color: textColor),
        ),
      ),
    );
  }
}

class _InputSurface extends StatelessWidget {
  const _InputSurface({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip(this.priceText);

  final String priceText;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          priceText,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}

class _RowKVText extends StatelessWidget {
  const _RowKVText({
    required this.k,
    this.v,
    this.vText,
    this.keyStyle,
    this.valStyle,
    this.isWidgetValue = false,
  }) : assert((vText != null) ^ (v != null), 'Provide either vText or v');
  final String k;
  final Widget? v;
  final String? vText;
  final TextStyle? keyStyle;
  final TextStyle? valStyle;
  final bool isWidgetValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$k: ',
          style: keyStyle,
        ),
        if (isWidgetValue && v != null) Expanded(child: v!),
        if (!isWidgetValue && vText != null)
          Expanded(
            child: Text(
              vText!,
              style: valStyle,
            ),
          ),
      ],
    );
  }
}