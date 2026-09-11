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
    final primaryColor = Theme.of(context).primaryColor;
    final darkerPrimary = Color.lerp(primaryColor, Colors.black, 0.22)!;

    return BlocBuilder<ActiveTripCubit, ActiveTripState>(
      builder: (context, state) {
        List<ActiveTripModel> activeTrips = [];
        if (state is ActiveTripLoaded) {
          activeTrips = state.activeTrips;
        }

        final bool hasActiveTrips = activeTrips.isNotEmpty;

        if (hasActiveTrips) {
          final firstTrip = activeTrips.first;
          final driverName = firstTrip.driver.name.isNotEmpty
              ? firstTrip.driver.name
              : 'السائق';

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
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(minHeight: 72.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.darkGradientStart, AppColors.darkGradientEnd]
                        : [darkerPrimary, primaryColor],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.22),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 1️⃣ تفاصيل الرحلة النشطة (جهة اليمين)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 9.r,
                                height: 9.r,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                activeTrips.length > 1
                                    ? '${activeTrips.length} رحلات نشطة حالياً • تتبع مباشر'
                                    : 'رحلة نشطة حالياً • تتبع مباشر',
                                style: AppTextStyles.style(
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            firstTrip.children.isNotEmpty
                                ? 'مع $driverName (${firstTrip.children.map((c) => c.childName).join('، ')}) • اضغط للتتبع'
                                : 'اضغط لمتابعة مسار الرحلة على الخريطة مباشرة',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.style(
                              fontSize: 10.5.sp,
                              color: AppColors.white.withValues(alpha: 0.92),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2️⃣ صورة الحافلة
                    SizedBox(
                      width: 52.w,
                      height: 44.h,
                      child: Image.asset(
                        'assets/images/hastrips.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.directions_bus_rounded,
                            size: 30.r,
                            color: AppColors.white.withValues(alpha: 0.8),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),

                    // 3️⃣ زر التتبع
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 13.r,
                            color: primaryColor,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'تتبع',
                            style: AppTextStyles.style(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
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

        // 🌟 في حال عدم وجود رحلات نشطة حالياً: كرت واضح ومريح لا يفيض أبداً
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
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 62.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark
                      ? AppColors.grey800
                      : primaryColor.withValues(alpha: 0.25),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // أيقونة المسارات
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.route_rounded,
                      size: 20.r,
                      color: isDark ? AppColors.primaryLight : primaryColor,
                    ),
                  ),
                  SizedBox(width: 10.w),

                  // النصوص
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'لا توجد رحلات نشطة الآن',
                          style: AppTextStyles.style(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.white : AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'اضغط هنا للاطلاع على جدول ومواعيد الرحلات',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.style(
                            fontSize: 10.sp,
                            color: isDark ? AppColors.grey400 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // سهم التنقل (يشير لليسار في واجهة RTL للدلالة على المتابعة)
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey800 : AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13.r,
                      color: isDark ? AppColors.grey300 : primaryColor,
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
