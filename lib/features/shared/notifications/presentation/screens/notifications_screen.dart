import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/logic/cubit/notification_cubit.dart';
import 'package:kids_transport/core/models/notification_model.dart';
import 'package:kids_transport/core/routes/notification_navigation_handler.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();
  late NotificationCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<NotificationCubit>()..loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _cubit.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _cubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
          appBar: AppBar(
            elevation: 0,
            title: Text(
              'الإشعارات',
              style: AppTextStyles.style(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            actions: [
              BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoaded && state.notifications.isNotEmpty) {
                    return TextButton(
                      onPressed: () => _cubit.markAllAsRead(),
                      child: Text(
                        'قراءة الكل',
                        style: AppTextStyles.style(
                          fontSize: 12.sp,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
          body: BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is NotificationError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 60.sp, color: context.errorColor),
                      SizedBox(height: 12.h),
                      Text(
                        'حدث خطأ في تحميل الإشعارات',
                        style: AppTextStyles.style(fontSize: 14.sp, color: context.textMuted),
                      ),
                      SizedBox(height: 8.h),
                      ElevatedButton(
                        onPressed: () => _cubit.loadNotifications(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              if (state is NotificationLoaded) {
                final notifications = state.notifications;

                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 80.sp,
                          color: isDark ? AppColors.grey700 : AppColors.grey400,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'لا توجد إشعارات حالياً',
                          style: AppTextStyles.style(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _cubit.refresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    itemCount: notifications.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == notifications.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }

                      final notification = notifications[index];
                      return _buildNotificationItem(context, notification, isDark);
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel notification, bool isDark) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) {
        _cubit.deleteNotification(notification.id);
      },
      background: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: context.errorColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete_sweep_rounded, color: context.errorColor, size: 28.sp),
      ),
      child: InkWell(
        onTap: () {
          if (!notification.isRead) {
            _cubit.markAsRead(notification.id);
          }
          final payload = notification.payload ?? {};
          final map = {
            'screen': notification.screen,
            'action': notification.action,
            'entity_type': notification.entityType,
            'entity_id': notification.entityId,
            ...payload,
          };
          NotificationNavigationHandler.handleNotificationTap(map);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: notification.isRead
                ? (isDark ? context.cardSurface : Colors.white)
                : (isDark ? context.cardSurface.withValues(alpha: 0.7) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: notification.isRead
                  ? (isDark ? AppColors.grey800 : AppColors.grey200)
                  : Theme.of(context).primaryColor.withValues(alpha: 0.4),
              width: notification.isRead ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon status indicator
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? (isDark ? AppColors.grey800 : AppColors.grey100)
                      : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForType(notification.type),
                  color: notification.isRead
                      ? context.textMuted
                      : Theme.of(context).primaryColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.style(
                              fontSize: 14.sp,
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      notification.message,
                      style: AppTextStyles.style(
                        fontSize: 12.5.sp,
                        color: context.textMuted,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      _formatDateTime(notification.createdAt),
                      style: AppTextStyles.style(
                        fontSize: 10.sp,
                        color: isDark ? AppColors.grey500 : AppColors.grey400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'trip_started':
      case 'driver_arrived':
      case 'child_picked_up':
      case 'child_dropped_off':
        return Icons.directions_bus_rounded;
      case 'invoice_generated':
      case 'recharge_approved':
      case 'settlement_paid':
        return Icons.account_balance_wallet_rounded;
      case 'new_subscription_request':
      case 'subscription_approved':
        return Icons.assignment_turned_in_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return '${dt.year}/${dt.month}/${dt.day}';
    }
  }
}
