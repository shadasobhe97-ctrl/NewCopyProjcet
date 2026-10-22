import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/dashboard/presentation/screens/parent_main_wrapper.dart';
import 'package:kids_transport/features/parent/trips/data/models/active_trip_model.dart';
import 'package:kids_transport/features/parent/trips/logic/active_trip_cubit/active_trip_cubit.dart';
import 'package:kids_transport/features/parent/trips/logic/active_trip_cubit/active_trip_state.dart';
import 'package:kids_transport/features/parent/trips/presentation/screens/trip_tracking_screen.dart';
import 'package:kids_transport/features/parent/trips/presentation/screens/trips_home_screen.dart';

/// 🚍 ويدجت تتبع الرحلة الذكي في الشاشة الرئيسية
/// يتصل مباشرة بـ ActiveTripCubit:
/// 1️⃣ في حال وجود رحلة نشطة: يعرض كرت التتبع المباشر بالصورة والبيانات اللحظية.
/// 2️⃣ في حال عدم وجود رحلات نشطة: يعرض كرت هادئ وأنيق يتيح لولي الأمر الاطلاع على جدول وسجل رحلاته.
class TopCardWidget extends StatelessWidget {
  final VoidCallback? onTrackTrips;
  final VoidCallback? onViewTrips;

  const TopCardWidget({
    super.key,
    this.onTrackTrips,
    this.onViewTrips,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // خلفية سماوية هادئة غير متدرجة كأنها شبه شفافة
    final cardBackgroundColor = isDark ? const Color(0xFF102840) : const Color(0xFFE8F3FA);
    // حدود زرقاء داكنة
    final cardBorderColor = isDark ? AppColors.primaryLight : AppColors.primary;
    // البوتون نفس لون الحدود الزرقاء الداكنة
    const buttonColor = AppColors.primary;

    return BlocBuilder<ActiveTripCubit, ActiveTripState>(
      builder: (context, state) {
        List<ActiveTripModel> activeTrips = [];
        if (state is ActiveTripLoaded) {
          activeTrips = state.activeTrips;
        }

        final bool hasActiveTrips = activeTrips.isNotEmpty;

        if (hasActiveTrips) {
          final firstTrip = activeTrips.first;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTrackTrips ??
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripTrackingScreen(
                          trip: firstTrip,
                          allActiveTrips: activeTrips,
                        ),
                      ),
                    );
                  },
              borderRadius: BorderRadius.circular(18.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: cardBorderColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: isDark ? 0.2 : 0.08,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1️⃣ السطر العلوي: العنوان في اليمين + أيقونة السيارة في اليسار
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 9.r,
                                height: 9.r,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'لديك رحلة نشطة',
                                style: AppTextStyles.style(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.white : AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),

                        // 🚗 أيقونة السيارات على اليسار
                        SizedBox(
                          width: 66.w,
                          height: 52.h,
                          child: Image.asset(
                            'assets/images/hastrips.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.directions_bus_rounded,
                                size: 36.r,
                                color: AppColors.primary,
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // 2️⃣ زر التتبع السفلي بنفس لون الحدود الزرقاء الداكنة
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: buttonColor.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 16.r,
                            color: AppColors.white,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'تتبع مسار الرحلة الآن',
                            style: AppTextStyles.style(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // 🌟 في حال عدم وجود رحلات نشطة
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onViewTrips ??
                () {
                  try {
                    ParentMainWrapper.changeTab(3);
                  } catch (_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TripsHomeScreen(),
                      ),
                    );
                  }
                },
            borderRadius: BorderRadius.circular(18.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: cardBorderColor,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.2 : 0.08,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1️⃣ السطر العلوي: لا توجد رحلات نشطة فقط + أيقونة السيارة
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'لا توجد رحلات نشطة',
                          style: AppTextStyles.style(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.white : AppColors.primaryDark,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),

                      // 🚗 أيقونة السيارات على اليسار
                      SizedBox(
                        width: 66.w,
                        height: 52.h,
                        child: Image.asset(
                          'assets/images/hastrips.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.directions_bus_rounded,
                              size: 36.r,
                              color: AppColors.primary,
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // 2️⃣ البوتون بنفس لون الحدود الزرقاء الداكنة
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: buttonColor.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.route_rounded,
                          size: 16.r,
                          color: AppColors.white,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'عرض جدول ومسارات الرحلات',
                          style: AppTextStyles.style(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
