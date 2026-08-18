import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/notification_model.dart';
import '../../network/notification_repository.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;
  final int unreadCount;

  NotificationLoaded({
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMore,
    required this.unreadCount,
  });

  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? hasMore,
    int? unreadCount,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
}

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _repository;

  NotificationCubit(this._repository) : super(NotificationInitial());

  Future<void> loadNotifications() async {
    emit(NotificationLoading());
    try {
      final result = await _repository.getNotifications(1);
      int unread = 0;
      try {
        unread = await _repository.getUnreadCount();
      } catch (_) {}

      emit(NotificationLoaded(
        notifications: result.notifications,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        total: result.total,
        hasMore: result.hasMore,
        unreadCount: unread,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! NotificationLoaded || !currentState.hasMore) return;

    try {
      final nextPage = currentState.currentPage + 1;
      final result = await _repository.getNotifications(nextPage);

      emit(currentState.copyWith(
        notifications: [...currentState.notifications, ...result.notifications],
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        total: result.total,
        hasMore: result.hasMore,
      ));
    } catch (_) {
      // Keep existing items on pagination error
    }
  }

  Future<void> refresh() async {
    try {
      final result = await _repository.getNotifications(1);
      int unread = 0;
      try {
        unread = await _repository.getUnreadCount();
      } catch (_) {}

      emit(NotificationLoaded(
        notifications: result.notifications,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        total: result.total,
        hasMore: result.hasMore,
        unreadCount: unread,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> updateUnreadCount() async {
    final currentState = state;
    try {
      final unread = await _repository.getUnreadCount();
      if (currentState is NotificationLoaded) {
        emit(currentState.copyWith(unreadCount: unread));
      } else {
        emit(NotificationLoaded(
          notifications: const [],
          currentPage: 1,
          lastPage: 1,
          total: 0,
          hasMore: false,
          unreadCount: unread,
        ));
      }
    } catch (_) {}
  }

  Future<void> markAsRead(String id) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    try {
      await _repository.markAsRead(id);
      
      final updatedList = currentState.notifications.map((item) {
        if (item.id == id) {
          return item.copyWith(isRead: true, readAt: DateTime.now());
        }
        return item;
      }).toList();

      final newUnread = (currentState.unreadCount - 1).clamp(0, 999);

      emit(currentState.copyWith(
        notifications: updatedList,
        unreadCount: newUnread,
      ));
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    try {
      await _repository.markAllAsRead();

      final updatedList = currentState.notifications.map((item) {
        return item.copyWith(isRead: true, readAt: DateTime.now());
      }).toList();

      emit(currentState.copyWith(
        notifications: updatedList,
        unreadCount: 0,
      ));
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    final currentState = state;
    if (currentState is! NotificationLoaded) return;

    try {
      await _repository.deleteNotification(id);

      final target = currentState.notifications.firstWhere((item) => item.id == id);
      final updatedList = currentState.notifications.where((item) => item.id != id).toList();
      final newUnread = target.isRead ? currentState.unreadCount : (currentState.unreadCount - 1).clamp(0, 999);

      emit(currentState.copyWith(
        notifications: updatedList,
        unreadCount: newUnread,
        total: (currentState.total - 1).clamp(0, 9999),
      ));
    } catch (_) {}
  }
}
