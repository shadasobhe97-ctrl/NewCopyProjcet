import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_user_avatar.dart';
import '../../data/models/active_trip_model.dart';

class ActiveTripCard extends StatelessWidget {
  final ActiveTripModel trip;
  final VoidCallback onTrackPressed;
  final VoidCallback? onDetailsPressed;

  const ActiveTripCard({
    super.key,
    required this.trip,
    required this.onTrackPressed,
    this.onDetailsPressed,
  });

  void _onCall(BuildContext context, String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('مكالمة السائق: $phone'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onMessage(BuildContext context, String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('رسالة السائق: $phone'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) DRIVER ROW
          Row(
            children: [
              AppUserAvatar(
                imageUrl: trip.driver.photo,
                radius: 22.r,
                backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                iconColor: context.primaryColor,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.driver.name.isNotEmpty ? trip.driver.name : 'سائق الحافلة',
                      style: AppTextStyles.style(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      trip.driver.phone.isNotEmpty ? trip.driver.phone : 'رقم الهاتف غير متاح',
                      style: AppTextStyles.style(
                        fontSize: 11.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (trip.driver.phone.isNotEmpty) ...[
                // 📞 Call Button
                CircleAvatar(
                  radius: 17.r,
                  backgroundColor: AppColors.success.withValues(alpha: 0.12),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _onCall(context, trip.driver.phone),
                    icon: const Icon(
                      Icons.phone_rounded,
                      color: AppColors.success,
                      size: 16,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // 💬 Chat Button
                CircleAvatar(
                  radius: 17.r,
                  backgroundColor: context.primaryColor.withValues(alpha: 0.12),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _onMessage(context, trip.driver.phone),
                    icon: Icon(
                      Icons.chat_bubble_rounded,
                      color: context.primaryColor,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: 12.h),
          Divider(height: 1, color: isDark ? AppColors.grey800 : AppColors.grey200),
          SizedBox(height: 12.h),

          // 2) VEHICLE & DESTINATION ROW
          Row(
            children: [
              Icon(Icons.directions_bus_rounded, size: 18.r, color: context.primaryColor),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  trip.vehicle.info,
                  style: AppTextStyles.style(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
              ),
              if (trip.vehicle.plateNumber != null && trip.vehicle.plateNumber!.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey800 : AppColors.grey100,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    trip.vehicle.plateNumber!,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 8.h),

          // 3) DESTINATION INFO
          Row(
            children: [
              Icon(
                trip.destination.type == 'home' ? Icons.home_rounded : Icons.school_rounded,
                size: 18.r,
                color: AppColors.amber,
              ),
              SizedBox(width: 6.w),
              Text(
                'الوجهة: ',
                style: AppTextStyles.style(
                  fontSize: 12.sp,
                  color: AppColors.textMuted,
                ),
              ),
              Expanded(
                child: Text(
                  trip.destination.name,
                  style: AppTextStyles.style(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // 4) CHILDREN LIST IN THIS TRIP
          Text(
            'الأطفال في هذه الرحلة:',
            style: AppTextStyles.style(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: trip.children.map((child) => _buildChildChip(context, child, isDark)).toList(),
          ),

          SizedBox(height: 14.h),

          // 5) ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42.h,
                  child: ElevatedButton.icon(
                    onPressed: onTrackPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.map_rounded, size: 18),
                    label: Text(
                      'تتبع الرحلة ع الخريطة',
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
              if (onDetailsPressed != null) ...[
                SizedBox(width: 8.w),
                SizedBox(
                  height: 42.h,
                  child: OutlinedButton(
                    onPressed: onDetailsPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.primaryColor,
                      side: BorderSide(color: context.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'التفاصيل',
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: context.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChildChip(BuildContext context, TripChildInfo child, bool isDark) {
    Color statusColor = AppColors.success;

    final s = child.childStatus.toLowerCase();
    if (s.contains('waiting') || s.contains('ينتظر')) {
      statusColor = AppColors.warning;
    } else if (s.contains('absent') || s.contains('غائب')) {
      statusColor = AppColors.error;
    } else if (s.contains('dropped_off') || s.contains('arrived')) {
      statusColor = AppColors.grey400;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.grey100,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? AppColors.grey700 : AppColors.grey200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppUserAvatar(
            imageUrl: child.childPhoto,
            radius: 10.r,
            backgroundColor: statusColor.withValues(alpha: 0.2),
            iconColor: statusColor,
          ),
          SizedBox(width: 6.w),
          Text(
            child.childName.split(' ')[0],
            style: AppTextStyles.style(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          SizedBox(width: 4.w),
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
