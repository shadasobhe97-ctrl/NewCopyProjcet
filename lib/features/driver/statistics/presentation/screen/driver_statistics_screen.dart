import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../logic/cubit/driver_statistics_cubit.dart';
import '../../logic/state/driver_statistics_state.dart';
import '../widget/earnings_summary_card.dart';
import '../widget/activity_summary_card.dart';
import '../widget/vehicle_capacity_card.dart';
import '../widget/subscription_history_card.dart';
import '../widget/trip_operations_card.dart';
import '../widget/expiring_subscriptions_card.dart';
import '../widget/documents_status_card.dart';

class DriverStatisticsScreen extends StatefulWidget {
  const DriverStatisticsScreen({super.key});

  @override
  State<DriverStatisticsScreen> createState() => _DriverStatisticsScreenState();
}

class _DriverStatisticsScreenState extends State<DriverStatisticsScreen> {
  final List<String> _arabicMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF4F6FA),
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          elevation: 0.5,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: isDark ? AppColors.white : AppColors.textDark,
          ),
          title: Text(
            'نشاطي وأرباحي',
            style: AppTextStyles.style(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.calendar_month_rounded,
                color: theme.colorScheme.primary,
                size: 22.r,
              ),
              tooltip: 'تحديد الشهر والسنة',
              onPressed: () => _showMonthYearPicker(context),
            ),
          ],
        ),
        body: BlocBuilder<DriverStatisticsCubit, DriverStatisticsState>(
          builder: (context, state) {
            if (state is DriverStatisticsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is DriverStatisticsError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 60.r,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.style(
                          fontSize: 14.sp,
                          color: isDark ? AppColors.white : AppColors.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<DriverStatisticsCubit>().loadStatistics(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(
                          'إعادة المحاولة',
                          style: AppTextStyles.style(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                            color: AppColors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is DriverStatisticsSuccess) {
              final stats = state.statistics;
              final quickWidgets = stats.quickWidgets;

              return RefreshIndicator(
                onRefresh: () =>
                    context.read<DriverStatisticsCubit>().refreshStatistics(),
                child: ListView(
                  padding: EdgeInsets.all(16.w),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    // فلتر تاريخ اختياري عند تحديده
                    if (state.selectedMonth != null && state.selectedYear != null) ...[
                      _selectedDateBanner(
                        context,
                        state.selectedMonth!,
                        state.selectedYear!,
                        isDark,
                      ),
                      SizedBox(height: 14.h),
                    ],

                    // 1. الأرباح المالية
                    EarningsSummaryCard(financialStats: stats.financialStats),
                    SizedBox(height: 14.h),

                    // 2. ملخص النشاط السريع
                    ActivitySummaryCard(
                      activeStudentsCount: stats
                          .subscriptionAndPassengerStats.activeStudentsCount,
                      completedTripsCount:
                          stats.tripOperationsStats.completedTrips.total,
                      punctualityRate: stats.tripOperationsStats.punctualityRate,
                    ),
                    SizedBox(height: 14.h),

                    // 3. المركبة ونسبة الإشغال
                    VehicleCapacityCard(
                      capacity:
                          stats.subscriptionAndPassengerStats.vehicleCapacity,
                    ),
                    SizedBox(height: 14.h),

                    // 4. سجل الاشتراكات
                    SubscriptionHistoryCard(
                      history: stats.subscriptionAndPassengerStats.history,
                    ),
                    SizedBox(height: 14.h),

                    // 5. عمليات الرحلات
                    TripOperationsCard(
                      tripStats: stats.tripOperationsStats,
                    ),
                    SizedBox(height: 14.h),

                    // 6. اشتراكات قاربت على الانتهاء
                    if (quickWidgets?.expiringSoonSubscriptions != null) ...[
                      ExpiringSubscriptionsCard(
                        expiringSoon: quickWidgets!.expiringSoonSubscriptions!,
                      ),
                      SizedBox(height: 14.h),
                    ],

                    // 7. حالة الوثائق الرسمية
                    if (quickWidgets?.documentsStatus != null) ...[
                      DocumentsStatusCard(
                        documentsStatus: quickWidgets!.documentsStatus!,
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _selectedDateBanner(
    BuildContext context,
    int month,
    int year,
    bool isDark,
  ) {
    final monthName = (month >= 1 && month <= 12)
        ? _arabicMonths[month - 1]
        : '$month';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_alt_rounded,
                size: 16.r,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                'عرض إحصائيات: $monthName $year',
                style: AppTextStyles.style(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => context.read<DriverStatisticsCubit>().resetFilter(),
            child: Row(
              children: [
                Text(
                  'الشهر الحالي',
                  style: AppTextStyles.style(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.close_rounded, size: 14.r, color: AppColors.error),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthYearPicker(BuildContext context) {
    final now = DateTime.now();
    int selectedM = now.month;
    int selectedY = now.year;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceDark
          : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.grey400,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'اختر الشهر والسنة',
                    style: AppTextStyles.style(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      // اختيار الشهر
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: selectedM,
                          decoration: InputDecoration(
                            labelText: 'الشهر',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          items: List.generate(12, (index) {
                            return DropdownMenuItem<int>(
                              value: index + 1,
                              child: Text(_arabicMonths[index]),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedM = val);
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // اختيار السنة
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: selectedY,
                          decoration: InputDecoration(
                            labelText: 'السنة',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          items: List.generate(5, (index) {
                            final y = now.year - 2 + index;
                            return DropdownMenuItem<int>(
                              value: y,
                              child: Text('$y'),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedY = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<DriverStatisticsCubit>().filterByDate(
                              month: selectedM,
                              year: selectedY,
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'عرض الإحصائيات',
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
          },
        );
      },
    );
  }
}
