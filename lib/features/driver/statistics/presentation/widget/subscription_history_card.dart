import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../data/models/driver_statistics_model.dart';

class SubscriptionHistoryCard extends StatelessWidget {
  final SubscriptionHistoryModel history;

  const SubscriptionHistoryCard({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_outlined,
                color: theme.colorScheme.primary,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'سجل الاشتراكات التاريخي',
                style: AppTextStyles.style(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: _historyBox(
                  'المكتملة',
                  '${history.completedSubscriptionsCount}',
                  AppColors.success,
                  isDark,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _historyBox(
                  'الملغاة',
                  '${history.cancelledSubscriptionsCount}',
                  AppColors.error,
                  isDark,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _historyBox(
                  'إجمالي الاشتراكات',
                  '${history.totalHistoricalSubscriptions}',
                  theme.colorScheme.primary,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _historyBox(String title, String value, Color color, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.style(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 10.sp,
              color: isDark ? AppColors.grey300 : AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
