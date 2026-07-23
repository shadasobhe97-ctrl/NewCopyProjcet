import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../logic/trip_history_cubit/trip_history_cubit.dart';
import '../../logic/trip_history_cubit/trip_history_state.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'سجل الرحلات',
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
          create: (context) => getIt<TripHistoryCubit>()..loadHistory(),
          child: BlocBuilder<TripHistoryCubit, TripHistoryState>(
            builder: (context, state) {
              if (state is TripHistoryLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TripHistoryError) {
                return Center(
                  child: Text(
                    state.message,
                    style: AppTextStyles.style(color: AppColors.error),
                  ),
                );
              } else if (state is TripHistoryLoaded) {
                if (state.historyTrips.isEmpty) {
                  return Center(
                    child: Text(
                      'سجل الرحلات فارغ حالياً.',
                      style: AppTextStyles.style(
                        color: isDark ? AppColors.grey400 : AppColors.textMuted,
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  color: context.primaryColor,
                  onRefresh: () => context.read<TripHistoryCubit>().refresh(),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.historyTrips.length + 1,
                    itemBuilder: (context, index) {
                      if (index == state.historyTrips.length) {
                        // زر تحميل المزيد
                        if (state.hasMore) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48.h,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.primaryColor,
                                  foregroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  context.read<TripHistoryCubit>().loadMore();
                                },
                                child: Text(
                                  'تحميل المزيد',
                                  style: AppTextStyles.style(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.h),
                            child: Center(
                              child: Text(
                                'نهاية السجل',
                                style: AppTextStyles.style(
                                  fontSize: 12.sp,
                                  color: isDark ? AppColors.grey500 : AppColors.grey400,
                                ),
                              ),
                            ),
                          );
                        }
                      }

                      final trip = state.historyTrips[index];
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
                                  backgroundColor: AppColors.success.withValues(alpha: 0.1),
                                  child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'رحلة #${trip.tripId}',
                                        style: AppTextStyles.style(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.white : AppColors.textDark,
                                        ),
                                      ),
                                      Text(
                                        '${trip.tripDate} • ${trip.tripType == 'to_school' ? 'ذهاب للمدرسة' : 'عودة للمنزل'}',
                                        style: AppTextStyles.style(
                                          fontSize: 11.sp,
                                          color: isDark ? AppColors.grey400 : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: context.primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    '${trip.tripCost} د.ل',
                                    style: AppTextStyles.style(
                                      fontSize: 12.sp,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTextItem('الطفل: ${trip.childName}', isDark),
                                    SizedBox(height: 4.h),
                                    _buildTextItem('السائق: ${trip.driverName}', isDark),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        trip.actionType,
                                        style: AppTextStyles.style(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'المسح: ${trip.scannedAt}',
                                      style: AppTextStyles.style(
                                        fontSize: 10.sp,
                                        color: isDark ? AppColors.grey400 : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  Widget _buildTextItem(String text, bool isDark) {
    return Text(
      text,
      style: AppTextStyles.style(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.grey300 : AppColors.textDark,
      ),
    );
  }
}
