import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../data/models/active_trip_model.dart';
import '../../logic/trip_tracking_cubit/trip_tracking_cubit.dart';
import '../../logic/trip_tracking_cubit/trip_tracking_state.dart';

class TripTrackingScreen extends StatefulWidget {
  final ActiveTripModel trip;

  const TripTrackingScreen({super.key, required this.trip});

  @override
  State<TripTrackingScreen> createState() => _TripTrackingScreenState();
}

class _TripTrackingScreenState extends State<TripTrackingScreen> {
  late final TripTrackingCubit _trackingCubit;
  late final MapController _mapController;
  bool _followDriver = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _trackingCubit = getIt<TripTrackingCubit>()..startTracking(widget.trip.tripId);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _centerOnDriver(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), _mapController.camera.zoom);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'تتبع رحلة ${widget.trip.childName}',
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
        body: BlocProvider.value(
          value: _trackingCubit,
          child: BlocBuilder<TripTrackingCubit, TripTrackingState>(
            builder: (context, state) {
              LatLng driverPos = const LatLng(32.8872, 13.1913); // Default location (Tripoli)
              String lastUpdate = 'جاري الاتصال...';

              if (state is TripTrackingLoaded) {
                driverPos = LatLng(state.trackData.driverLat, state.trackData.driverLng);
                lastUpdate = 'آخر تحديث: ${state.trackData.lastUpdated}';

                if (_followDriver) {
                  // Auto-move map center to driver coordinates
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _centerOnDriver(driverPos.latitude, driverPos.longitude);
                    }
                  });
                }
              }

              return Stack(
                children: [
                  // ─── الخريطة التفاعلية ───
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: driverPos,
                      initialZoom: 15.0,
                      onPositionChanged: (position, hasGesture) {
                        if (hasGesture) {
                          // Stop auto-following if parent drags map manually
                          setState(() {
                            _followDriver = false;
                          });
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'ly.derbi.kids_transport',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: driverPos,
                            width: 60.r,
                            height: 60.r,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Halo animation ring
                                Container(
                                  width: 48.r,
                                  height: 48.r,
                                  decoration: BoxDecoration(
                                    color: context.primaryColor.withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 20.r,
                                  backgroundColor: context.primaryColor,
                                  child: const Icon(
                                    Icons.directions_bus_rounded,
                                    color: AppColors.white,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // ─── شارة آخر تحديث العائمة ───
                  Positioned(
                    top: 16.h,
                    left: 16.w,
                    right: 16.w,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.white,
                          borderRadius: BorderRadius.circular(30.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
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
                            SizedBox(width: 8.w),
                            Text(
                              lastUpdate,
                              style: AppTextStyles.style(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.white : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ─── أزرار التحكم الجانبية العائمة ───
                  Positioned(
                    left: 16.w,
                    bottom: 230.h,
                    child: Column(
                      children: [
                        _buildFloatingButton(
                          icon: Icons.add_rounded,
                          onPressed: () {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom + 1,
                            );
                          },
                          isDark: isDark,
                        ),
                        SizedBox(height: 8.h),
                        _buildFloatingButton(
                          icon: Icons.remove_rounded,
                          onPressed: () {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom - 1,
                            );
                          },
                          isDark: isDark,
                        ),
                        SizedBox(height: 8.h),
                        _buildFloatingButton(
                          icon: _followDriver ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                          color: _followDriver ? context.primaryColor : null,
                          onPressed: () {
                            setState(() {
                              _followDriver = true;
                            });
                            _centerOnDriver(driverPos.latitude, driverPos.longitude);
                          },
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  // ─── اللوحة السفلية (Bottom Card) ───
                  Positioned(
                    bottom: 16.h,
                    left: 16.w,
                    right: 16.w,
                    child: _buildBottomPanel(context, isDark),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
    Color? color,
  }) {
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? (isDark ? AppColors.white : AppColors.textDark), size: 20.r),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شارة حالة الطفل
          Row(
            children: [
              Container(
                width: 10.r,
                height: 10.r,
                decoration: const BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  widget.trip.childStatus,
                  style: AppTextStyles.style(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
              ),
              Text(
                'البداية: ${widget.trip.startedAt.split('T').first}',
                style: AppTextStyles.style(
                  fontSize: 11.sp,
                  color: isDark ? AppColors.grey400 : AppColors.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          const Divider(height: 1),
          SizedBox(height: 14.h),

          // تفاصيل الطفل والسائق
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                child: Icon(Icons.child_care_rounded, color: context.primaryColor, size: 20.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.trip.childName,
                      style: AppTextStyles.style(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'الكابتن: ${widget.trip.driverName} • ${widget.trip.vehicleInfo}',
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
          SizedBox(height: 16.h),

          // زر الاتصال
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                elevation: 0,
              ),
              icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.white),
              label: Text(
                'اتصل بالسائق 📞',
                style: AppTextStyles.style(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              onPressed: () => _callDriver(widget.trip.driverPhone),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callDriver(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
