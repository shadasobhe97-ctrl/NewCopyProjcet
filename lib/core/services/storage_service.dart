import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_transport/core/services/hive_helper.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static const String _themeKey = 'is_dark_mode';
  static const String _isFirstTimeKey = 'is_first_time';

  static const String _tokenKey = 'token';
  static const String _tokenTypeKey = 'token_type';
  static const String _roleIdKey = 'role_id';
  static const String _roleNameKey = 'role_name';
  static const String _userIdKey = 'user_id';
  static const String _fullNameKey = 'full_name';
  static const String _phoneNumberKey = 'phone_number';
  static const String _isActiveKey = 'is_active';
  static const String _isPreferencesSetKey = 'is_preferences_set';
  static const String _driverIdKey = 'driver_id';

  static const String _driverRegStageKey = 'driver_reg_stage';
  static const String _driverRegDraftKey = 'driver_reg_draft';
  static const String _parentRegStageKey = 'parent_reg_stage';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _fcmTokenKey = 'fcm_token';
  static const String _deviceIdKey = 'device_id';

  static Future<bool> saveDeviceId(String deviceId) {
    return _prefs.setString(_deviceIdKey, deviceId);
  }

  static String? getDeviceId() => _prefs.getString(_deviceIdKey);

  static Future<bool> saveThemeMode(bool isDarkMode) {
    return _prefs.setBool(_themeKey, isDarkMode);
  }

  static bool getThemeMode() {
    return _prefs.getBool(_themeKey) ?? false;
  }

  static Future<void> saveUserSession({
    required String token,
    required int roleId,
    String tokenType = 'Bearer',
    String? roleName,
    int? userId,
    String? fullName,
    String? phoneNumber,
    bool? isActive,
  }) async {
    await Future.wait([
      _prefs.setString(_tokenKey, token),
      _prefs.setString(_tokenTypeKey, tokenType),
      _prefs.setInt(_roleIdKey, roleId),
      if (roleName != null) _prefs.setString(_roleNameKey, roleName),
      if (userId != null) _prefs.setInt(_userIdKey, userId),
      if (fullName != null) _prefs.setString(_fullNameKey, fullName),
      if (phoneNumber != null) _prefs.setString(_phoneNumberKey, phoneNumber),
      if (isActive != null) _prefs.setBool(_isActiveKey, isActive),
    ]);
  }

  static String? getToken() => _prefs.getString(_tokenKey);

  static String getTokenType() => _prefs.getString(_tokenTypeKey) ?? 'Bearer';

  static String? getAuthorizationHeader() {
    final token = getToken();
    if (token == null || token.isEmpty) return null;
    return '${getTokenType()} $token';
  }

  static int? getRoleId() {
    final value = _prefs.get(_roleIdKey);
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? getRoleName() => _prefs.getString(_roleNameKey);

  static int? getUserId() {
    final value = _prefs.get(_userIdKey);
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? getFullName() => _prefs.getString(_fullNameKey);

  static String? getPhoneNumber() => _prefs.getString(_phoneNumberKey);

  static bool? getIsActive() => _prefs.getBool(_isActiveKey);

  static Future<bool> saveDriverId(int driverId) {
    return _prefs.setInt(_driverIdKey, driverId);
  }

  static int? getDriverId() {
    final value = _prefs.get(_driverIdKey);
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool hasValidSession() {
    final token = getToken();
    final roleId = getRoleId();
    return token != null && token.isNotEmpty && roleId != null;
  }

  static Future<void> clearSession() async {
    await Future.wait([
      _prefs.remove(_tokenKey),
      _prefs.remove(_tokenTypeKey),
      _prefs.remove(_roleIdKey),
      _prefs.remove(_roleNameKey),
      _prefs.remove(_userIdKey),
      _prefs.remove(_fullNameKey),
      _prefs.remove(_phoneNumberKey),
      _prefs.remove(_isActiveKey),
      _prefs.remove(_isPreferencesSetKey),
      _prefs.remove(_driverIdKey),
      _prefs.remove(_fcmTokenKey),
      _prefs.remove(_driverRegStageKey),
      _prefs.remove(_driverRegDraftKey),
      _prefs.remove(_parentRegStageKey),
    ]);
    await HiveHelper.clearAllCache();
  }

  static Future<void> setFirstTimeComplete() async {
    await _prefs.setBool(_isFirstTimeKey, false);
  }

  static bool isFirstTime() => _prefs.getBool(_isFirstTimeKey) ?? true;

  static Future<bool> setIsPreferencesSet(bool value) {
    return _prefs.setBool(_isPreferencesSetKey, value);
  }

  static bool getIsPreferencesSet() =>
      _prefs.getBool(_isPreferencesSetKey) ?? false;

  static Future<bool> saveFcmToken(String token) {
    return _prefs.setString(_fcmTokenKey, token);
  }

  static String? getFcmToken() => _prefs.getString(_fcmTokenKey);

  // --- [إدارة المسودة وحالة تسجيل السائق] ---
  static Future<bool> saveDriverRegStage(String stage) {
    return _prefs.setString(_driverRegStageKey, stage);
  }

  static String? getDriverRegStage() => _prefs.getString(_driverRegStageKey);

  static Future<bool> saveDriverRegDraft(Map<String, dynamic> data) {
    final cleanMap = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is String || value is num || value is bool) {
        cleanMap[key] = value;
      } else if (value is File) {
        cleanMap['${key}_path'] = value.path;
      } else if (value is XFile) {
        // على الويب مسار الـ XFile هو blob مؤقت لا يصلح للاستعادة بعد إعادة تحميل الصفحة
        if (!kIsWeb) {
          cleanMap['${key}_path'] = value.path;
        }
      }
    });
    return _prefs.setString(_driverRegDraftKey, jsonEncode(cleanMap));
  }

  static Map<String, dynamic> getDriverRegDraft() {
    final raw = _prefs.getString(_driverRegDraftKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final resultMap = Map<String, dynamic>.from(decoded);
        final fileEntries = <String, XFile>{};
        resultMap.forEach((key, value) {
          if (key.endsWith('_path') && value is String) {
            try {
              if (!kIsWeb) {
                final file = File(value);
                if (file.existsSync()) {
                  final originalKey = key.substring(0, key.length - 5);
                  fileEntries[originalKey] = XFile(value);
                }
              }
            } catch (_) {}
          }
        });
        resultMap.addAll(fileEntries);
        return resultMap;
      }
    } catch (_) {}
    return {};
  }

  static Future<void> clearDriverRegDraft() async {
    await Future.wait([
      _prefs.remove(_driverRegStageKey),
      _prefs.remove(_driverRegDraftKey),
    ]);
  }

  // --- [إدارة مرحلة تسجيل ولي الأمر] ---
  static Future<bool> saveParentRegStage(String stage) {
    return _prefs.setString(_parentRegStageKey, stage);
  }

  static String? getParentRegStage() => _prefs.getString(_parentRegStageKey);

  static Future<void> clearParentRegStage() async {
    await _prefs.remove(_parentRegStageKey);
  }
}
