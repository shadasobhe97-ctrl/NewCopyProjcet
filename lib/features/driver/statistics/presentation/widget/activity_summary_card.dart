import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class ActivitySummaryCard extends StatelessWidget {
  final int activeStudentsCount;
  final int completedTripsCount;
  final double punctualityRate;

  const ActivitySummaryCard({
    super.key,
    required this.activeStudentsCount,
    required this.completedTripsCount,
    required this.punctualityRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: _statBox(
            context,
            title: 'الطلاب النشطون',
            value: '$activeStudentsCount',
            unit: 'طالب',
            icon: Icons.people_alt_rounded,
            iconColor: theme.colorScheme.primary,
            isDark: isDark,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _statBox(
            context,
            title: 'الرحلات المكتملة',
            value: '$completedTripsCount',
            unit: 'رحلة',
            icon: Icons.directions_bus_rounded,
            iconColor: AppColors.success,
            isDark: isDark,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _statBox(
            context,
            title: 'الالتزام بالمواعيد',
            value: '${punctualityRate.toStringAsFixed(0)}%',
            unit: 'نسبة الدقة',
            icon: Icons.timer_outlined,
            iconColor: AppColors.info,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _statBox(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18.r),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: AppTextStyles.style(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
