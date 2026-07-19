import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../data/models/request_model.dart';

class RequestCard extends StatelessWidget {
  final RequestModel request;
  final bool isCancelling;
  final VoidCallback? onDetailsPressed;
  final VoidCallback? onCancelPressed;

  const RequestCard({
    super.key,
    required this.request,
    this.isCancelling = false,
    this.onDetailsPressed,
    this.onCancelPressed,
  });

  Color _statusColor(BuildContext context) {
    switch (request.status.toLowerCase()) {
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'cancelled':
        return AppColors.grey500;
      default: // pending
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _statusIcon() {
    switch (request.status.toLowerCase()) {
      case 'accepted':
        return Icons.check_circle_outline_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'cancelled':
        return Icons.block_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _statusColor(context);
    final isPending = request.status.toLowerCase() == 'pending';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          right: BorderSide(color: statusColor, width: 3.5.w),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصف العلوي: اسم الطالب + حالة الطلب
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.studentName.isNotEmpty
                        ? request.studentName
                        : 'طالب',
                    style: AppTextStyles.style(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                // Badge الحالة
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _statusIcon(),
                        color: statusColor,
                        size: 13.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        request.statusDisplayLabel,
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

            SizedBox(height: 10.h),

            // نوع الطلب
            if (request.requestType.isNotEmpty)
              _infoRow(
                Icons.assignment_outlined,
                'نوع الطلب',
                request.requestType,
                isDark,
              ),

            // تاريخ الإنشاء
            if (request.createdAt.isNotEmpty)
              _infoRow(
                Icons.calendar_today_outlined,
                'تاريخ الطلب',
                _formatDate(request.createdAt),
                isDark,
              ),

            // سبب الرفض
            if (request.rejectionReason != null &&
                request.rejectionReason!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.error,
                      size: 14.r,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'سبب الرفض: ${request.rejectionReason}',
                        style: AppTextStyles.style(
                          fontSize: 12.sp,
                          color: AppColors.error,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 12.h),

            // أزرار الإجراءات
            Row(
              children: [
                // زر التفاصيل
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDetailsPressed,
                    icon: Icon(Icons.visibility_outlined, size: 15.r),
                    label: Text(
                      'التفاصيل',
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 9.h),
                    ),
                  ),
                ),

                // زر الإلغاء (فقط للطلبات المعلقة)
                if (isPending && onCancelPressed != null) ...[
                  SizedBox(width: 8.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isCancelling ? null : onCancelPressed,
                      icon: isCancelling
                          ? SizedBox(
                              width: 13.r,
                              height: 13.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Icon(Icons.close_rounded, size: 15.r),
                      label: Text(
                        'إلغاء',
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                          color: AppColors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 9.h),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14.r,
            color: isDark ? AppColors.grey400 : AppColors.grey500,
          ),
          SizedBox(width: 6.w),
          Text(
            '$label: ',
            style: AppTextStyles.style(
              fontSize: 12.sp,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.style(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.grey200 : AppColors.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
