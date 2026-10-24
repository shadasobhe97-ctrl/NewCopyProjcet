import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../data/models/driver_statistics_model.dart';

class TripOperationsCard extends StatelessWidget {
  final TripOperationsStatsModel tripStats;
  final bool isFiltered;

  const TripOperationsCard({
    super.key,
    required this.tripStats,
    this.isFiltered = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final completedTripsCount = tripStats.getCompletedTripsCount(isFiltered: isFiltered);
    final todayCompleted = tripStats.completedTrips.todayCompleted;
    final absentTripsCount = tripStats.getAbsentTripsCount(isFiltered: isFiltered);
    final vehicleBreakdownsCount = tripStats.getVehicleBreakdownsCount(isFiltered: isFiltered);
    final completedSubstituteTrips = tripStats.getCompletedSubstituteTripsCount();

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
          // رأس البطاقة
          Row(
            children: [
              Icon(
                Icons.alt_route_rounded,
                color: theme.colorScheme.primary,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'عمليات الرحلات والإنتاجية',
                style: AppTextStyles.style(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: isFiltered
                      ? theme.colorScheme.primary.withValues(alpha: 0.12)
                      : AppColors.info.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  isFiltered ? 'بيانات الفترة' : 'إجمالي تراكمي',
                  style: AppTextStyles.style(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: isFiltered ? theme.colorScheme.primary : AppColors.info,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // 1. الرحلات المكتملة
          Text(
            'الرحلات المكتملة:',
            style: AppTextStyles.style(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _operationBox(
                  icon: Icons.check_circle_outline_rounded,
                  title: isFiltered ? 'المكتملة بالفترة' : 'إجمالي المكتملة',
                  value: '$completedTripsCount',
                  unit: 'رحلة',
                  color: theme.colorScheme.primary,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _operationBox(
                  icon: Icons.today_rounded,
                  title: 'المكتملة اليوم',
                  value: '$todayCompleted',
                  unit: 'رحلة',
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),
          Divider(color: isDark ? AppColors.grey800 : AppColors.grey200, height: 1),
          SizedBox(height: 12.h),

          // 2. الغياب والأعطال
          Text(
            'الغياب والأعطال:',
            style: AppTextStyles.style(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _operationBox(
                  icon: Icons.person_off_outlined,
                  title: 'رحلات الغياب',
                  value: '$absentTripsCount',
                  unit: 'رحلة متغيب عنها',
                  color: AppColors.warning,
                  isDark: isDark,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _operationBox(
                  icon: Icons.car_crash_outlined,
                  title: 'أعطال المركبة',
                  value: '$vehicleBreakdownsCount',
                  unit: 'عطل مسجل',
                  color: AppColors.error,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),
          Divider(color: isDark ? AppColors.grey800 : AppColors.grey200, height: 1),
          SizedBox(height: 12.h),

          // 3. رحلات الطوارئ (كسائق بديل)
          Text(
            'رحلات الطوارئ (كسائق بديل):',
            style: AppTextStyles.style(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
          ),
          SizedBox(height: 8.h),
          _operationBox(
            icon: Icons.task_alt_rounded,
            title: 'المكتملة كبديل',
            value: '$completedSubstituteTrips',
            unit: 'مهمة منجزة',
            color: AppColors.success,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _operationBox({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16.r),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
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
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: AppTextStyles.style(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            unit,
            style: AppTextStyles.style(
              fontSize: 9.sp,
              color: isDark ? AppColors.grey500 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
