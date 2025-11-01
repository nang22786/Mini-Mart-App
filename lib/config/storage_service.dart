// lib/config/storage_service.dart

import 'package:mini_mart/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Save Access Token
  static Future<bool> saveAccessToken(String token) async {
    return await _prefs?.setString(ApiConfig.accessTokenKey, token) ?? false;
  }

  // Get Access Token
  static String? getAccessToken() {
    return _prefs?.getString(ApiConfig.accessTokenKey);
  }

  // Save User ID
  static Future<bool> saveUserId(int userId) async {
    return await _prefs?.setInt(ApiConfig.userIdKey, userId) ?? false;
  }

  // Get User ID
  static int? getUserId() {
    return _prefs?.getInt(ApiConfig.userIdKey);
  }

  // Save User Email
  static Future<bool> saveUserEmail(String email) async {
    return await _prefs?.setString(ApiConfig.userEmailKey, email) ?? false;
  }

  // Get User Email
  static String? getUserEmail() {
    return _prefs?.getString(ApiConfig.userEmailKey);
  }

  // ✅ NEW: Save Selected Address ID
  static Future<bool> saveSelectedAddressId(int addressId) async {
    return await _prefs?.setInt('selected_address_id', addressId) ?? false;
  }

  // ✅ NEW: Get Selected Address ID
  static int? getSelectedAddressId() {
    return _prefs?.getInt('selected_address_id');
  }

  // ✅ NEW: Clear Selected Address ID
  static Future<bool> clearSelectedAddressId() async {
    return await _prefs?.remove('selected_address_id') ?? false;
  }

  // ✅ NEW: Save FCM Token
  static Future<bool> saveFCMToken(String token) async {
    return await _prefs?.setString('fcm_token', token) ?? false;
  }

  // ✅ NEW: Get FCM Token
  static String? getFCMToken() {
    return _prefs?.getString('fcm_token');
  }

  // ✅ NEW: Clear FCM Token
  static Future<bool> clearFCMToken() async {
    return await _prefs?.remove('fcm_token') ?? false;
  }

  // Check if logged in
  static bool isLoggedIn() {
    return getAccessToken() != null && getUserId() != null;
  }

  // Clear all data (Logout)
  static Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }

  // Remove specific key
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }
}
