import '../models/notification_model.dart';
import 'notification_remote_datasource.dart';

class NotificationPaginationResult {
  final List<NotificationModel> notifications;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;

  NotificationPaginationResult({
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMore,
  });
}

class NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepository(this._remoteDataSource);

  Future<NotificationPaginationResult> getNotifications(int page) async {
    final response = await _remoteDataSource.getNotifications(page);
    final data = response.data;
    
    final List<dynamic> list = data['data'] ?? [];
    final notifications = list
        .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final pagination = data['pagination'] ?? data['meta'] ?? {};
    final currentPage = pagination['current_page'] ?? 1;
    final lastPage = pagination['last_page'] ?? 1;
    final total = pagination['total'] ?? notifications.length;
    final hasMore = pagination['has_more'] ?? (currentPage < lastPage);

    return NotificationPaginationResult(
      notifications: notifications,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      hasMore: hasMore,
    );
  }

  Future<int> getUnreadCount() async {
    final response = await _remoteDataSource.getUnreadCount();
    final data = response.data;
    return data['unread_count'] ?? data['count'] ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _remoteDataSource.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    await _remoteDataSource.markAllAsRead();
  }

  Future<void> deleteNotification(String id) async {
    await _remoteDataSource.deleteNotification(id);
  }

  Future<void> registerDeviceToken(Map<String, dynamic> body) async {
    await _remoteDataSource.registerDeviceToken(body);
  }

  Future<void> removeDeviceToken(String deviceId) async {
    await _remoteDataSource.removeDeviceToken(deviceId);
  }

  Future<void> logoutAllDevices() async {
    await _remoteDataSource.logoutAllDevices();
  }
}
