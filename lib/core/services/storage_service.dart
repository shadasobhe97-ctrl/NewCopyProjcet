import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

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
    ]);
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
}
