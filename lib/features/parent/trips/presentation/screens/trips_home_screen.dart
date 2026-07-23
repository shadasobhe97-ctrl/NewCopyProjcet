import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../logic/active_trip_cubit/active_trip_cubit.dart';
import '../../logic/active_trip_cubit/active_trip_state.dart';
import '../../logic/upcoming_trips_cubit/upcoming_trips_cubit.dart';
import '../../logic/upcoming_trips_cubit/upcoming_trips_state.dart';

class TripsHomeScreen extends StatefulWidget {
  const TripsHomeScreen({super.key});

  @override
  State<TripsHomeScreen> createState() => _TripsHomeScreenState();
}

class _TripsHomeScreenState extends State<TripsHomeScreen> {
  late final ActiveTripCubit _activeTripCubit;
  late final UpcomingTripsCubit _upcomingTripsCubit;

  @override
  void initState() {
    super.initState();
    _activeTripCubit = getIt<ActiveTripCubit>()..loadActiveTrips();
    _upcomingTripsCubit = getIt<UpcomingTripsCubit>()..loadUpcomingTrips();
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _activeTripCubit.refresh(),
      _upcomingTripsCubit.loadUpcomingTrips(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _activeTripCubit),
        BlocProvider.value(value: _upcomingTripsCubit),
      ],
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        body: RefreshIndicator(
          color: context.primaryColor,
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── قسم الرحلة النشطة حالياً ───
                _buildActiveTripSection(context, isDark),
                SizedBox(height: 24.h),

                // ─── قسم الرحلات القادمة ───
                _buildUpcomingTripsSection(context, isDark),
                SizedBox(height: 24.h),

                // ─── قسم سجل الرحلات ───
                _buildHistorySection(context, isDark),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // قسم الرحلة النشطة
  // ─────────────────────────────────────────────
  Widget _buildActiveTripSection(BuildContext context, bool isDark) {
    return BlocBuilder<ActiveTripCubit, ActiveTripState>(
      builder: (context, state) {
        if (state is ActiveTripLoading) {
          return Container(
            height: 180.h,
            width: double.infinity,
            decoration: _cardDeco(isDark),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        } else if (state is ActiveTripError) {
          return _buildInfoBanner(
            title: 'حدث خطأ أثناء تحميل الرحلة النشطة',
            subtitle: state.message,
            icon: Icons.error_outline_rounded,
            color: AppColors.error,
            isDark: isDark,
          );
        } else if (state is ActiveTripLoaded && state.activeTrips.isNotEmpty) {
          final trip = state.activeTrips.first;
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.primaryColor, context.primaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: context.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الهيدر
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: AppColors.success, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'رحلة نشطة الآن',
                            style: AppTextStyles.style(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      trip.tripType == 'both'
                          ? 'ذهاب وعودة'
                          : (trip.tripType == 'to_school' ? 'ذهاب للمدرسة' : 'عودة للمنزل'),
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white70,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // بيانات الطفل والسائق
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22.r,
                      backgroundColor: AppColors.white.withValues(alpha: 0.2),
                      child: Icon(Icons.child_care_rounded, color: AppColors.white, size: 24.r),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.childName,
                            style: AppTextStyles.style(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'السائق: ${trip.driverName} • ${trip.vehicleInfo}',
                            style: AppTextStyles.style(
                              fontSize: 12.sp,
                              color: AppColors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // زر الاتصال
                    IconButton(
                      icon: CircleAvatar(
                        radius: 20.r,
                        backgroundColor: AppColors.white.withValues(alpha: 0.25),
                        child: const Icon(Icons.phone_in_talk_rounded, color: AppColors.white, size: 18),
                      ),
                      onPressed: () => _callNumber(trip.driverPhone),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                const Divider(color: AppColors.white24, height: 1),
                SizedBox(height: 12.h),

                // حالة الطفل
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: AppColors.white70, size: 16.r),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'الحالة: ${trip.childStatus}',
                        style: AppTextStyles.style(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    if (trip.waitingTimer != null)
                      Text(
                        'الانتظار: ${trip.waitingTimer}',
                        style: AppTextStyles.style(
                          fontSize: 11.sp,
                          color: AppColors.white70,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16.h),

                // زر التتبع اللحظي
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: context.primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    icon: Icon(Icons.map_rounded, size: 18.r, color: context.primaryColor),
                    label: Text(
                      'تتبع الرحلة 📍',
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: context.primaryColor,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.parentTripTracking,
                        arguments: trip,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        // لا توجد رحلة نشطة حالياً
        return _buildInfoBanner(
          title: 'لا توجد رحلة نشطة حالياً 🚌',
          subtitle: 'سوف تظهر هنا تفاصيل التتبع فور بدء السائق للرحلة اليومية لأطفالك.',
          icon: Icons.directions_bus_rounded,
          color: context.primaryColor,
          isDark: isDark,
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // قسم الرحلات القادمة
  // ─────────────────────────────────────────────
  Widget _buildUpcomingTripsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: context.primaryColor, size: 20.r),
            SizedBox(width: 8.w),
            Text(
              'الرحلات القادمة المجدولة',
              style: AppTextStyles.style(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        BlocBuilder<UpcomingTripsCubit, UpcomingTripsState>(
          builder: (context, state) {
            if (state is UpcomingTripsLoading) {
              return const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ));
            } else if (state is UpcomingTripsError) {
              return Text(
                'فشل في تحميل الرحلات القادمة: ${state.message}',
                style: AppTextStyles.style(fontSize: 12.sp, color: AppColors.error),
              );
            } else if (state is UpcomingTripsLoaded && state.upcomingTrips.isNotEmpty) {
              final trip = state.upcomingTrips.first;
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: _cardDeco(isDark),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18.r,
                          backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                          child: Icon(Icons.alarm_rounded, color: context.primaryColor, size: 18.r),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.title,
                                style: AppTextStyles.style(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.white : AppColors.textDark,
                                ),
                              ),
                              Text(
                                'الطفل: ${trip.childName} • مجدولة لـ ${trip.scheduledFor}',
                                style: AppTextStyles.style(
                                  fontSize: 11.sp,
                                  color: isDark ? AppColors.grey400 : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    const Divider(height: 1),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'المدرسة: ${trip.schoolName}',
                          style: AppTextStyles.style(
                            fontSize: 12.sp,
                            color: isDark ? AppColors.grey300 : AppColors.textDark,
                          ),
                        ),
                        Text(
                          'السائق: ${trip.driverName}',
                          style: AppTextStyles.style(
                            fontSize: 11.sp,
                            color: isDark ? AppColors.grey400 : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: context.primaryColor.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                        child: Text(
                          'عرض جميع الرحلات القادمة',
                          style: AppTextStyles.style(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: context.primaryColor,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.parentUpcomingTrips);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: _cardDeco(isDark),
              alignment: Alignment.center,
              child: Text(
                'لا توجد رحلات مجدولة قريباً.',
                style: AppTextStyles.style(
                  fontSize: 12.sp,
                  color: isDark ? AppColors.grey400 : AppColors.textMuted,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // قسم سجل الرحلات
  // ─────────────────────────────────────────────
  Widget _buildHistorySection(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDeco(isDark),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundColor: AppColors.success.withValues(alpha: 0.1),
            child: const Icon(Icons.history_rounded, color: AppColors.success, size: 22),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سجل الرحلات المكتملة',
                  style: AppTextStyles.style(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
                Text(
                  'تصفح سجل العمليات والتكاليف والرحلات السابقة.',
                  style: AppTextStyles.style(
                    fontSize: 11.sp,
                    color: isDark ? AppColors.grey400 : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded, color: context.primaryColor, size: 18.r),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.parentTripHistory);
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────
  BoxDecoration _cardDeco(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColors.surfaceDark : AppColors.white,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
          blurRadius: 10,
          offset: const Offset(0, 3),
        )
      ],
    );
  }

  Widget _buildInfoBanner({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: _cardDeco(isDark),
      child: Column(
        children: [
          CircleAvatar(
            radius: 26.r,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 28.r),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 11.5.sp,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callNumber(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
