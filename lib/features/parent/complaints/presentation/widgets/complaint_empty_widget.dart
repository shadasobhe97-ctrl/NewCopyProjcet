import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class ComplaintEmptyWidget extends StatelessWidget {
  final String title;
  final String message;

  const ComplaintEmptyWidget({
    super.key,
    this.title = 'لا توجد شكاوى حتى الآن',
    this.message = 'لم تقم بتقديم أي شكاوى تحت تصنيف هذا التبويب.',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey800.withValues(alpha: 0.5) : AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.report_off_outlined,
              color: isDark ? AppColors.grey500 : AppColors.grey400,
              size: 48.r,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            title,
            style: AppTextStyles.style(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.grey300 : AppColors.textDark,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 11.5.sp,
              color: isDark ? AppColors.grey500 : AppColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
