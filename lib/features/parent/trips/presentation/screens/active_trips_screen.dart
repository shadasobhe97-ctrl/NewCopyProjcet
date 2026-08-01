import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_user_avatar.dart';
import '../../data/models/active_trip_model.dart';
import '../widgets/trip_status_chip.dart';
import 'trip_details_screen.dart';
import 'trip_tracking_screen.dart';

class ActiveTripsScreen extends StatelessWidget {
  final List<ActiveTripModel> activeTrips;

  const ActiveTripsScreen({
    super.key,
    required this.activeTrips,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'جميع الرحلات النشطة',
            style: AppTextStyles.style(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          centerTitle: true,
          backgroundColor: isDark ? context.cardSurface : AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: context.textPrimary,
              size: 18.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: activeTrips.isEmpty
            ? Center(
                child: Text(
                  'لا توجد رحلات نشطة حالياً',
                  style: AppTextStyles.style(
                    fontSize: 14.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.all(16.r),
                itemCount: activeTrips.length,
                separatorBuilder: (context, index) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  final trip = activeTrips[index];
                  return _buildActiveCard(context, trip, isDark);
                },
              ),
      ),
    );
  }

  Widget _buildActiveCard(BuildContext context, ActiveTripModel trip, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver info & status badge
          Row(
            children: [
              AppUserAvatar(
                imageUrl: trip.driver.photo,
                radius: 22.r,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.driver.name,
                      style: AppTextStyles.style(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      trip.vehicle.info,
                      style: AppTextStyles.style(
                        fontSize: 11.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TripStatusChip.fromStatusString(trip.status),
                  SizedBox(height: 4.h),
                  Text(
                    'بدأت ${trip.startedAt}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(height: 24.h, thickness: 1),

          // Children List in this active trip
          Text(
            'الأطفال المشمولون بالرحلة:',
            style: AppTextStyles.style(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 8.h),
          ...trip.children.map((c) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  AppUserAvatar(imageUrl: c.childPhoto, radius: 12.r),
                  SizedBox(width: 8.w),
                  Text(
                    c.childName,
                    style: AppTextStyles.style(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TripStatusChip.fromStatusString(c.childStatus),
                ],
              ),
            );
          }),
          SizedBox(height: 12.h),

          // Action Buttons: "التفاصيل" and "تتبع"
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42.h,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripDetailsScreen(tripId: trip.tripId),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.primaryColor,
                      side: BorderSide(color: context.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: const Icon(Icons.list_alt_rounded, size: 18),
                    label: const Text('التفاصيل'),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: SizedBox(
                  height: 42.h,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // 🌟 Opens existing Live Tracking Screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripTrackingScreen(
                            trip: trip,
                            allActiveTrips: activeTrips,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.location_on_rounded, size: 18),
                    label: const Text('تتبع'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
