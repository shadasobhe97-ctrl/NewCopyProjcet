import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../data/models/driver_statistics_model.dart';

class DocumentsStatusCard extends StatelessWidget {
  final DocumentsStatusModel documentsStatus;

  const DocumentsStatusCard({
    super.key,
    required this.documentsStatus,
  });

  Color _indicatorColor(String indicator) {
    switch (indicator.toLowerCase()) {
      case 'green':
        return AppColors.success;
      case 'yellow':
      case 'warning':
        return AppColors.warning;
      case 'red':
      case 'error':
        return AppColors.error;
      default:
        return AppColors.success;
    }
  }

  IconData _indicatorIcon(String indicator) {
    switch (indicator.toLowerCase()) {
      case 'green':
        return Icons.verified_user_rounded;
      case 'yellow':
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'red':
      case 'error':
        return Icons.gpp_maybe_rounded;
      default:
        return Icons.verified_user_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final overallColor = _indicatorColor(documentsStatus.overallIndicator);
    final overallIcon = _indicatorIcon(documentsStatus.overallIndicator);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder_shared_rounded,
                color: theme.colorScheme.primary,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'حالة الوثائق الرسمية',
                style: AppTextStyles.style(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // شريط المؤشر العام
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: overallColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: overallColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(overallIcon, color: overallColor, size: 20.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    documentsStatus.overallStatusLabel,
                    style: AppTextStyles.style(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: overallColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // وثيقة رخصة القيادة
          if (documentsStatus.license != null)
            _documentRow(documentsStatus.license!, isDark),

          if (documentsStatus.license != null && documentsStatus.insurance != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Divider(color: isDark ? AppColors.grey800 : AppColors.grey200, height: 1),
            ),

          // وثيقة التأمين
          if (documentsStatus.insurance != null)
            _documentRow(documentsStatus.insurance!, isDark),
        ],
      ),
    );
  }

  Widget _documentRow(DocumentItemModel doc, bool isDark) {
    final docColor = _indicatorColor(doc.indicator);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: docColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            doc.isExpired ? Icons.error_outline_rounded : Icons.description_outlined,
            color: docColor,
            size: 18.r,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc.label,
                style: AppTextStyles.style(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
              if (doc.licenseNumber != null && doc.licenseNumber!.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  'رقم الوثيقة: ${doc.licenseNumber}',
                  style: AppTextStyles.style(
                    fontSize: 10.sp,
                    color: isDark ? AppColors.grey400 : AppColors.textMuted,
                  ),
                ),
              ],
              SizedBox(height: 2.h),
              Text(
                'تنتهي في: ${doc.expiryDate} (${doc.daysRemaining} يوم متبقي)',
                style: AppTextStyles.style(
                  fontSize: 10.sp,
                  color: isDark ? AppColors.grey400 : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: docColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            doc.statusLabel,
            style: AppTextStyles.style(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: docColor,
            ),
          ),
        ),
      ],
    );
  }
}
