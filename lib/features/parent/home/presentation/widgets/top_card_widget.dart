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
    this.activeTripsCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    // استخراج درجة أغمق قليلاً من لون الثيم الأساسي الخاص بك
    final darkerPrimary = Color.lerp(primaryColor, Colors.black, 0.18)!;

    if (hasTrips) {
      // 🟢 الحالة الأولى: يوجد رحلات (صورة hastrips.png)
      return Container(
        height: 155.h,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F626B), const Color(0xFF063A40)]
                : [darkerPrimary, primaryColor], // استخدام الدرجة الأغمق هنا
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.25),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // النصوص وزر الإجراء
            Positioned(
              right: 16.w,
              top: 0,
              bottom: 0,
              left: 150.w, // ترك مساحة 150 للصورة على اليسار
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لديك رحلات نشطة',
                    style: AppTextStyles.style(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'تابع رحلات أطفالك الآن',
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
                        'تتبع الآن',
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

            // الصورة (أعطيناها مساحة طولية وعرضية باش تتمدد براحتها بدون تشويه)
            Positioned(
              left: 5.w,
              top: 10.h,
              bottom: 10.h,
              width: 140.w, // عرض ثابت لاحتواء الصورة العريضة
              child: Image.asset(
                'assets/images/hastrips.png',
                fit: BoxFit
                    .contain, // يخلي الصورة تاخذ حجمها الطبيعي داخل المربع
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.directions_bus_filled_rounded,
                    size: 70.r,
                    color: AppColors.white.withValues(alpha: 0.4),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      // ⚪ الحالة الثانية: لا يوجد رحلات (صورة nothastrips.png)
      return Container(
        height: 155.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.grey900
              : primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isDark
                ? AppColors.grey800
                : primaryColor.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
              left: 150.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لا توجد رحلات نشطة',
                    style: AppTextStyles.style(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'يمكنك تتبع رحلات أطفالك لاحقاً',
                    style: AppTextStyles.style(
                      fontSize: 10.5.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 34.h,
                    child: OutlinedButton.icon(
                      onPressed:
                          onViewUpcoming ??
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const UpcomingTripsScreen(),
                              ),
                            );
                          },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.transparent
                            : AppColors.white,
                        foregroundColor: primaryColor,
                        side: BorderSide(
                          color: primaryColor.withValues(alpha: 0.5),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        elevation: 0,
                      ),
                      icon: Icon(
                        Icons.calendar_month_outlined,
                        size: 14.r,
                        color: primaryColor,
                      ),
                      label: Text(
                        'عرض الرحلات',
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

            // الصورة الفارغة
            Positioned(
              left: 5.w,
              top: 10.h,
              bottom: 10.h,
              width: 140.w,
              child: Image.asset(
                'assets/images/nothastrips.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.nature_people_rounded,
                    size: 70.r,
                    color: primaryColor.withValues(alpha: 0.3),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }
}
