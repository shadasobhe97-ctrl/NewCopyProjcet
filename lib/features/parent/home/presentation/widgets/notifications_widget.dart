import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';

/// 🔔 4) NotificationsWidget - قسم الإشعارات
/// يحتوي على هيدر "آخر الإشعارات" و "عرض الكل".
/// - hasNotifications = true: قائمة عمودية بالإشعارات مع أيقونات وعناوين وتوقيت.
/// - hasNotifications = false: حالة فارغة متمركزة في المنتصف مع أيقونة جرس رمادية.
class NotificationsWidget extends StatelessWidget {
  final bool hasNotifications;
  final List<Map<String, String>>? notifications;
  final VoidCallback? onViewAll;

  const NotificationsWidget({
    super.key,
    required this.hasNotifications,
    this.notifications,
    this.onViewAll,
  });

  static const List<Map<String, String>> _defaultNotifications = [
    {
      'title': 'وصلت سارة إلى المدرسة',
      'subtitle': 'تم توثيق الوصول بسلامة الله',
      'time': 'منذ 10 دقائق',
      'type': 'bus',
    },
    {
      'title': 'بدأت رحلة أحمد إلى المدرسة',
      'subtitle': 'انطلقت الحافلة في المسار المحجوز',
      'time': 'منذ 25 دقيقة',
      'type': 'bus',
    },
    {
      'title': 'تم تأكيد الدفع بنجاح',
      'subtitle': 'تم استلام قيمة الاشتراك الشهرية',
      'time': 'منذ 1 ساعة',
      'type': 'check',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final currentNotifications = notifications ?? _defaultNotifications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // هيدر القسم: "آخر الإشعارات" على اليمين و "عرض الكل" على اليسار
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'آخر الإشعارات',
              style: AppTextStyles.style(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            if (hasNotifications)
              InkWell(
                onTap: onViewAll ?? () {},
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Text(
                    'عرض الكل',
                    style: AppTextStyles.style(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 10.h),

        if (!hasNotifications)
          // ⚪ الحالة الثانية (hasNotifications = false): Empty State متمركزة في المنتصف
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: isDark ? context.cardSurface : AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark ? AppColors.grey800 : AppColors.grey200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.grey800.withValues(alpha: 0.5)
                        : AppColors.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.grey400,
                    size: 32.r,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'لا توجد إشعارات حالياً',
                  style: AppTextStyles.style(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'ستظهر هنا آخر التنبيهات والإشعارات',
                  style: AppTextStyles.style(
                    fontSize: 10.5.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          )
        else
          // 🟢 الحالة الأولى (hasNotifications = true): قائمة عمودية من الإشعارات
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: isDark ? context.cardSurface : AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isDark ? AppColors.grey800 : AppColors.grey200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: List.generate(currentNotifications.length, (index) {
                final notif = currentNotifications[index];
                final isBus = notif['type'] == 'bus';
                final isLast = index == currentNotifications.length - 1;

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Row(
                        children: [
                          // أيقونة دائرية
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: (isBus ? primaryColor : AppColors.success)
                                  .withValues(alpha: isDark ? 0.2 : 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isBus
                                  ? Icons.directions_bus_rounded
                                  : Icons.check_circle_outline_rounded,
                              color: isBus ? primaryColor : AppColors.success,
                              size: 18.r,
                            ),
                          ),
                          SizedBox(width: 10.w),

                          // العنوان والوصف
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notif['title'] ?? '',
                                  style: AppTextStyles.style(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.bold,
                                    color: context.textPrimary,
                                  ),
                                ),
                                if (notif['subtitle'] != null &&
                                    notif['subtitle']!.isNotEmpty) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    notif['subtitle']!,
                                    style: AppTextStyles.style(
                                      fontSize: 9.5.sp,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // وقت الإشعار
                          Text(
                            notif['time'] ?? '',
                            style: AppTextStyles.style(
                              fontSize: 9.5.sp,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 6.h,
                        thickness: 0.5,
                        color: isDark ? AppColors.grey800 : AppColors.grey100,
                      ),
                  ],
                );
              }),
            ),
          ),
      ],
    );
  }
}
