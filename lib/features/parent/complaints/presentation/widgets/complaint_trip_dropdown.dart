import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../data/models/driver_trip_model.dart';

class ComplaintTripDropdown extends StatelessWidget {
  final List<DriverTripModel> trips;
  final int? selectedTripId;
  final ValueChanged<int?> onChanged;
  final bool isLoading;

  const ComplaintTripDropdown({
    super.key,
    required this.trips,
    required this.selectedTripId,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return Container(
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey300),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18.w,
              height: 18.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'جاري تحميل رحلات السائق...',
              style: AppTextStyles.style(
                fontSize: 12.sp,
                color: isDark ? AppColors.grey400 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    if (trips.isEmpty) {
      return Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.pending.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.pending.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.pending, size: 20.r),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'لا توجد رحلات متاحة لهذا السائق.',
                style: AppTextStyles.style(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedTripId,
          isExpanded: true,
          hint: Text(
            'اختر الرحلة المعنية بالشكوى',
            style: AppTextStyles.style(
              fontSize: 12.sp,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
          ),
          icon: Icon(Icons.arrow_drop_down_rounded, color: theme.colorScheme.primary),
          items: trips.map((trip) {
            return DropdownMenuItem<int>(
              value: trip.id,
              child: Text(
                trip.title,
                style: AppTextStyles.style(
                  fontSize: 12.5.sp,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
