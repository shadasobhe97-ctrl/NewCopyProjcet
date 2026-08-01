import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_user_avatar.dart';
import '../../data/models/active_trip_model.dart';

class TrackingBottomSheet extends StatelessWidget {
  final ActiveTripModel trip;
  final bool isOnline;
  final VoidCallback? onOpenDetails;
  final ScrollController? scrollController;

  const TrackingBottomSheet({
    super.key,
    required this.trip,
    this.scrollController,
    this.isOnline = true,
    this.onOpenDetails,
  });

  void _onMockCall(BuildContext context, String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('مكالمة تجريبية للسائق: $phone'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onMockMessage(BuildContext context, String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('رسالة تجريبية للسائق: $phone'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey700 : AppColors.grey300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // 1) DRIVER CARD
          _buildDriverCard(context, isDark),
          SizedBox(height: 12.h),

          // 2) VEHICLE CARD
          _buildVehicleCard(context, isDark),
          SizedBox(height: 16.h),

          // 3) CHILDREN LIST IN THIS TRIP
          Text(
            'الأطفال في هذه الرحلة (${trip.children.length}):',
            style: AppTextStyles.style(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          ...trip.children.map(
            (child) => _buildChildCardItem(context, child, isDark),
          ),

          SizedBox(height: 20.h),

          // 4) FULL TIMELINE BUTTON
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: onOpenDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.timeline_rounded, size: 20),
              label: Text(
                'عرض تفاصيل الرحلة والـ Timeline',
                style: AppTextStyles.style(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey900 : AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          AppUserAvatar(
            imageUrl: trip.driver.photo,
            radius: 24.r,
            backgroundColor: context.primaryColor.withValues(alpha: 0.1),
            iconColor: context.primaryColor,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.driver.name.isNotEmpty
                      ? trip.driver.name
                      : 'سائق الحافلة',
                  style: AppTextStyles.style(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  trip.driver.phone.isNotEmpty
                      ? trip.driver.phone
                      : 'رقم الهاتف غير متاح',
                  style: AppTextStyles.style(
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (trip.driver.phone.isNotEmpty) ...[
            CircleAvatar(
              radius: 18.r,
              backgroundColor: AppColors.success.withValues(alpha: 0.15),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _onMockCall(context, trip.driver.phone),
                icon: const Icon(
                  Icons.phone_rounded,
                  color: AppColors.success,
                  size: 18,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 18.r,
              backgroundColor: context.primaryColor.withValues(alpha: 0.15),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _onMockMessage(context, trip.driver.phone),
                icon: Icon(
                  Icons.chat_bubble_rounded,
                  color: context.primaryColor,
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey900 : AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_bus_rounded,
              color: context.primaryColor,
              size: 22.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              trip.vehicle.info,
              style: AppTextStyles.style(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ),
          if (trip.vehicle.plateNumber != null &&
              trip.vehicle.plateNumber!.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey800 : AppColors.grey200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                trip.vehicle.plateNumber!,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChildCardItem(
    BuildContext context,
    TripChildInfo child,
    bool isDark,
  ) {
    Color badgeColor = AppColors.success;
    String statusText = 'داخل الحافلة 🟢';

    if (child.childStatus.contains('waiting') ||
        child.childStatus.contains('ينتظر')) {
      badgeColor = AppColors.warning;
      statusText = 'ينتظر 🟡';
    } else if (child.childStatus.contains('absent') ||
        child.childStatus.contains('غائب')) {
      badgeColor = AppColors.error;
      statusText = 'غائب 🔴';
    } else if (child.childStatus.contains('dropped_off') ||
        child.childStatus.contains('arrived')) {
      badgeColor = AppColors.grey400;
      statusText = 'تم النزول ⚪';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey800 : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.grey700 : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          AppUserAvatar(
            imageUrl: child.childPhoto,
            radius: 18.r,
            backgroundColor: context.primaryColor.withValues(alpha: 0.1),
            iconColor: context.primaryColor,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              child.childName,
              style: AppTextStyles.style(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
