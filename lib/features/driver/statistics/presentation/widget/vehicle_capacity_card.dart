import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../data/models/driver_statistics_model.dart';

class VehicleCapacityCard extends StatelessWidget {
  final VehicleCapacityModel capacity;

  const VehicleCapacityCard({
    super.key,
    required this.capacity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final double rate = capacity.occupancyRate.clamp(0.0, 100.0);
    final Color progressColor = rate >= 80
        ? AppColors.error
        : (rate >= 50 ? AppColors.warning : theme.colorScheme.primary);

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
                Icons.time_to_leave_rounded,
                color: theme.colorScheme.primary,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'مركبتي وسعة المقاعد',
                style: AppTextStyles.style(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // تفاصيل المركبة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      capacity.vehicleModel,
                      style: AppTextStyles.style(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.grey200 : AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'رقم اللوحة: ${capacity.plateNumber}',
                      style: AppTextStyles.style(
                        fontSize: 11.sp,
                        color: isDark ? AppColors.grey400 : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'نسبة الإشغال ${capacity.occupancyRate.toStringAsFixed(1)}%',
                  style: AppTextStyles.style(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // شريط نسبة الإشغال
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: rate / 100.0,
              minHeight: 8.h,
              backgroundColor: isDark ? AppColors.grey800 : AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          SizedBox(height: 14.h),

          // المقاعد الكلية والشاغرة والمتاحة
          Row(
            children: [
              Expanded(
                child: _seatStat(
                  'السعة الكلية',
                  '${capacity.totalCapacity}',
                  isDark,
                ),
              ),
              Expanded(
                child: _seatStat(
                  'المقاعد المشغولة',
                  '${capacity.occupiedSeats}',
                  isDark,
                  textColor: progressColor,
                ),
              ),
              Expanded(
                child: _seatStat(
                  'المقاعد المتاحة',
                  '${capacity.availableSeats}',
                  isDark,
                  textColor: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _seatStat(String label, String value, bool isDark, {Color? textColor}) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.style(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: textColor ?? (isDark ? AppColors.white : AppColors.textDark),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.style(
            fontSize: 10.sp,
            color: isDark ? AppColors.grey400 : AppColors.textMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
