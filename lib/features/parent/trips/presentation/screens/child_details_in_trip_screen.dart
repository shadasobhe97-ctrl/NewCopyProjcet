import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_user_avatar.dart';
import '../../data/models/active_trip_model.dart';
import '../widgets/driver_card.dart';
import 'trip_tracking_screen.dart';

class ChildDetailsInTripScreen extends StatelessWidget {
  final ActiveTripModel trip;
  final TripChildInfo child;

  const ChildDetailsInTripScreen({
    super.key,
    required this.trip,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            child.childName,
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
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: context.textPrimary,
              size: 18.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(16.r),
          children: [
            // 1) HEADER CARD
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: isDark ? context.cardSurface : AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? AppColors.grey800 : AppColors.grey200,
                ),
              ),
              child: Row(
                children: [
                  AppUserAvatar(
                    imageUrl: child.childPhoto,
                    radius: 24.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.childName,
                          style: AppTextStyles.style(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: context.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'في الطريق إلى ${trip.destination.name} • ${child.pickupTime ?? "07:35"} تم الصعود',
                          style: AppTextStyles.style(
                            fontSize: 11.sp,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // 2) MINI MAP PREVIEW
            Container(
              height: 160.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? AppColors.grey800 : AppColors.grey200,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(trip.destination.lat, trip.destination.lng),
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.kids_transport.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(trip.destination.lat, trip.destination.lng),
                          width: 80.w,
                          height: 50.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.school_rounded, size: 14.r, color: context.primaryColor),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    trip.destination.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),

            // 3) DRIVER CARD
            DriverCard(driver: trip.driver),
            SizedBox(height: 14.h),

            // 4) CHILD METRICS INFO CARD
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: isDark ? context.cardSurface : AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isDark ? AppColors.grey800 : AppColors.grey200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معلومات ${child.childName.split(" ")[0]}',
                    style: AppTextStyles.style(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoRow(context, Icons.home_work_rounded, 'الوجهة', trip.destination.name),
                  _buildInfoRow(
                    context,
                    Icons.category_rounded,
                    'نوع الوجهة',
                    trip.destination.type == 'home' ? 'منزل' : 'مدرسة',
                  ),
                  _buildInfoRow(context, Icons.alt_route_rounded, 'المسافة المتبقية', '2.4 كم'),
                  _buildInfoRow(context, Icons.access_time_rounded, 'الوقت المتبقي', '20 دقيقة'),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // 🌟 5) TRACK ON MAP BUTTON (RETURNS TO TRACKING DASHBOARD MAP / POP STEP BACK)
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripTrackingScreen(
                        trip: trip,
                        initialSelectedChildId: child.childId,
                      ),
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
                icon: const Icon(Icons.location_on_rounded, size: 20),
                label: Text(
                  'تتبع على الخريطة',
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
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Icon(icon, size: 16.r, color: context.primaryColor),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: AppTextStyles.style(
              fontSize: 12.sp,
              color: AppColors.textMuted,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.style(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
