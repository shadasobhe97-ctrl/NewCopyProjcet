import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class NotificationRemoteDataSource {
  final ApiClient _apiClient;

  NotificationRemoteDataSource(this._apiClient);

  Future<Response<dynamic>> getNotifications(int page) async {
    return await _apiClient.get(
      ApiEndpoints.notifications,
      queryParameters: {'page': page},
    );
  }

  Future<Response<dynamic>> getUnreadCount() async {
    return await _apiClient.get(ApiEndpoints.notificationsUnreadCount);
  }

  Future<Response<dynamic>> markAsRead(String id) async {
    return await _apiClient.patch(ApiEndpoints.markNotificationRead(id));
  }

  Future<Response<dynamic>> markAllAsRead() async {
    return await _apiClient.post(ApiEndpoints.markAllNotificationsRead);
  }

  Future<Response<dynamic>> deleteNotification(String id) async {
    return await _apiClient.delete(ApiEndpoints.deleteNotification(id));
  }

  Future<Response<dynamic>> registerDeviceToken(Map<String, dynamic> body) async {
    return await _apiClient.post(
      ApiEndpoints.registerDeviceToken,
      data: body,
    );
  }

  Future<Response<dynamic>> removeDeviceToken(String deviceId) async {
    return await _apiClient.dio.delete(
      ApiEndpoints.deleteDeviceToken,
      data: {'device_id': deviceId},
    );
  }

  Future<Response<dynamic>> logoutAllDevices() async {
    return await _apiClient.post(ApiEndpoints.logoutAllDevices);
  }
}
