import 'package:kids_transport/core/services/storage_service.dart';

class SessionRepository {
  String? getToken() => StorageService.getToken();
  int? getRoleId() => StorageService.getRoleId();
  String? getFullName() => StorageService.getFullName();
  String? getPhoneNumber() => StorageService.getPhoneNumber();
  String? getUserId() => StorageService.getUserId()?.toString();
  Future<void> clearSession() => StorageService.clearSession();
  bool hasValidSession() => StorageService.hasValidSession();
  bool isFirstTime() => StorageService.isFirstTime();
  bool getIsPreferencesSet() => StorageService.getIsPreferencesSet();
  Future<void> setIsPreferencesSet(bool value) => StorageService.setIsPreferencesSet(value);
  Future<void> setFirstTimeComplete() => StorageService.setFirstTimeComplete();
  bool? getIsActive() => StorageService.getIsActive();
  String? getAuthorizationHeader() => StorageService.getAuthorizationHeader();

  Future<void> saveUserSession({
    required String token,
    required String tokenType,
    required int roleId,
    required String roleName,
    required int userId,
    required String fullName,
    required String phoneNumber,
    required bool isActive,
  }) {
    return StorageService.saveUserSession(
      token: token,
      tokenType: tokenType,
      roleId: roleId,
      roleName: roleName,
      userId: userId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      isActive: isActive,
    );
  }
}
