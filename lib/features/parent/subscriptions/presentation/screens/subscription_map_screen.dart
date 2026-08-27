import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../data/models/subscription_location_model.dart';

class SubscriptionMapScreen extends StatefulWidget {
  final String title;
  final SubscriptionLocationModel? pickupLocation;
  final SubscriptionLocationModel? dropoffLocation;

  const SubscriptionMapScreen({
    super.key,
    required this.title,
    this.pickupLocation,
    this.dropoffLocation,
  });

  @override
  State<SubscriptionMapScreen> createState() => _SubscriptionMapScreenState();
}

class _SubscriptionMapScreenState extends State<SubscriptionMapScreen> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPickup = widget.pickupLocation?.hasValidCoordinates == true;
    final hasDropoff = widget.dropoffLocation?.hasValidCoordinates == true;
    final hasAnyLocation = hasPickup || hasDropoff;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: AppTextStyles.style(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: !hasAnyLocation
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off_rounded,
                      size: 64.sp,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'الموقع غير متوفر',
                      style: AppTextStyles.style(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'لا تتوفر إحداثيات دقيقة لهذا الموقع للعرض على الخريطة.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.style(
                        fontSize: 13.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _getInitialCenter(hasPickup, hasDropoff),
                    initialZoom: (hasPickup && hasDropoff) ? 12.0 : 14.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.kids_transport.app',
                    ),
                    MarkerLayer(
                      markers: [
                        if (hasPickup)
                          Marker(
                            point: LatLng(
                              widget.pickupLocation!.latitude!,
                              widget.pickupLocation!.longitude!,
                            ),
                            width: 50.w,
                            height: 50.h,
                            child: Column(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.green.shade700,
                                  size: 36.sp,
                                ),
                              ],
                            ),
                          ),
                        if (hasDropoff)
                          Marker(
                            point: LatLng(
                              widget.dropoffLocation!.latitude!,
                              widget.dropoffLocation!.longitude!,
                            ),
                            width: 50.w,
                            height: 50.h,
                            child: Column(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.red.shade700,
                                  size: 36.sp,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                // ── بطاقة العناوين العائمة ──
                Positioned(
                  bottom: 20.h,
                  left: 16.w,
                  right: 16.w,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasPickup) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Colors.green.shade700,
                                  size: 12.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'نقطة الانطلاق:',
                                  style: AppTextStyles.style(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              widget.pickupLocation?.displayName ?? 'نقطة الانطلاق',
                              style: AppTextStyles.style(
                                fontSize: 12.sp,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                          if (hasPickup && hasDropoff) Divider(height: 16.h),
                          if (hasDropoff) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Colors.red.shade700,
                                  size: 12.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'نقطة الوصول:',
                                  style: AppTextStyles.style(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              widget.dropoffLocation?.displayName ?? 'المدرسة',
                              style: AppTextStyles.style(
                                fontSize: 12.sp,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  LatLng _getInitialCenter(bool hasPickup, bool hasDropoff) {
    if (hasPickup && hasDropoff) {
      final lat = (widget.pickupLocation!.latitude! +
              widget.dropoffLocation!.latitude!) /
          2;
      final lng = (widget.pickupLocation!.longitude! +
              widget.dropoffLocation!.longitude!) /
          2;
      return LatLng(lat, lng);
    } else if (hasPickup) {
      return LatLng(
        widget.pickupLocation!.latitude!,
        widget.pickupLocation!.longitude!,
      );
    } else if (hasDropoff) {
      return LatLng(
        widget.dropoffLocation!.latitude!,
        widget.dropoffLocation!.longitude!,
      );
    }
    return const LatLng(32.8872, 13.1913); // fallback Tripoli center
  }
}
