import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../data/models/emergency_dispatch_model.dart';
import '../../logic/driver_emergency_cubit/driver_emergency_cubit.dart';

class DriverEmergencyDispatchesScreen extends StatefulWidget {
  const DriverEmergencyDispatchesScreen({super.key});

  @override
  State<DriverEmergencyDispatchesScreen> createState() =>
      _DriverEmergencyDispatchesScreenState();
}

class _DriverEmergencyDispatchesScreenState
    extends State<DriverEmergencyDispatchesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DriverEmergencyCubit>().loadAvailableDispatches();
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
            'المهام الطارئة (بديل الحافلة)',
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
                // الانتقال المباشر للرحلة النشطة الجديدة بالسائق البديل
                Navigator.pushNamed(
                  context,
                  AppRoutes.driverLiveTrip,
                  arguments: state.substituteTripId,
                );
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
            final isLoading = state is DriverEmergencyLoading;
            final dispatches = state is DriverEmergencyLoaded
                ? state.dispatches
                : <EmergencyDispatchModel>[];

            return Column(
              children: [
                _buildHeaderNotice(context),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : dispatches.isEmpty
                          ? _buildEmptyState(context)
                          : RefreshIndicator(
                              onRefresh: () async {
                                await context
                                    .read<DriverEmergencyCubit>()
                                    .loadAvailableDispatches();
                              },
                              child: ListView.separated(
                                padding: EdgeInsets.all(16.r),
                                itemCount: dispatches.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 14.h),
                                itemBuilder: (context, index) {
                                  final dispatch = dispatches[index];
                                  return _buildDispatchCard(context, dispatch);
                                },
                              ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderNotice(BuildContext context) {
    return Container(
      color: AppColors.warning.withValues(alpha: 0.12),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 22.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'تظهر هنا بلاغات الطوارئ العاجلة للحافلات المتعطلة بالقرب من نطاقك الجغرافي لنقل الطلاب المتبقين.',
              style: AppTextStyles.style(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_rounded,
              size: 64.r,
              color: AppColors.success,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد بلاغات طوارئ حالياً',
              style: AppTextStyles.style(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'جميع حافلات السائقين تعمل بشكل طبيعي، وستتلقى إشعاراً فورياً عند حدوث أي عطل طارئ.',
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 12.sp,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDispatchCard(
      BuildContext context, EmergencyDispatchModel dispatch) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const warningColor = AppColors.warning;

    return Container(
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: warningColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: warningColor.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Header with original driver info & urgency badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: warningColor.withValues(alpha: 0.15),
                    child: Icon(
                      Icons.directions_bus_filled_rounded,
                      color: warningColor,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dispatch.originalDriver?.name ?? 'سائق متعطل',
                        style: AppTextStyles.style(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      if (dispatch.originalDriver?.phone != null)
                        Text(
                          'هاتف: ${dispatch.originalDriver!.phone}',
                          style: AppTextStyles.style(
                            fontSize: 11.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: warningColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bolt_rounded,
                        size: 14.r, color: warningColor),
                    SizedBox(width: 4.w),
                    Text(
                      'طلب طارئ',
                      style: AppTextStyles.style(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: warningColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          const Divider(height: 1),
          SizedBox(height: 12.h),

          // Details Grid
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey900 : AppColors.grey50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  icon: Icons.people_outline_rounded,
                  label: 'عدد الطلاب المنتظرين:',
                  value: '${dispatch.strandedChildrenCount} طالب',
                  valueColor: warningColor,
                  isBold: true,
                ),
                SizedBox(height: 6.h),
                _buildInfoRow(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'أجر المهمة المحول للمحفظة:',
                  value:
                      '${dispatch.tripFareAmount.toStringAsFixed(2)} د.ل',
                  valueColor: AppColors.success,
                  isBold: true,
                ),
                SizedBox(height: 6.h),
                _buildInfoRow(
                  context,
                  icon: Icons.location_on_outlined,
                  label: 'موقع الحافلة المتعطلة:',
                  value:
                      '${dispatch.breakdownLat.toStringAsFixed(4)}, ${dispatch.breakdownLng.toStringAsFixed(4)}',
                ),
                if (dispatch.expiresAt != null) ...[
                  SizedBox(height: 6.h),
                  _buildInfoRow(
                    context,
                    icon: Icons.timer_outlined,
                    label: 'تنتهي المهلة في:',
                    value: dispatch.expiresAt!.contains('T')
                        ? dispatch.expiresAt!.split('T').last.substring(0, 5)
                        : dispatch.expiresAt!,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // Action Buttons: Details, Accept, Reject
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _confirmAccept(context, dispatch.id),
                  icon: Icon(Icons.check_circle_rounded,
                      size: 18.r, color: AppColors.white),
                  label: Text(
                    'قبول المهمة',
                    style: AppTextStyles.style(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.driverEmergencyDispatchDetails,
                    arguments: dispatch.id,
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  'التفاصيل',
                  style: AppTextStyles.style(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: context.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: () => _confirmReject(context, dispatch.id),
                icon: Icon(Icons.close_rounded,
                    size: 20.r, color: AppColors.error),
                tooltip: 'استبعاد الطلب',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15.r, color: context.primaryColor),
        SizedBox(width: 6.w),
        Text(
          label,
          style: AppTextStyles.style(
            fontSize: 11.sp,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: AppTextStyles.style(
              fontSize: 11.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? context.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmAccept(BuildContext context, int dispatchId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد قبول المهمة الطارئة'),
        content: const Text(
          'عند قبول المهمة الطارئة، ستُعيّن كسائق بديل لنقل الطلاب المتبقين وسيحول أجر الرحلة بالكامل إلى محفظتك المالية فور إكمالها.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DriverEmergencyCubit>().acceptDispatch(dispatchId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('قبول وإنقاذ الطلاب'),
          ),
        ],
      ),
    );
  }

  void _confirmReject(BuildContext context, int dispatchId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('استبعاد المهمة الطارئة'),
        content: const Text(
          'هل أنت متأكد من استبعاد هذه المهمة الطارئة من قائمتك؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DriverEmergencyCubit>().rejectDispatch(dispatchId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('استبعاد'),
          ),
        ],
      ),
    );
  }
}
