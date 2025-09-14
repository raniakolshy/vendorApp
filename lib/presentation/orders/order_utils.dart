import 'package:flutter/material.dart';
import 'order_model.dart';
import 'package:intl/intl.dart';

enum OrderStatus { delivered, processing, cancelled, onHold, closed, pending }

class OrderUtils {
  static OrderStatus mapMagentoStatusToOrderStatus(String magentoStatus) {
    switch (magentoStatus.toLowerCase()) {
      case 'complete':
      case 'delivered':
        return OrderStatus.delivered;
      case 'processing':
      case 'pending_payment':
        return OrderStatus.processing;
      case 'canceled':
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'holded':
        return OrderStatus.onHold;
      case 'closed':
        return OrderStatus.closed;
      case 'pending':
      case 'new':
        return OrderStatus.pending;
      default:
        return OrderStatus.processing;
    }
  }

  static String formatOrderDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd / MM / yyyy').format(date);
    } catch (_) {
      return dateString;
    }
  }

  static String getProductImageUrl(dynamic productData) {
    if (productData is Map<String, dynamic>) {
      final mediaGallery = productData['media_gallery_entries'] as List<dynamic>?;
      if (mediaGallery != null && mediaGallery.isNotEmpty) {
        final firstImage = mediaGallery.first;
        final file = firstImage['file'] as String?;
        if (file != null) {
          return 'https://kolshy.ae/media/catalog/product$file';
        }
      }
      final customAttributes = productData['custom_attributes'] as List<dynamic>?;
      if (customAttributes != null) {
        for (var attr in customAttributes) {
          if (attr['attribute_code'] == 'image' && attr['value'] != null) {
            return 'https://kolshy.ae/media/catalog/product${attr['value']}';
          }
        }
      }
    }
    return 'assets/img_square.jpg';
  }
}
