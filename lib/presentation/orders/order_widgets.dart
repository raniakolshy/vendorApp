import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'order_utils.dart';
import 'orders_list_screen.dart';
import 'order_model.dart';


class OrderRow extends StatelessWidget {
  const OrderRow({required this.order, super.key});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final keyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black.withOpacity(.65));
    final valStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Colors.black.withOpacity(.85));
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    Widget imageWidget;
    if (order.thumbnailAsset.startsWith('http')) {
      imageWidget = Image.network(
        order.thumbnailAsset,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) =>
            Image.asset('assets/img_square.jpg', fit: BoxFit.cover),
      );
    } else {
      imageWidget = Image.asset(order.thumbnailAsset, fit: BoxFit.cover);
    }

    final children = [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 90,
          height: 90,
          color: const Color(0xFFEDEEEF),
          child: imageWidget,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              order.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
            ),
            const SizedBox(height: 8),
            _PriceChip('\$${order.price.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text(
              order.type,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
            ),
            const SizedBox(height: 16),
            _RowKVText(
              k: localizations.status,
              v: _StatusPill(status: order.status),
              keyStyle: keyStyle,
              valStyle: valStyle,
              isWidgetValue: true,
            ),
            const SizedBox(height: 10),
            _RowKVText(
                k: localizations.orderId,
                vText: order.orderId,
                keyStyle: keyStyle,
                valStyle: valStyle),
            const SizedBox(height: 10),
            _RowKVText(
                k: localizations.purchasedOn,
                vText: order.purchasedOn,
                keyStyle: keyStyle,
                valStyle: valStyle),
            const SizedBox(height: 10),
            _RowKVText(
                k: localizations.baseTotal,
                vText: order.baseTotal,
                keyStyle: keyStyle,
                valStyle: valStyle),
            const SizedBox(height: 10),
            _RowKVText(
                k: localizations.purchasedTotal,
                vText: order.purchasedTotal,
                keyStyle: keyStyle,
                valStyle: valStyle),
            const SizedBox(height: 10),
            _RowKVText(
                k: localizations.customer,
                vText: order.customer,
                keyStyle: keyStyle,
                valStyle: valStyle),
          ],
        ),
      ),
    ];

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: isRTL ? children.reversed.toList() : children,
        ),
      ],
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
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Row(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            k,
            style: keyStyle,
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: isWidgetValue && v != null
              ? v!
              : Text(
            vText ?? '',
            style: valStyle,
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
          ),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final OrderStatus status;

  Color get _bg {
    switch (status) {
      case OrderStatus.delivered:
        return const Color(0xFFDFF7E3);
      case OrderStatus.processing:
        return const Color(0xFFFFF4CC);
      case OrderStatus.cancelled:
        return const Color(0xFFFFE0E0);
      case OrderStatus.onHold:
        return const Color(0xFFEDE7FE);
      case OrderStatus.closed:
        return const Color(0xFFECEFF1);
      case OrderStatus.pending:
        return const Color(0xFFE7F0FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String label = () {
      switch (status) {
        case OrderStatus.delivered:
          return l10n.delivered;
        case OrderStatus.processing:
          return l10n.processing;
        case OrderStatus.cancelled:
          return l10n.cancelled;
        case OrderStatus.onHold:
          return l10n.onHold;
        case OrderStatus.closed:
          return l10n.closed;
        case OrderStatus.pending:
          return l10n.pending;
      }
    }();

    return DecoratedBox(
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class InputSurface extends StatelessWidget {
  const InputSurface({required this.child, super.key});
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
