import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../data/models/active_trip_model.dart';
import '../../data/models/upcoming_trip_model.dart';
import '../../data/models/trip_history_model.dart';
import '../../logic/active_trip_cubit/active_trip_cubit.dart';
import '../../logic/active_trip_cubit/active_trip_state.dart';
import '../../logic/upcoming_trips_cubit/upcoming_trips_cubit.dart';
import '../../logic/upcoming_trips_cubit/upcoming_trips_state.dart';
import '../../logic/trip_history_cubit/trip_history_cubit.dart';
import '../../logic/trip_history_cubit/trip_history_state.dart';
import '../widgets/skeleton_loading_widget.dart';
import 'trip_tracking_screen.dart';

class TripsHomeScreen extends StatefulWidget {
  const TripsHomeScreen({super.key});

  @override
  State<TripsHomeScreen> createState() => _TripsHomeScreenState();
}

class _TripsHomeScreenState extends State<TripsHomeScreen> with SingleTickerProviderStateMixin {
  late final ActiveTripCubit _activeTripCubit;
  late final UpcomingTripsCubit _upcomingTripsCubit;
  late final TripHistoryCubit _historyCubit;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _activeTripCubit = getIt<ActiveTripCubit>()..loadActiveTrips();
    _upcomingTripsCubit = getIt<UpcomingTripsCubit>()..loadUpcomingTrips();
    _historyCubit = getIt<TripHistoryCubit>()..loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _activeTripCubit.refresh(),
      _upcomingTripsCubit.loadUpcomingTrips(),
      _historyCubit.refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _activeTripCubit),
        BlocProvider.value(value: _upcomingTripsCubit),
        BlocProvider.value(value: _historyCubit),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
          body: Column(
            children: [
              // Custom TabBar Header
              Container(
                color: isDark ? context.cardSurface : AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey900 : AppColors.grey100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: context.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: AppColors.white,
                    unselectedLabelColor: context.textMuted,
                    labelStyle: AppTextStyles.style(fontSize: 13.sp, fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: 'الرحلات الحالية'),
                      Tab(text: 'الرحلات القادمة'),
                      Tab(text: 'سجل الرحلات'),
                    ],
                  ),
                ),
              ),

              // TabBar View Body
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActiveTripsTab(context, isDark),
                    _buildUpcomingTripsTab(context, isDark),
                    _buildHistoryTab(context, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: Current Active Trips
  // -------------------------------------------------------------
  Widget _buildActiveTripsTab(BuildContext context, bool isDark) {
    return BlocBuilder<ActiveTripCubit, ActiveTripState>(
      builder: (context, state) {
        if (state is ActiveTripLoading) {
          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: 2,
            itemBuilder: (_, __) => const TripCardSkeleton(),
          );
        } else if (state is ActiveTripError) {
          return _buildErrorView(state.message);
        } else if (state is ActiveTripLoaded) {
          final trips = state.activeTrips;
          if (trips.isEmpty) {
            return _buildEmptyState(
              context,
              title: 'لا توجد رحلات نشطة حالياً',
              subtitle: 'سوف تظهر رحلات أطفالك المباشرة فور انطلاق الحافلة.',
              buttonText: 'عرض الرحلات القادمة',
              onPressed: () => _tabController.animateTo(1),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshAll,
            color: context.primaryColor,
            child: ListView.separated(
              padding: EdgeInsets.all(16.r),
              itemCount: trips.length,
              separatorBuilder: (_, __) => SizedBox(height: 14.h),
              itemBuilder: (context, index) {
                final trip = trips[index];
                return _buildActiveTripCard(context, trip, trips, isDark);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActiveTripCard(BuildContext context, ActiveTripModel trip, List<ActiveTripModel> allTrips, bool isDark) {
    final isMorning = trip.direction == 'to_school' || trip.tripType == 'morning';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.primaryColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isMorning ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                    size: 18.r,
                    color: isMorning ? context.primaryColor : AppColors.pending,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    isMorning ? 'رحلة الذهاب إلى المدرسة' : 'رحلة العودة إلى المنزل',
                    style: AppTextStyles.style(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: isMorning ? context.primaryColor : AppColors.pending,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'نشطة الآن 🟢',
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.success),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Driver Row
          Row(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                backgroundImage: trip.driver.photo != null && trip.driver.photo!.isNotEmpty
                    ? CachedNetworkImageProvider(trip.driver.photo!)
                    : null,
                child: trip.driver.photo == null || trip.driver.photo!.isEmpty
                    ? Icon(Icons.person_rounded, size: 24.r, color: context.primaryColor)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.driver.name.isNotEmpty ? trip.driver.name : 'السائق',
                      style: AppTextStyles.style(fontSize: 14.sp, fontWeight: FontWeight.bold, color: context.textPrimary),
                    ),
                    Text(
                      trip.vehicle.info,
                      style: AppTextStyles.style(fontSize: 12.sp, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'الوجهة',
                    style: AppTextStyles.style(fontSize: 10.sp, color: AppColors.textMuted),
                  ),
                  Text(
                    trip.destination.name,
                    style: AppTextStyles.style(fontSize: 12.sp, fontWeight: FontWeight.bold, color: context.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Action Button: Open Tracking Screen
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripTrackingScreen(
                      trip: trip,
                      allActiveTrips: allTrips,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: const Icon(Icons.map_rounded, size: 18),
              label: Text(
                'فتح التتبع الحي والمباشر',
                style: AppTextStyles.style(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 2: Upcoming Trips
  // -------------------------------------------------------------
  Widget _buildUpcomingTripsTab(BuildContext context, bool isDark) {
    return BlocBuilder<UpcomingTripsCubit, UpcomingTripsState>(
      builder: (context, state) {
        if (state is UpcomingTripsLoading) {
          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: 2,
            itemBuilder: (_, __) => const TripCardSkeleton(),
          );
        } else if (state is UpcomingTripsError) {
          return _buildErrorView(state.message);
        } else if (state is UpcomingTripsLoaded) {
          final trips = state.upcomingTrips;
          if (trips.isEmpty) {
            return _buildEmptyState(
              context,
              title: 'لا توجد رحلات قادمة',
              subtitle: 'لم يتم جدولة رحلات جديدة لأطفالك في الوقت الحالي.',
              buttonText: 'تحديث البيانات',
              onPressed: _refreshAll,
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshAll,
            color: context.primaryColor,
            child: ListView.separated(
              padding: EdgeInsets.all(16.r),
              itemCount: trips.length,
              separatorBuilder: (_, __) => SizedBox(height: 14.h),
              itemBuilder: (context, index) {
                final upcoming = trips[index];
                return _buildUpcomingTripCard(context, upcoming, isDark);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildUpcomingTripCard(BuildContext context, UpcomingTripModel trip, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trip.title,
                style: AppTextStyles.style(fontSize: 14.sp, fontWeight: FontWeight.bold, color: context.primaryColor),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.pending.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  trip.scheduledFor,
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.pending),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 18.r, color: AppColors.textMuted),
              SizedBox(width: 6.w),
              Text('السائق: ${trip.driverName}', style: AppTextStyles.style(fontSize: 13.sp, color: context.textPrimary)),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.school_outlined, size: 18.r, color: AppColors.textMuted),
              SizedBox(width: 6.w),
              Text('المدرسة: ${trip.schoolName}', style: AppTextStyles.style(fontSize: 13.sp, color: context.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 3: History
  // -------------------------------------------------------------
  Widget _buildHistoryTab(BuildContext context, bool isDark) {
    return BlocBuilder<TripHistoryCubit, TripHistoryState>(
      builder: (context, state) {
        if (state is TripHistoryLoading) {
          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: 3,
            itemBuilder: (_, __) => const TripCardSkeleton(),
          );
        } else if (state is TripHistoryError) {
          return _buildErrorView(state.message);
        } else if (state is TripHistoryLoaded) {
          final history = state.filteredTrips;
          final currentDirection = state.selectedDirection;

          return Column(
            children: [
              // Direction Filter Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                color: isDark ? context.cardSurface : AppColors.white,
                child: Row(
                  children: [
                    Text(
                      'تصفية:',
                      style: AppTextStyles.style(fontSize: 12.sp, fontWeight: FontWeight.bold, color: context.textPrimary),
                    ),
                    SizedBox(width: 8.w),
                    _buildFilterChip('الكل', 'all', currentDirection),
                    SizedBox(width: 6.w),
                    _buildFilterChip('الذهاب 🌅', 'to_school', currentDirection),
                    SizedBox(width: 6.w),
                    _buildFilterChip('العودة 🌆', 'to_home', currentDirection),
                  ],
                ),
              ),

              Expanded(
                child: history.isEmpty
                    ? _buildEmptyState(
                        context,
                        title: 'لا توجد نتائج بالسجل',
                        subtitle: 'لم نجد رحلات سابقة تطابق التصفية الحالية.',
                        buttonText: 'إعادة ضبط الفلتر',
                        onPressed: () => _historyCubit.filterByDirection('all'),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                            _historyCubit.loadMore();
                          }
                          return false;
                        },
                        child: RefreshIndicator(
                          onRefresh: _refreshAll,
                          color: context.primaryColor,
                          child: ListView.separated(
                            padding: EdgeInsets.all(16.r),
                            itemCount: history.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final item = history[index];
                              return _buildHistoryCard(context, item, isDark);
                            },
                          ),
                        ),
                      ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFilterChip(String label, String value, String selectedValue) {
    final isSelected = selectedValue == value;
    return GestureDetector(
      onTap: () => _historyCubit.filterByDirection(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor : (context.isDarkMode ? AppColors.grey800 : AppColors.grey100),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.white : context.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, TripHistoryModel item, bool isDark) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 20.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رحلة بتاريخ ${item.tripDate}',
                      style: AppTextStyles.style(fontSize: 13.sp, fontWeight: FontWeight.bold, color: context.textPrimary),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'السائق: ${item.driverName} ${item.childName.isNotEmpty ? "| " + item.childName : ""}',
                      style: AppTextStyles.style(fontSize: 11.sp, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Text(
                item.tripCost,
                style: AppTextStyles.style(fontSize: 13.sp, fontWeight: FontWeight.bold, color: context.primaryColor),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Mini Timeline Preview
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey900 : AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.play_circle_fill_rounded, size: 14.r, color: AppColors.success),
                    SizedBox(width: 4.w),
                    Text('الانطلاق: ${item.pickupTime.isNotEmpty ? item.pickupTime : "07:00 ص"}', style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted)),
                  ],
                ),
                Icon(Icons.arrow_forward_rounded, size: 14.r, color: AppColors.grey400),
                Row(
                  children: [
                    Icon(Icons.task_alt_rounded, size: 14.r, color: context.primaryColor),
                    SizedBox(width: 4.w),
                    Text('الوصول: ${item.dropoffTime.isNotEmpty ? item.dropoffTime : "07:35 ص"}', style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_bus_filled_outlined, size: 70.r, color: AppColors.grey400),
            SizedBox(height: 16.h),
            Text(title, style: AppTextStyles.style(fontSize: 16.sp, fontWeight: FontWeight.bold, color: context.textPrimary)),
            SizedBox(height: 6.h),
            Text(subtitle, textAlign: TextAlign.center, style: AppTextStyles.style(fontSize: 12.sp, color: AppColors.textMuted)),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Text(message, style: AppTextStyles.style(color: AppColors.error)),
      ),
    );
  }
}
