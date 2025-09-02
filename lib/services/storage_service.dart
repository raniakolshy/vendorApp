// Create a new service for storage management
// services/storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Clear ALL storage - this is what your boss wants
  Future<void> clearAllStorage() async {
    try {
      // Clear secure storage
      await _secureStorage.deleteAll();

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      print('All storage cleared successfully');
    } catch (e) {
      print('Error clearing storage: $e');
      // Try individual deletions as fallback
      await _secureStorage.delete(key: 'authToken');
      await _secureStorage.delete(key: 'isGuest');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('is_guest');
      await prefs.remove('isGuest');
    }
  }

  // Check if any auth token exists anywhere
  Future<bool> hasAnyAuthToken() async {
    try {
      // Check secure storage
      final secureToken = await _secureStorage.read(key: 'authToken');
      if (secureToken != null && secureToken.isNotEmpty) return true;

      // Check shared preferences
      final prefs = await SharedPreferences.getInstance();
      final prefsToken = prefs.getString('auth_token');
      if (prefsToken != null && prefsToken.isNotEmpty) return true;

      return false;
    } catch (e) {
      return false;
    }
  }
}