import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../data/models/active_trip_model.dart';
import '../../logic/trip_tracking_cubit/trip_tracking_cubit.dart';
import '../../logic/trip_tracking_cubit/trip_tracking_state.dart';
import '../widgets/messenger_children_bar.dart';
import '../widgets/tracking_map_widget.dart';
import '../widgets/tracking_bottom_sheet.dart';
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

  bool _isAllSelected = false;
  int? _selectedChildId;
  ActiveTripModel? _currentDisplayedTrip;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _trackingCubit = getIt<TripTrackingCubit>();

    if (widget.allActiveTrips.isNotEmpty) {
      _trackingCubit.setAllActiveTrips(widget.allActiveTrips);
    }

    if (widget.trip != null) {
      _currentDisplayedTrip = widget.trip;
      if (widget.trip!.children.isNotEmpty) {
        _selectedChildId = widget.trip!.children.first.childId;
      }
      _trackingCubit.startTracking(widget.trip!.tripId, activeTrip: widget.trip);
    } else if (widget.allActiveTrips.isNotEmpty) {
      _isAllSelected = true;
      _currentDisplayedTrip = widget.allActiveTrips.first;
      _trackingCubit.startMultiTracking(activeTrips: widget.allActiveTrips);
    } else {
      _trackingCubit.startMultiTracking();
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<MessengerChildItem> _extractChildrenItems() {
    final List<MessengerChildItem> items = [];
    final tripsToScan = widget.allActiveTrips.isNotEmpty
        ? widget.allActiveTrips
        : (widget.trip != null ? [widget.trip!] : <ActiveTripModel>[]);

    for (var t in tripsToScan) {
      for (var c in t.children) {
        items.add(
          MessengerChildItem(
            childId: c.childId,
            childName: c.childName,
            childPhoto: c.childPhoto,
            childStatus: c.childStatus,
            tripId: t.tripId,
          ),
        );
      }
    }
    return items;
  }

  void _onSelectAll() {
    setState(() {
      _isAllSelected = true;
      _selectedChildId = null;
    });
    _trackingCubit.startMultiTracking(activeTrips: widget.allActiveTrips);
  }

  void _onSelectChild(MessengerChildItem item) {
    ActiveTripModel? targetTrip;

    try {
      targetTrip = widget.allActiveTrips.firstWhere((t) => t.tripId == item.tripId);
    } catch (_) {
      targetTrip = widget.trip;
    }

    final bool isSameTrip = _currentDisplayedTrip != null && _currentDisplayedTrip!.tripId == item.tripId;

    setState(() {
      _isAllSelected = false;
      _selectedChildId = item.childId;
      _currentDisplayedTrip = targetTrip;
    });

    if (!isSameTrip && targetTrip != null) {
      // Different trip -> reload map for new trip
      _trackingCubit.startTracking(targetTrip.tripId, activeTrip: targetTrip, childId: item.childId);
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
            'تتبع الرحلات المباشر',
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 17.sp,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          foregroundColor: isDark ? AppColors.white : AppColors.textDark,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _trackingCubit.refresh(),
            ),
          ],
        ),
        body: BlocProvider.value(
          value: _trackingCubit,
          child: BlocBuilder<TripTrackingCubit, TripTrackingState>(
            builder: (context, state) {
              bool isOffline = false;
              String? offlineMessage;

              if (state is TripTrackingSingleLoaded) {
                isOffline = state.isOffline;
                offlineMessage = state.offlineMessage;
                if (state.activeTrip != null) {
                  _currentDisplayedTrip = state.activeTrip;
                }
              }

              return Column(
                children: [
                  // 1. Messenger Stories Children Bar
                  if (childrenItems.isNotEmpty)
                    MessengerChildrenBar(
                      children: childrenItems,
                      isAllSelected: _isAllSelected,
                      selectedChildId: _selectedChildId,
                      onSelectAll: _onSelectAll,
                      onSelectChild: _onSelectChild,
                    ),

                  // 2. Offline Banner Warning (If Stale/Offline)
                  if (isOffline)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      color: AppColors.pending,
                      child: Row(
                        children: [
                          Icon(Icons.wifi_off_rounded, color: AppColors.white, size: 18.r),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              offlineMessage ?? 'آخر تحديث للموقع منذ فترة... جاري إعادة الاتصال',
                              style: AppTextStyles.style(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 3. Interactive Map Canvas
                  Expanded(
                    child: Stack(
                      children: [
                        TrackingMapWidget(
                          mapController: _mapController,
                          isMultiMode: _isAllSelected || state is TripTrackingMultiLoaded,
                          singleTrack: state is TripTrackingSingleLoaded ? state.trackData : null,
                          singleTrip: _currentDisplayedTrip,
                          multiTracks: state is TripTrackingMultiLoaded ? state.tracks : [],
                          multiTrips: widget.allActiveTrips,
                          onSelectTrip: (selectedTripId) {
                            try {
                              final tripObj = widget.allActiveTrips.firstWhere((t) => t.tripId == selectedTripId);
                              setState(() {
                                _isAllSelected = false;
                                _currentDisplayedTrip = tripObj;
                              });
                              _trackingCubit.startTracking(selectedTripId, activeTrip: tripObj);
                            } catch (_) {}
                          },
                        ),

                        // Loading overlay if initial load
                        if (state is TripTrackingLoading)
                          Positioned(
                            top: 20.h,
                            left: 20.w,
                            right: 20.w,
                            child: Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: context.cardSurface.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16.r,
                                    height: 16.r,
                                    child: const CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    'جاري التحديث البصري للموقع...',
                                    style: AppTextStyles.style(fontSize: 12.sp, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 4. Dynamic Bottom Sheet
                  if (_currentDisplayedTrip != null)
                    TrackingBottomSheet(
                      trip: _currentDisplayedTrip!,
                      onOpenDetails: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripDetailsScreen(tripId: _currentDisplayedTrip!.tripId),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
