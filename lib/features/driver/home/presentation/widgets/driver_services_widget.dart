import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/requests/logic/driver_location_change_cubit.dart';

class DriverServicesWidget extends StatelessWidget {
  const DriverServicesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الخدمات السريعة',
          style: AppTextStyles.style(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.white : AppColors.textDark,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 118.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // 1. كرت طلبات التعديل (باللون الأحمر مع العداد)
              BlocBuilder<DriverLocationChangeCubit, DriverLocationChangeState>(
                builder: (context, state) {
                  int pendingCount = 0;
                  if (state is DriverLocationChangeLoaded) {
                    pendingCount = state.pendingCount;
                  } else {
                    pendingCount =
                        context.read<DriverLocationChangeCubit>().pendingCount;
                  }

                  return _buildRedLocationChangeCard(
                    context,
                    title: 'طلبات التعديل',
                    subtitle: 'تغيير الموقع',
                    badgeCount: pendingCount,
                    isDark: isDark,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.driverLocationChangeRequests,
                      ).then((_) {
                        if (context.mounted) {
                          context
                              .read<DriverLocationChangeCubit>()
                              .fetchPendingCount();
                        }
                      });
                    },
                  );
                },
              ),

              // 2. كرت التفضيلات
              _buildStandardServiceCard(
                context,
                title: 'التفضيلات',
                subtitle: 'تخصيص النطاق',
                icon: Icons.tune_rounded,
                color: context.primaryColor,
                isDark: isDark,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.driverPreferences,
                ),
              ),

              // 3. كرت الإحصائيات
              _buildStandardServiceCard(
                context,
                title: 'الإحصائيات',
                subtitle: 'أداء السائق',
                icon: Icons.bar_chart_rounded,
                color: AppColors.accentBlue,
                isDark: isDark,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.driverStatistics,
                ),
              ),

              // 4. كرت سجل الرحلات
              _buildStandardServiceCard(
                context,
                title: 'سجل الرحلات',
                subtitle: 'الرحلات السابقة',
                icon: Icons.history_rounded,
                color: AppColors.success,
                isDark: isDark,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.driverTripsHistory,
                ),
              ),

              // 5. كرت تسجيل الغياب
              _buildStandardServiceCard(
                context,
                title: 'إدارة الغياب',
                subtitle: 'الطلبات المسبقة',
                icon: Icons.event_busy_rounded,
                color: AppColors.pending,
                isDark: isDark,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.driverAbsence,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// بناء كرت طلبات التعديل باللون الأحمر المميز مع عداد التنبيهات
  Widget _buildRedLocationChangeCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int badgeCount,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    const redColor = AppColors.error;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 110.w,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey900 : AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: redColor.withValues(alpha: isDark ? 0.6 : 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: redColor.withValues(alpha: isDark ? 0.25 : 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: redColor.withValues(alpha: isDark ? 0.2 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_location_alt_rounded,
                    color: redColor,
                    size: 22.r,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.style(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: redColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.style(
                    fontSize: 8.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // العداد المميز (Badge Counter)
          if (badgeCount > 0)
            Positioned(
              top: -2.h,
              right: 0.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: redColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                constraints: BoxConstraints(
                  minWidth: 20.w,
                  minHeight: 20.h,
                ),
                child: Center(
                  child: Text(
                    badgeCount.toString(),
                    style: AppTextStyles.style(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStandardServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 108.w,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey900 : AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20.r,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.style(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.style(
                fontSize: 8.sp,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
