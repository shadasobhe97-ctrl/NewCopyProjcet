import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/trips/presentation/screens/trip_tracking_screen.dart';
import 'package:kids_transport/features/parent/trips/presentation/screens/upcoming_trips_screen.dart';

class TopCardWidget extends StatelessWidget {
  final bool hasTrips;
  final VoidCallback? onTrackTrips;
  final VoidCallback? onViewUpcoming;
  final int activeTripsCount;

  const TopCardWidget({
    super.key,
    required this.hasTrips,
    this.onTrackTrips,
    this.onViewUpcoming,
    this.activeTripsCount = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final darkerPrimary = Color.lerp(primaryColor, Colors.black, 0.18)!;

    if (hasTrips) {
      // 🟢 الحالة الأولى: يوجد رحلات نشطة
      return Container(
        height: 145.h,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F626B), const Color(0xFF063A40)]
                : [darkerPrimary, primaryColor],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.22),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: 16.w,
              top: 0,
              bottom: 0,
              left: 140.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: const BoxDecoration(
                          color: AppColors.accentGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'رحلة نشطة حالياً',
                        style: AppTextStyles.style(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'لديك رحلة نشطة',
                    style: AppTextStyles.style(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'تابعي رحلة طفلك الآن مباشرة',
                    style: AppTextStyles.style(
                      fontSize: 10.5.sp,
                      color: AppColors.white.withValues(alpha: 0.88),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 34.h,
                    child: ElevatedButton.icon(
                      onPressed:
                          onTrackTrips ??
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TripTrackingScreen(),
                              ),
                            );
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        elevation: 0,
                      ),
                      icon: Icon(
                        Icons.location_on_rounded,
                        size: 14.r,
                        color: primaryColor,
                      ),
                      label: Text(
                        'تتبع الرحلة',
                        style: AppTextStyles.style(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 5.w,
              top: 10.h,
              bottom: 10.h,
              width: 130.w,
              child: Image.asset(
                'assets/images/hastrips.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.directions_bus_filled_rounded,
                    size: 60.r,
                    color: AppColors.white.withValues(alpha: 0.4),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      // ⚪ الحالة الثانية: لا توجد رحلة نشطة (حالة بسيطة وخفيفة جداً تمنع هدر المساحة)
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.grey900
              : primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isDark
                ? AppColors.grey800
                : primaryColor.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.directions_bus_outlined,
              color: AppColors.textMuted,
              size: 18.r,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'لا توجد رحلة نشطة حالياً',
                style: AppTextStyles.style(
                  fontSize: 11.5.sp,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            InkWell(
              onTap: onViewUpcoming ??
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UpcomingTripsScreen(),
                      ),
                    );
                  },
              child: Text(
                'عرض جدول الرحلات',
                style: AppTextStyles.style(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

