import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../data/models/active_trip_model.dart';
import '../../data/datasources/trips_mock_data.dart';
import '../../logic/trip_tracking_cubit/trip_tracking_cubit.dart';
import '../../logic/trip_tracking_cubit/trip_tracking_state.dart';
import '../widgets/messenger_children_bar.dart';
import '../widgets/tracking_map_widget.dart';
import '../widgets/trip_status_chip.dart';
import 'child_tracking_screen.dart';
import 'full_tracking_map_screen.dart';
import 'trip_details_screen.dart';

class TripTrackingScreen extends StatefulWidget {
  final ActiveTripModel? trip;
  final List<ActiveTripModel> allActiveTrips;

  const TripTrackingScreen({
    super.key,
    this.trip,
    this.allActiveTrips = const [],
  });

  @override
  State<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends State<TripTrackingScreen> {
  late final TripTrackingCubit _trackingCubit;
  late final MapController _mapController;

  bool _isAllSelected = true;
  int? _selectedChildId;
  ActiveTripModel? _currentDisplayedTrip;
  List<ActiveTripModel> _effectiveTrips = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _trackingCubit = getIt<TripTrackingCubit>();

    if (widget.allActiveTrips.isNotEmpty) {
      _effectiveTrips = widget.allActiveTrips;
    } else if (widget.trip != null) {
      _effectiveTrips = [widget.trip!];
    } else {
      _effectiveTrips = TripsMockData.activeTrips;
    }

    if (_effectiveTrips.isNotEmpty) {
      _currentDisplayedTrip = widget.trip ?? _effectiveTrips.first;
      _trackingCubit.startMultiTracking(activeTrips: _effectiveTrips);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<MessengerChildItem> _extractChildrenItems() {
    final List<MessengerChildItem> items = [];
    final Set<int> addedChildIds = {};

    for (final trip in _effectiveTrips) {
      for (final child in trip.children) {
        if (!addedChildIds.contains(child.childId)) {
          addedChildIds.add(child.childId);
          items.add(
            MessengerChildItem(
              childId: child.childId,
              childName: child.childName,
              childPhoto: child.childPhoto,
              childStatus: child.childStatus,
              tripId: trip.tripId,
            ),
          );
        }
      }
    }
    return items;
  }

  void _onSelectAll() {
    setState(() {
      _isAllSelected = true;
      _selectedChildId = null;
      if (_effectiveTrips.isNotEmpty) {
        _currentDisplayedTrip = _effectiveTrips.first;
      }
    });
    _trackingCubit.startMultiTracking(activeTrips: _effectiveTrips);
  }

  void _onSelectChild(MessengerChildItem item) {
    ActiveTripModel? targetTrip;
    try {
      targetTrip = _effectiveTrips.firstWhere((t) => t.tripId == item.tripId);
    } catch (_) {
      targetTrip = null;
    }

    setState(() {
      _isAllSelected = false;
      _selectedChildId = item.childId;
      _currentDisplayedTrip = targetTrip;
    });

    if (targetTrip != null) {
      // Navigate to dedicated Child Tracking Screen (Screenshot #2)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChildTrackingScreen(
            childId: item.childId,
            childName: item.childName,
            childPhoto: item.childPhoto,
            trip: targetTrip!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final childrenItems = _extractChildrenItems();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'تتبع أبنائي',
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 17.sp,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark ? AppColors.white : AppColors.textDark,
              size: 18.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // 1) TOP MESSENGER STORIES BAR
            if (childrenItems.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: MessengerChildrenBar(
                  children: childrenItems,
                  isAllSelected: _isAllSelected,
                  selectedChildId: _selectedChildId,
                  activeTripsCount: _effectiveTrips.length,
                  onSelectAll: _onSelectAll,
                  onSelectChild: _onSelectChild,
                ),
              ),

            // 2) MIDDLE INTERACTIVE MAP WITH FLOATING EXPAND BUTTON
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: BlocProvider.value(
                      value: _trackingCubit,
                      child: BlocBuilder<TripTrackingCubit, TripTrackingState>(
                        builder: (context, state) {
                          return TrackingMapWidget(
                            mapController: _mapController,
                            isMultiMode: _isAllSelected || state is TripTrackingMultiLoaded,
                            singleTrack: state is TripTrackingSingleLoaded ? state.trackData : null,
                            singleTrip: _currentDisplayedTrip,
                            multiTracks: state is TripTrackingMultiLoaded ? state.tracks : [],
                            multiTrips: _effectiveTrips,
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16.h,
                    left: 16.w,
                    child: FloatingActionButton.small(
                      heroTag: 'expand_map_main',
                      backgroundColor: isDark ? AppColors.grey400 : AppColors.white,
                      elevation: 4,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullTrackingMapScreen(
                              selectedTrip: _currentDisplayedTrip,
                              allTrips: _effectiveTrips,
                            ),
                          ),
                        );
                      },
                      child: Icon(Icons.fullscreen_rounded, color: context.primaryColor, size: 24.r),
                    ),
                  ),
                ],
              ),
            ),

            // 3) BOTTOM DRAGGABLE LIST OF ACTIVE TRIPS (Matching Screenshot #1)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? context.cardSurface : AppColors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 10.h, bottom: 6.h),
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.grey700 : AppColors.grey300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                      child: Text(
                        'الرحلات النشطة (${_effectiveTrips.length})',
                        style: AppTextStyles.style(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        itemCount: _effectiveTrips.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final trip = _effectiveTrips[index];
                          return _buildActiveTripCard(context, trip, isDark);
                        },
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

  Widget _buildActiveTripCard(BuildContext context, ActiveTripModel trip, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailsScreen(tripId: trip.tripId),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey900 : AppColors.grey50,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                  child: Icon(Icons.person_rounded, color: context.primaryColor, size: 22.r),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.driver.name,
                        style: AppTextStyles.style(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        trip.vehicle.info,
                        style: AppTextStyles.style(
                          fontSize: 10.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TripStatusChip.fromStatusString(trip.status),
                    SizedBox(height: 4.h),
                    Text(
                      trip.startedAt,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Divider(height: 16.h, thickness: 1),
            Row(
              children: [
                Text(
                  'الأطفال: ',
                  style: AppTextStyles.style(
                    fontSize: 10.sp,
                    color: AppColors.textMuted,
                  ),
                ),
                ...trip.children.map((c) {
                  return Padding(
                    padding: EdgeInsets.only(left: 6.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 8.r,
                          child: Icon(Icons.person, size: 8.r),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          c.childName.split(' ')[0],
                          style: AppTextStyles.style(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
