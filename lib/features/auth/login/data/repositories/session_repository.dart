import 'package:kids_transport/core/services/storage_service.dart';

class SessionRepository {
  String? getToken() => StorageService.getToken();
  int? getRoleId() => StorageService.getRoleId();
  String? getRoleName() => StorageService.getRoleName();
  String? getFullName() => StorageService.getFullName();
  String? getPhoneNumber() => StorageService.getPhoneNumber();
  String? getUserId() => StorageService.getUserId()?.toString();
  int? getParentId() => StorageService.getParentId();
  Future<void> saveParentId(int parentId) =>
      StorageService.saveParentId(parentId);
  int? getDriverId() => StorageService.getDriverId();
  Future<void> saveDriverId(int driverId) =>
      StorageService.saveDriverId(driverId);
  Future<void> clearSession() => StorageService.clearSession();
  bool hasValidSession() => StorageService.hasValidSession();
  bool isFirstTime() => StorageService.isFirstTime();
  bool getIsPreferencesSet() => StorageService.getIsPreferencesSet();
  Future<void> setIsPreferencesSet(bool value) =>
      StorageService.setIsPreferencesSet(value);
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
