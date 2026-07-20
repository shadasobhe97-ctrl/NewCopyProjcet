import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../logic/requests_cubit/requests_cubit.dart';
import '../../data/models/request_model.dart';

class RequestDetailsScreen extends StatelessWidget {
  final RequestModel request;

  const RequestDetailsScreen({super.key, required this.request});

  String _typeLabel() {
    switch (request.subscriptionType.toLowerCase()) {
      case 'weekly':
        return 'أسبوعي';
      case 'daily':
        return 'يومي';
      case 'monthly':
      default:
        return 'شهري';
    }
  }

  String _directionLabel() {
    switch (request.direction.toLowerCase()) {
      case 'go':
      case 'to_school':
      case 'morning':
        return 'ذهاب فقط';
      case 'return':
      case 'from_school':
      case 'evening':
        return 'عودة فقط';
      case 'both':
      default:
        return 'ذهاب وعودة';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPending = request.status.toLowerCase() == 'pending';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'تفاصيل الطلب',
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
        body: BlocConsumer<RequestsCubit, RequestsState>(
          listener: (context, state) {
            if (state is RequestsActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      state.message,
                      style: AppTextStyles.style(
                          color: AppColors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16.w),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              );
              Navigator.of(context).pop();
            } else if (state is RequestsActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      state.message,
                      style: AppTextStyles.style(
                          color: AppColors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.all(16.w),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              );
            }
          },
          builder: (context, state) {
            final isCancelling = state is RequestsActionLoading &&
                state.actionId == request.id;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDriverCard(theme, isDark),
                        SizedBox(height: 16.h),
                        _buildRequestCard(theme, isDark),
                        SizedBox(height: 16.h),
                        _buildChildrenCard(theme, isDark),
                        if (request.rejectionReason != null &&
                            request.rejectionReason!.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          _buildRejectionCard(isDark),
                        ],
                      ],
                    ),
                  ),
                ),
                if (isPending)
                  _buildCancelButton(context, isDark, isCancelling),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDriverCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(Icons.person_rounded,
                color: theme.colorScheme.primary, size: 24.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.driver.name,
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  request.school.name,
                  style: AppTextStyles.style(
                    fontSize: 12.sp,
                    color: isDark ? AppColors.grey400 : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (request.driver.phone != null)
            IconButton(
              icon: Icon(Icons.phone_in_talk_rounded,
                  color: theme.colorScheme.primary),
              onPressed: () {},
            ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined,
                  color: theme.colorScheme.primary, size: 18.r),
              SizedBox(width: 8.w),
              Text(
                'تفاصيل الطلب',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _detailRow('القيمة الإجمالية',
              request.formattedPrice, isDark,
              valueColor: theme.colorScheme.primary, isBoldValue: true),
          _divider(isDark),
          _detailRow('تاريخ الطلب', _formatDate(request.createdAt), isDark),
          _divider(isDark),
          _detailRow('نوع الاشتراك', _typeLabel(), isDark),
          _divider(isDark),
          _detailRow('اتجاه الرحلة', _directionLabel(), isDark),
          _divider(isDark),
          _detailRow('التوقيت', request.timing, isDark),
          _divider(isDark),
          _detailRow(
              'فترة الاشتراك',
              request.endDate != null
                  ? 'من ${request.startDate} إلى ${request.endDate}'
                  : 'من ${request.startDate}',
              isDark),
          _divider(isDark),
          _detailRow('عدد الأطفال',
              '${request.childrenCount} أطفال', isDark),
          _divider(isDark),
          _detailRow('حالة الطلب',
              request.statusDisplayLabel, isDark,
              valueColor: _statusColor(), isBoldValue: true),
        ],
      ),
    );
  }

  Widget _buildChildrenCard(ThemeData theme, bool isDark) {
    if (request.children.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: isDark ? AppColors.grey800 : AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_alt_outlined,
                  color: theme.colorScheme.primary, size: 18.r),
              SizedBox(width: 8.w),
              Text(
                'الأطفال المشمولون بالطلب',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...request.children.map((child) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16.r,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.08),
                      child: Icon(Icons.child_care_outlined,
                          color: theme.colorScheme.primary, size: 16.r),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        child.name,
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                          color: isDark ? AppColors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                    if (child.schoolName != null)
                      Text(
                        child.schoolName!,
                        style: AppTextStyles.style(
                          fontSize: 11.sp,
                          color: isDark ? AppColors.grey400 : AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRejectionCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سبب الرفض:',
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: AppColors.error,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  request.rejectionReason!,
                  style: AppTextStyles.style(
                    fontSize: 13.sp,
                    color: AppColors.error,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, bool isDark, bool isCancelling) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        border: Border(
            top: BorderSide(
                color: isDark ? AppColors.grey800 : AppColors.grey200,
                width: 0.5.w)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10.r,
            offset: Offset(0, -4.h),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton.icon(
          onPressed:
              isCancelling ? null : () => _showCancelDialog(context),
          icon: isCancelling
              ? SizedBox(
                  width: 18.w,
                  height: 18.h,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5.w, color: AppColors.white),
                )
              : Icon(Icons.delete_outline_rounded,
                  size: 18.r, color: AppColors.white),
          label: Text(
            'إلغاء الطلب',
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              color: AppColors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r)),
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r)),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          title: Text(
            'تأكيد إلغاء الطلب',
            style: AppTextStyles.style(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: isDark ? AppColors.white : AppColors.textDark),
          ),
          content: Text(
            'هل أنت متأكد من إلغاء طلب الاشتراك هذا؟',
            style: AppTextStyles.style(
                fontSize: 13.sp,
                color: isDark ? AppColors.grey300 : AppColors.textMuted,
                height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'تراجع',
                style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.grey400 : AppColors.textMuted),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<RequestsCubit>().cancelRequest(request.id);
              },
              child: Text(
                'نعم، إلغاء',
                style: AppTextStyles.style(
                    fontWeight: FontWeight.bold, color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isDark,
      {Color? valueColor, bool isBoldValue = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.style(
              fontSize: 12.sp,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.style(
              fontSize: 13.sp,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w600,
              color: valueColor ??
                  (isDark ? AppColors.white : AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
        color: isDark ? AppColors.grey800 : AppColors.grey100, height: 16);
  }

  Color _statusColor() {
    switch (request.status.toLowerCase()) {
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
        return AppColors.pending;
      case 'cancelled':
        return AppColors.grey500;
      default:
        return AppColors.grey500;
    }
  }

  String _formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return rawDate.split('T').first;
    }
  }
}
