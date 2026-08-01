import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_user_avatar.dart';
import '../../data/models/active_trip_model.dart';
import '../../logic/trip_tracking_cubit/trip_tracking_cubit.dart';
import '../../logic/trip_tracking_cubit/trip_tracking_state.dart';
import '../widgets/tracking_map_widget.dart';
import '../widgets/driver_card.dart';
import '../widgets/trip_status_chip.dart';
import 'trip_details_screen.dart';

class ChildTrackingScreen extends StatefulWidget {
  final int childId;
  final String childName;
  final String? childPhoto;
  final ActiveTripModel trip;

  const ChildTrackingScreen({
    super.key,
    required this.childId,
    required this.childName,
    this.childPhoto,
    required this.trip,
  });

  @override
  State<ChildTrackingScreen> createState() => _ChildTrackingScreenState();
}

class _ChildTrackingScreenState extends State<ChildTrackingScreen> {
  late final TripTrackingCubit _trackingCubit;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _trackingCubit = getIt<TripTrackingCubit>();

    _trackingCubit.startTracking(
      widget.trip.tripId,
      activeTrip: widget.trip,
      childId: widget.childId,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final childInfo = widget.trip.children.firstWhere(
      (c) => c.childId == widget.childId,
      orElse: () => widget.trip.children.first,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'تتبع ${widget.childName.split(" ")[0]}',
            style: AppTextStyles.style(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          centerTitle: true,
          backgroundColor: isDark ? context.cardSurface : AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: context.primaryColor, size: 20.r),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_none_rounded, color: context.textPrimary),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            // 1) TOP CHILD HEADER & 3 METRIC CARDS
            Container(
              color: isDark ? context.cardSurface : AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                children: [
                  Row(
                    children: [
                      AppUserAvatar(
                        imageUrl: widget.childPhoto ?? childInfo.childPhoto,
                        radius: 22.r,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.childName,
                              style: AppTextStyles.style(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'في الطريق إلى ${widget.trip.destination.name}',
                              style: AppTextStyles.style(
                                fontSize: 11.sp,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TripStatusChip.fromStatusString(childInfo.childStatus),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _buildMetricCard(context, Icons.flag_rounded, 'وقت الانطلاق', widget.trip.startedAt),
                      SizedBox(width: 8.w),
                      _buildMetricCard(context, Icons.access_time_rounded, 'الوقت المتبقي', '20 دقيقة'),
                      SizedBox(width: 8.w),
                      _buildMetricCard(context, Icons.alt_route_rounded, 'المسافة المتبقية', '2.4 كم'),
                    ],
                  ),
                ],
              ),
            ),

            // 2) MIDDLE MAP VIEW
            Expanded(
              flex: 5,
              child: BlocProvider.value(
                value: _trackingCubit,
                child: BlocBuilder<TripTrackingCubit, TripTrackingState>(
                  builder: (context, state) {
                    return TrackingMapWidget(
                      mapController: _mapController,
                      isMultiMode: false,
                      singleTrack: state is TripTrackingSingleLoaded ? state.trackData : null,
                      singleTrip: widget.trip,
                    );
                  },
                ),
              ),
            ),

            // 3) BOTTOM DRIVER & TRIP STATUS CARDS
            Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isDark ? context.cardSurface : AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ListView(
                  children: [
                    DriverCard(driver: widget.trip.driver),
                    SizedBox(height: 12.h),
                    _buildChildStatusCard(context, childInfo, isDark),
                    SizedBox(height: 14.h),
                    SizedBox(
                      width: double.infinity,
                      height: 46.h,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TripDetailsScreen(tripId: widget.trip.tripId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.assignment_outlined, size: 18),
                        label: Text(
                          'عرض تفاصيل الرحلة بالكامل',
                          style: AppTextStyles.style(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, IconData icon, String title, String value) {
    final isDark = context.isDarkMode;
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey900 : AppColors.grey50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16.r, color: context.primaryColor),
            SizedBox(height: 4.h),
            Text(
              title,
              style: AppTextStyles.style(
                fontSize: 10.sp,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              value,
              style: AppTextStyles.style(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildStatusCard(BuildContext context, TripChildInfo child, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey900 : AppColors.grey50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة ${widget.childName.split(" ")[0]} في الرحلة',
            style: AppTextStyles.style(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.check_circle_rounded, size: 16.r, color: AppColors.success),
              SizedBox(width: 8.w),
              Text(
                'تم الصعود',
                style: AppTextStyles.style(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                child.pickupTime ?? '07:35 AM',
                style: AppTextStyles.style(
                  fontSize: 11.sp,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 16.r, color: context.primaryColor),
              SizedBox(width: 8.w),
              Text(
                'الوجهة: ',
                style: AppTextStyles.style(
                  fontSize: 11.sp,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                widget.trip.destination.name,
                style: AppTextStyles.style(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
