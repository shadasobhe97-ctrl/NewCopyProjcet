import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_user_avatar.dart';
import '../../data/models/active_trip_model.dart';
import '../../logic/trip_details_cubit/trip_details_cubit.dart';
import '../../logic/trip_details_cubit/trip_details_state.dart';
import '../widgets/driver_card.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/trip_status_chip.dart';
import 'child_details_in_trip_screen.dart';
import 'trip_timeline_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  final dynamic tripId;

  const TripDetailsScreen({
    super.key,
    required this.tripId,
  });

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  late final TripDetailsCubit _detailsCubit;

  @override
  void initState() {
    super.initState();
    _detailsCubit = getIt<TripDetailsCubit>();
    _detailsCubit.fetchTripDetails(widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'تفاصيل الرحلة',
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
              icon: Icon(Icons.more_vert_rounded, color: context.textPrimary),
              onPressed: () {},
            ),
          ],
        ),
        body: BlocProvider.value(
          value: _detailsCubit,
          child: BlocBuilder<TripDetailsCubit, TripDetailsState>(
            builder: (context, state) {
              if (state is TripDetailsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final trip = state is TripDetailsLoaded ? state.trip : null;
              if (trip == null) {
                return Center(
                  child: Text(
                    'تعذر تحميل تفاصيل الرحلة',
                    style: AppTextStyles.style(color: AppColors.textMuted),
                  ),
                );
              }

              // Transform TripDetailsModel into ActiveTripModel if needed for nested screens
              final activeTrip = ActiveTripModel(
                tripId: trip.tripId,
                tripType: trip.tripType,
                direction: trip.direction,
                status: trip.status,
                startedAt: trip.startedAt,
                driver: DriverInfo(
                  id: trip.driver.id,
                  name: trip.driver.name,
                  phone: trip.driver.phone,
                  photo: trip.driver.photo,
                ),
                vehicle: VehicleInfoModel(
                  info: trip.vehicle.info,
                  plateNumber: trip.vehicle.plateNumber,
                ),
                destination: DestinationInfo(
                  name: trip.destination.name,
                  type: trip.destination.type,
                  lat: trip.destination.lat,
                  lng: trip.destination.lng,
                ),
                children: trip.children
                    .map((c) => TripChildInfo(
                          childId: c.childId,
                          childName: c.childName,
                          childStatus: c.childStatus,
                          childPhoto: c.childPhoto,
                          pickupTime: c.pickupTime,
                        ))
                    .toList(),
              );

              return ListView(
                padding: EdgeInsets.all(16.r),
                children: [
                  // 1) TRIP HEADER CARD
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
                        Row(
                          children: [
                            Text(
                              'رحلة #${trip.tripId}',
                              style: AppTextStyles.style(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            TripStatusChip.fromStatusString(trip.status),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSummaryItem('نوع الرحلة', trip.tripType),
                            _buildSummaryItem(
                              'الاتجاه',
                              trip.direction == 'to_school' ? 'إلى المدرسة' : 'إلى المنزل',
                            ),
                            _buildSummaryItem('وقت الانطلاق', trip.startedAt),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // 2) DRIVER CARD
                  DriverCard(driver: activeTrip.driver),
                  SizedBox(height: 12.h),

                  // 3) VEHICLE CARD
                  VehicleCard(vehicle: activeTrip.vehicle),
                  SizedBox(height: 16.h),

                  // 4) CHILDREN IN THIS TRIP SECTION
                  Text(
                    'الأطفال في هذه الرحلة (${trip.children.length}):',
                    style: AppTextStyles.style(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ...trip.children.map((child) {
                    final childInfo = TripChildInfo(
                      childId: child.childId,
                      childName: child.childName,
                      childStatus: child.childStatus,
                      childPhoto: child.childPhoto,
                      pickupTime: child.pickupTime,
                    );

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChildDetailsInTripScreen(
                              trip: activeTrip,
                              child: childInfo,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.grey800 : AppColors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: isDark ? AppColors.grey700 : AppColors.grey200,
                          ),
                        ),
                        child: Row(
                          children: [
                            AppUserAvatar(
                              imageUrl: child.childPhoto,
                              radius: 18.r,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    child.childName,
                                    style: AppTextStyles.style(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    child.direction == 'to_school' ? 'إلى المدرسة' : 'إلى المنزل',
                                    style: AppTextStyles.style(
                                      fontSize: 10.sp,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TripStatusChip.fromStatusString(child.childStatus),
                            SizedBox(width: 4.w),
                            Icon(Icons.arrow_forward_ios_rounded, size: 12.r, color: AppColors.grey400),
                          ],
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 20.h),

                  // 5) BOTTOM BUTTONS (SHARE & TIMELINE)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46.h,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم نسخ رابط الرحلة للمشاركة')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.primaryColor,
                              side: BorderSide(color: context.primaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            icon: const Icon(Icons.share_outlined, size: 18),
                            label: Text(
                              'مشاركة الرحلة',
                              style: AppTextStyles.style(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: context.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: SizedBox(
                          height: 46.h,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TripTimelineScreen(
                                    tripTitle: 'رحلة #${trip.tripId}',
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
                            icon: const Icon(Icons.timeline_rounded, size: 20),
                            label: Text(
                              'الخط الزمني',
                              style: AppTextStyles.style(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.style(fontSize: 10.sp, color: AppColors.textMuted),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: AppTextStyles.style(fontSize: 12.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
