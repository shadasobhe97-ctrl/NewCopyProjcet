import '../models/notification_model.dart';
import 'notification_remote_datasource.dart';

class NotificationPaginationResult {
  final List<NotificationModel> notifications;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;
  final int? unreadCount;

  NotificationPaginationResult({
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMore,
    this.unreadCount,
  });
}

class NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepository(this._remoteDataSource);

  Future<NotificationPaginationResult> getNotifications(
    int page, {
    int? perPage,
    bool? unreadOnly,
    String? type,
  }) async {
    final response = await _remoteDataSource.getNotifications(
      page: page,
      perPage: perPage,
      unreadOnly: unreadOnly,
      type: type,
    );
    final data = response.data;

    dynamic rawData = data['data'];
    List<dynamic> list = [];
    Map<String, dynamic> pagination = {};
    int? unreadCount;

    if (rawData is Map<String, dynamic>) {
      if (rawData['notifications'] is List) {
        list = rawData['notifications'] as List;
      } else if (rawData['list'] is List) {
        list = rawData['list'] as List;
      } else if (rawData['data'] is List) {
        list = rawData['data'] as List;
      }

      if (rawData['pagination'] is Map) {
        pagination = Map<String, dynamic>.from(rawData['pagination'] as Map);
      } else if (rawData['meta'] is Map) {
        pagination = Map<String, dynamic>.from(rawData['meta'] as Map);
      }

      if (rawData['unread_count'] != null) {
        unreadCount = int.tryParse(rawData['unread_count'].toString());
      }
    } else if (rawData is List) {
      list = rawData;
      if (data['pagination'] is Map) {
        pagination = Map<String, dynamic>.from(data['pagination'] as Map);
      } else if (data['meta'] is Map) {
        pagination = Map<String, dynamic>.from(data['meta'] as Map);
      }
      if (data['unread_count'] != null) {
        unreadCount = int.tryParse(data['unread_count'].toString());
      }
    } else {
      if (data['notifications'] is List) {
        list = data['notifications'] as List;
      }
      if (data['pagination'] is Map) {
        pagination = Map<String, dynamic>.from(data['pagination'] as Map);
      }
      if (data['unread_count'] != null) {
        unreadCount = int.tryParse(data['unread_count'].toString());
      }
    }

    final notifications = list
        .whereType<Map<String, dynamic>>()
        .map((item) => NotificationModel.fromJson(item))
        .toList();

    final currentPage = pagination['current_page'] != null
        ? int.tryParse(pagination['current_page'].toString()) ?? page
        : page;
    final lastPage = pagination['last_page'] != null
        ? int.tryParse(pagination['last_page'].toString()) ?? 1
        : 1;
    final total = pagination['total'] != null
        ? int.tryParse(pagination['total'].toString()) ?? notifications.length
        : notifications.length;
    final hasMore = pagination['has_more'] == true ||
        (pagination['has_more'] == null && currentPage < lastPage);

    return NotificationPaginationResult(
      notifications: notifications,
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      hasMore: hasMore,
      unreadCount: unreadCount,
    );
  }

  Future<int> getUnreadCount() async {
    final response = await _remoteDataSource.getUnreadCount();
    final data = response.data;

    if (data is Map<String, dynamic>) {
      if (data['unread_count'] != null) {
        return int.tryParse(data['unread_count'].toString()) ?? 0;
      }
      if (data['count'] != null) {
        return int.tryParse(data['count'].toString()) ?? 0;
      }
      if (data['data'] is Map && data['data']['unread_count'] != null) {
        return int.tryParse(data['data']['unread_count'].toString()) ?? 0;
      }
    }
    return 0;
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

