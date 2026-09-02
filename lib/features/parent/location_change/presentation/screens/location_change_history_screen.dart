import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/di/dependency_injection.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';
import '../../data/models/location_change_request_model.dart';
import '../../logic/cubit/location_change_cubit.dart';

class LocationChangeHistoryScreen extends StatefulWidget {
  const LocationChangeHistoryScreen({super.key});

  @override
  State<LocationChangeHistoryScreen> createState() => _LocationChangeHistoryScreenState();
}

class _LocationChangeHistoryScreenState extends State<LocationChangeHistoryScreen> {
  late LocationChangeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<LocationChangeCubit>()..fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _cubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
          appBar: AppBar(
            elevation: 0,
            title: Text(
              'سجل طلبات تغيير الموقع 📋',
              style: AppTextStyles.style(
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
          ),
          body: BlocBuilder<LocationChangeCubit, LocationChangeState>(
            builder: (context, state) {
              if (state is LocationChangeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is LocationChangeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 60.sp, color: context.errorColor),
                      SizedBox(height: 12.h),
                      Text(
                        state.message,
                        style: AppTextStyles.style(fontSize: 14.sp, color: context.textMuted),
                      ),
                      SizedBox(height: 12.h),
                      ElevatedButton(
                        onPressed: () => _cubit.fetchHistory(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }

              if (state is LocationChangeHistoryLoaded) {
                final requests = state.requests;

                if (requests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off_rounded,
                          size: 70.sp,
                          color: isDark ? AppColors.grey700 : AppColors.grey400,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'لا توجد طلبات تغيير موقع سابقة',
                          style: AppTextStyles.style(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: context.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _cubit.fetchHistory(),
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: requests.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final item = requests[index];
                      return _buildRequestItemCard(context, item, isDark);
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRequestItemCard(
    BuildContext context,
    LocationChangeRequestModel item,
    bool isDark,
  ) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (item.status.toLowerCase()) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'مقبول وتم التحديث';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        statusColor = context.errorColor;
        statusText = 'مرفوض من السائق';
        statusIcon = Icons.cancel_rounded;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusText = 'معلق بانتظار موافقة السائق';
        statusIcon = Icons.hourglass_top_rounded;
        break;
    }

    final pointTypeText = item.pointType == 'pickup' ? 'مكان الاستلام' : 'مكان التوصيل';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
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
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    child: Icon(
                      Icons.child_care_rounded,
                      size: 20.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.childName ?? 'طفل',
                        style: AppTextStyles.style(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'السائق: ${item.driverName ?? ''}',
                        style: AppTextStyles.style(
                          fontSize: 11.5.sp,
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      statusText,
                      style: AppTextStyles.style(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التاريخ والتوع:',
                style: AppTextStyles.style(fontSize: 12.sp, color: context.textMuted),
              ),
              Text(
                '${item.changeDate} • $pointTypeText',
                style: AppTextStyles.style(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الموقع الجديد:',
                style: AppTextStyles.style(fontSize: 12.sp, color: context.textMuted),
              ),
              Text(
                item.newLocation?.label.isNotEmpty == true
                    ? item.newLocation!.label
                    : 'موقع محدد على الخريطة',
                style: AppTextStyles.style(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الزيادة والرسوم:',
                style: AppTextStyles.style(fontSize: 12.sp, color: context.textMuted),
              ),
              Text(
                '${item.distanceKm.toStringAsFixed(1)} كم • ${item.feeAmount} ${item.currency}',
                style: AppTextStyles.style(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          if (item.status.toLowerCase() == 'rejected' &&
              item.rejectionReason != null &&
              item.rejectionReason!.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: context.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: context.errorColor, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'سبب الرفض: ${item.rejectionReason}',
                      style: AppTextStyles.style(
                        fontSize: 11.5.sp,
                        color: context.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
