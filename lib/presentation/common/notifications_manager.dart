// notifications_manager.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../../services/api_client.dart';


class NotificationData {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? type;
  final String? relatedId;

  NotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.type,
    this.relatedId,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? json['body'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      isRead: json['is_read'] ?? false,
      type: json['type'],
      relatedId: json['related_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'type': type,
      'related_id': relatedId,
    };
  }
}

class NotificationsManager with ChangeNotifier {
  final VendorApiClient _apiClient;
  List<NotificationData> _notifications = [];
  int _unreadCount = 0;

  List<NotificationData> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  NotificationsManager(this._apiClient);

  // Load notifications from API
  Future<void> loadNotifications() async {
    try {
      // First try to get vendor-specific notifications
      try {
        final response = await _apiClient.getVendorNotifications();
        _notifications = (response as List)
            .map((item) => NotificationData.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } catch (e) {
        // Fallback to admin notifications if vendor notifications fail
        final response = await _apiClient.getAdminNews();
        _notifications = (response as List)
            .map((item) => NotificationData.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }

      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();

      // Save to local storage for offline access
      await _saveNotificationsToLocal();
    } catch (e) {
      if (kDebugMode) print('Error loading notifications: $e');
      // Load from local storage if API fails
      await _loadNotificationsFromLocal();
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.markNotificationAsRead(notificationId);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationData(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          createdAt: _notifications[index].createdAt,
          isRead: true,
          type: _notifications[index].type,
          relatedId: _notifications[index].relatedId,
        );

        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
        await _saveNotificationsToLocal();
      }
    } catch (e) {
      if (kDebugMode) print('Error marking notification as read: $e');
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.markAllNotificationsAsRead();

      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = NotificationData(
            id: _notifications[i].id,
            title: _notifications[i].title,
            message: _notifications[i].message,
            createdAt: _notifications[i].createdAt,
            isRead: true,
            type: _notifications[i].type,
            relatedId: _notifications[i].relatedId,
          );
        }
      }

      _unreadCount = 0;
      notifyListeners();
      await _saveNotificationsToLocal();
    } catch (e) {
      if (kDebugMode) print('Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiClient.deleteNotification(notificationId);

      _notifications.removeWhere((n) => n.id == notificationId);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
      await _saveNotificationsToLocal();
    } catch (e) {
      if (kDebugMode) print('Error deleting notification: $e');
    }
  }

  Future<void> _saveNotificationsToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = _notifications.map((n) => n.toJson()).toList();
    await prefs.setString('vendor_notifications', json.encode(notificationsJson));
    await prefs.setInt('vendor_unread_count', _unreadCount);
  }

  Future<void> _loadNotificationsFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('vendor_notifications');
    final savedUnreadCount = prefs.getInt('vendor_unread_count') ?? 0;

    if (notificationsJson != null) {
      try {
        final List<dynamic> data = json.decode(notificationsJson);
        _notifications = data
            .map((item) => NotificationData.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        _unreadCount = savedUnreadCount;
        notifyListeners();
      } catch (e) {
        if (kDebugMode) print('Error loading local notifications: $e');
      }
    }
  }

  // Clear all notifications
  Future<void> clearAll() async {
    try {
      await _apiClient.clearAllNotifications();
      _notifications.clear();
      _unreadCount = 0;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('vendor_notifications');
      await prefs.remove('vendor_unread_count');
    } catch (e) {
      if (kDebugMode) print('Error clearing all notifications: $e');
    }
  }
}