import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import '../../data/models/active_trip_model.dart';

class TrackingBottomSheet extends StatelessWidget {
  final ActiveTripModel trip;
  final VoidCallback? onOpenDetails;

  const TrackingBottomSheet({
    super.key,
    required this.trip,
    this.onOpenDetails,
  });

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendMessage(String phone) async {
    final uri = Uri.parse('sms:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final isMorning = trip.direction == 'to_school' || trip.tripType == 'morning';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle bar
          Center(
            child: Container(
              width: 45.w,
              height: 4.5.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey700 : AppColors.grey300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 14.h),

          // Header Row: Direction & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isMorning
                      ? AppColors.primaryLight.withValues(alpha: 0.12)
                      : AppColors.pending.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isMorning ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                      size: 16.r,
                      color: isMorning ? context.primaryColor : AppColors.pending,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      isMorning ? 'رحلة الذهاب (المنزل ← المدرسة)' : 'رحلة العودة (المدرسة ← المنزل)',
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: isMorning ? context.primaryColor : AppColors.pending,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'نشطة الآن',
                  style: AppTextStyles.style(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Driver & Vehicle Card
          Container(
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
                CircleAvatar(
                  radius: 26.r,
                  backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                  backgroundImage: trip.driver.photo != null && trip.driver.photo!.isNotEmpty
                      ? CachedNetworkImageProvider(trip.driver.photo!)
                      : null,
                  child: trip.driver.photo == null || trip.driver.photo!.isEmpty
                      ? Icon(Icons.person_rounded, size: 28.r, color: context.primaryColor)
                      : null,
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
                        '${trip.vehicle.info} ${trip.vehicle.plateNumber != null ? "(${trip.vehicle.plateNumber})" : ""}',
                        style: AppTextStyles.style(
                          fontSize: 12.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Buttons: Call & SMS
                if (trip.driver.phone.isNotEmpty) ...[
                  IconButton(
                    onPressed: () => _makeCall(trip.driver.phone),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.success.withValues(alpha: 0.12),
                    ),
                    icon: const Icon(Icons.phone_rounded, color: AppColors.success, size: 20),
                  ),
                  SizedBox(width: 4.w),
                  IconButton(
                    onPressed: () => _sendMessage(trip.driver.phone),
                    style: IconButton.styleFrom(
                      backgroundColor: context.primaryColor.withValues(alpha: 0.12),
                    ),
                    icon: Icon(Icons.chat_bubble_rounded, color: context.primaryColor, size: 20),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Children List in this trip
          Text(
            'الأطفال في هذه الرحلة (${trip.children.length}):',
            style: AppTextStyles.style(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),

          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: trip.children.map((child) => _buildChildChip(context, child)).toList(),
          ),

          SizedBox(height: 20.h),

          // Action Button: View Trip Details
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: () {
                if (onOpenDetails != null) {
                  onOpenDetails!();
                } else {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.parentInvoiceDetails, // Or custom route
                    arguments: trip.tripId,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.info_outline_rounded, size: 20),
              label: Text(
                'تفاصيل الرحلة والـ Timeline',
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

  Widget _buildChildChip(BuildContext context, TripChildInfo child) {
    Color badgeColor = AppColors.success;
    String statusText = 'داخل الحافلة';
    final s = child.childStatus.toLowerCase();

    if (s.contains('waiting') || s.contains('ينتظر')) {
      badgeColor = AppColors.warning;
      statusText = 'ينتظر';
    } else if (s.contains('absent') || s.contains('غائب')) {
      badgeColor = AppColors.error;
      statusText = 'غائب';
    } else if (s.contains('arrived') || s.contains('وصل')) {
      badgeColor = AppColors.info;
      statusText = 'وصل';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: context.isDarkMode ? AppColors.grey800 : AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12.r,
            backgroundColor: badgeColor.withValues(alpha: 0.2),
            backgroundImage: child.childPhoto != null && child.childPhoto!.isNotEmpty
                ? CachedNetworkImageProvider(child.childPhoto!)
                : null,
            child: child.childPhoto == null || child.childPhoto!.isEmpty
                ? Icon(Icons.person_rounded, size: 14.r, color: badgeColor)
                : null,
          ),
          SizedBox(width: 8.w),
          Text(
            child.childName,
            style: AppTextStyles.style(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          SizedBox(width: 6.w),
          Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
