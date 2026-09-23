import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../logic/driver_emergency_cubit/driver_emergency_cubit.dart';

class EmergencyDispatchDetailsScreen extends StatefulWidget {
  final int dispatchId;

  const EmergencyDispatchDetailsScreen({
    super.key,
    required this.dispatchId,
  });

  @override
  State<EmergencyDispatchDetailsScreen> createState() =>
      _EmergencyDispatchDetailsScreenState();
}

class _EmergencyDispatchDetailsScreenState
    extends State<EmergencyDispatchDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<DriverEmergencyCubit>()
        .loadDispatchDetails(widget.dispatchId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(
          backgroundColor: context.cardSurface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: context.primaryColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'تفاصيل المهمة الطارئة',
            style: AppTextStyles.style(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: context.primaryColor,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<DriverEmergencyCubit, DriverEmergencyState>(
          listener: (context, state) {
            if (state is DriverEmergencyActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              if (state.substituteTripId != null) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.driverLiveTrip,
                  (route) => route.isFirst,
                  arguments: state.substituteTripId,
                );
              } else {
                Navigator.pop(context);
              }
            } else if (state is DriverEmergencyError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is DriverEmergencyLoading ||
                state is DriverEmergencyActionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DriverEmergencyError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 48.r, color: AppColors.error),
                      SizedBox(height: 12.h),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.style(color: AppColors.error),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<DriverEmergencyCubit>()
                              .loadDispatchDetails(widget.dispatchId);
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is DriverEmergencyDetailsLoaded) {
              final dispatch = state.dispatch;
              final trip = dispatch.trip;
              final originalDriver = dispatch.originalDriver;
              final stops = trip?.stops ?? [];

              return SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1: Emergency Summary & Fare
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: context.cardSurface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'تفاصيل الأجر المالي والرحلة',
                                style: AppTextStyles.style(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimary,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: AppColors.success
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  '${dispatch.tripFareAmount.toStringAsFixed(2)} د.ل',
                                  style: AppTextStyles.style(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'السائق المتعطل: ${originalDriver?.name ?? "غير متوفر"}',
                            style: AppTextStyles.style(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          if (originalDriver?.phone != null &&
                              originalDriver!.phone.isNotEmpty)
                            Text(
                              'رقم التواصل: ${originalDriver.phone}',
                              style: AppTextStyles.style(
                                fontSize: 12.sp,
                                color: AppColors.textMuted,
                              ),
                            ),
                          if (dispatch.reason != null &&
                              dispatch.reason!.isNotEmpty) ...[
                            SizedBox(height: 8.h),
                            Text(
                              'سبب التعطل: ${dispatch.reason}',
                              style: AppTextStyles.style(
                                fontSize: 12.sp,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Card 2: Remaining Stops & Stranded Children
                    Text(
                      'المحطات المتبقية والطلاب (${dispatch.strandedChildrenCount} طالب):',
                      style: AppTextStyles.style(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    if (stops.isEmpty)
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: context.cardSurface,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: const Text('لا توجد تفاصيل محطات متبقية متاحة.'),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: stops.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final stop = stops[index];
                          final child = stop.child;
                          final stopName = (child?.fullName.isNotEmpty == true)
                              ? child!.fullName
                              : (stop.label.isNotEmpty ? stop.label : 'محطة توقف');

                          return Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: context.cardSurface,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.grey200,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16.r,
                                  backgroundColor: context.primaryColor
                                      .withValues(alpha: 0.1),
                                  child: Text(
                                    '${stop.sequenceOrder}',
                                    style: AppTextStyles.style(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: context.primaryColor,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stopName,
                                        style: AppTextStyles.style(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                          color: context.textPrimary,
                                        ),
                                      ),
                                      if (child?.schoolName != null &&
                                          child!.schoolName!.isNotEmpty)
                                        Text(
                                          'المدرسة: ${child.schoolName}',
                                          style: AppTextStyles.style(
                                            fontSize: 11.sp,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    SizedBox(height: 24.h),

                    // Action Buttons: Accept & Reject
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context
                                  .read<DriverEmergencyCubit>()
                                  .acceptDispatch(dispatch.id);
                            },
                            icon: Icon(Icons.check_circle_rounded,
                                color: AppColors.white, size: 20.r),
                            label: Text(
                              'قبول وتعييني كسائق بديل',
                              style: AppTextStyles.style(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
