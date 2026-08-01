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
import '../widgets/driver_card.dart';
import '../widgets/trip_status_chip.dart';
import 'full_tracking_map_screen.dart';
import 'trip_details_screen.dart';

class TripTrackingScreen extends StatefulWidget {
  final ActiveTripModel? trip;
  final List<ActiveTripModel> allActiveTrips;
  final int? initialSelectedChildId;

  const TripTrackingScreen({
    super.key,
    this.trip,
    this.allActiveTrips = const [],
    this.initialSelectedChildId,
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

    if (widget.initialSelectedChildId != null) {
      _isAllSelected = false;
      _selectedChildId = widget.initialSelectedChildId;
    }

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

  // 🌟 UX FIX: Selecting a child story updates page mode dynamically without pushing a new screen!
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
      _trackingCubit.startTracking(
        targetTrip.tripId,
        activeTrip: targetTrip,
        childId: item.childId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final childrenItems = _extractChildrenItems();

    // Selected child info if single child mode is active
    MessengerChildItem? selectedChildItem;
    if (!_isAllSelected && _selectedChildId != null) {
      try {
        selectedChildItem = childrenItems.firstWhere((c) => c.childId == _selectedChildId);
      } catch (_) {}
    }

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
            // 1) TOP STORIES BAR (RTL)
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

            // 2) MIDDLE INTERACTIVE MAP WITH EXPAND BUTTON
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
                              selectedTrip: _isAllSelected ? null : _currentDisplayedTrip,
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

            // 3) DYNAMIC BOTTOM SHEET (MODE 1: ALL TRIPS | MODE 2: SINGLE CHILD TRIP)
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
                        _isAllSelected
                            ? 'الرحلات النشطة (${_effectiveTrips.length})'
                            : 'تتبع رحلة ${selectedChildItem?.childName ?? "الطفل"}',
                        style: AppTextStyles.style(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _isAllSelected
                          ? ListView.separated(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                              itemCount: _effectiveTrips.length,
                              separatorBuilder: (context, index) => SizedBox(height: 10.h),
                              itemBuilder: (context, index) {
                                final trip = _effectiveTrips[index];
                                return _buildActiveTripCard(context, trip, isDark);
                              },
                            )
                          : _buildSingleChildTripContent(
                              context,
                              selectedChildItem,
                              _currentDisplayedTrip,
                              isDark,
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

  // MODE 1 CARD: Active Trip Item Card in Trips List Mode
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

  // MODE 2 CONTENT: Single Child Trip View inside Bottom Sheet without page navigation
  Widget _buildSingleChildTripContent(
    BuildContext context,
    MessengerChildItem? childItem,
    ActiveTripModel? trip,
    bool isDark,
  ) {
    if (trip == null || childItem == null) {
      return Center(
        child: Text(
          'لا توجد رحلة نشطة لهذا الطفل حالياً',
          style: AppTextStyles.style(fontSize: 13.sp, color: AppColors.textMuted),
        ),
      );
    }

    final childInfo = trip.children.firstWhere(
      (c) => c.childId == childItem.childId,
      orElse: () => trip.children.first,
    );

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      children: [
        // 1) 3 METRIC CARDS ROW
        Row(
          children: [
            _buildMetricCard(context, Icons.flag_rounded, 'وقت الانطلاق', trip.startedAt),
            SizedBox(width: 8.w),
            _buildMetricCard(context, Icons.access_time_rounded, 'الوقت المتبقي', '20 دقيقة'),
            SizedBox(width: 8.w),
            _buildMetricCard(context, Icons.alt_route_rounded, 'المسافة المتبقية', '2.4 كم'),
          ],
        ),
        SizedBox(height: 12.h),

        // 2) DRIVER CARD WITH CALL / CHAT BUTTONS
        DriverCard(driver: trip.driver),
        SizedBox(height: 12.h),

        // 3) CHILD STATUS CARD IN TRIP
        Container(
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
                'حالة ${childItem.childName.split(" ")[0]} في الرحلة',
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
                    childInfo.pickupTime ?? '07:35 AM',
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
                    trip.destination.name,
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
        ),
        SizedBox(height: 14.h),

        // 4) ACTION BUTTON: FULL TRIP DETAILS
        SizedBox(
          width: double.infinity,
          height: 46.h,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripDetailsScreen(tripId: trip.tripId),
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
}
