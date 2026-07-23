import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../logic/upcoming_trips_cubit/upcoming_trips_cubit.dart';
import '../../logic/upcoming_trips_cubit/upcoming_trips_state.dart';

class UpcomingTripsScreen extends StatelessWidget {
  const UpcomingTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'الرحلات القادمة المجدولة',
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          foregroundColor: isDark ? AppColors.white : AppColors.textDark,
        ),
        body: BlocProvider(
          create: (context) => getIt<UpcomingTripsCubit>()..loadUpcomingTrips(),
          child: BlocBuilder<UpcomingTripsCubit, UpcomingTripsState>(
            builder: (context, state) {
              if (state is UpcomingTripsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is UpcomingTripsError) {
                return Center(
                  child: Text(
                    state.message,
                    style: AppTextStyles.style(color: AppColors.error),
                  ),
                );
              } else if (state is UpcomingTripsLoaded) {
                if (state.upcomingTrips.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد رحلات قادمة مجدولة.',
                      style: AppTextStyles.style(
                        color: isDark ? AppColors.grey400 : AppColors.textMuted,
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  color: context.primaryColor,
                  onRefresh: () => context.read<UpcomingTripsCubit>().loadUpcomingTrips(),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.upcomingTrips.length,
                    itemBuilder: (context, index) {
                      final trip = state.upcomingTrips[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.white,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(
                            color: isDark ? AppColors.grey800 : AppColors.grey200,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18.r,
                                  backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                                  child: Icon(Icons.directions_bus_rounded, color: context.primaryColor, size: 18.r),
                                ),
                                SizedBox(width: 12.w),
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
                                        'النوع: ${trip.tripType == 'to_school' ? 'ذهاب للمدرسة' : 'عودة للمنزل'}',
                                        style: AppTextStyles.style(
                                          fontSize: 11.sp,
                                          color: isDark ? AppColors.grey400 : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: context.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    trip.scheduledFor,
                                    style: AppTextStyles.style(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                      color: context.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            const Divider(height: 1),
                            SizedBox(height: 12.h),
                            _buildInfoRow(Icons.child_care_rounded, 'الطفل', trip.childName, isDark),
                            SizedBox(height: 6.h),
                            _buildInfoRow(Icons.school_rounded, 'المدرسة', trip.schoolName, isDark),
                            SizedBox(height: 6.h),
                            _buildInfoRow(Icons.person_rounded, 'السائق', trip.driverName, isDark),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14.r, color: isDark ? AppColors.grey500 : AppColors.grey400),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: AppTextStyles.style(
            fontSize: 12.sp,
            color: isDark ? AppColors.grey400 : AppColors.textMuted,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.style(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
