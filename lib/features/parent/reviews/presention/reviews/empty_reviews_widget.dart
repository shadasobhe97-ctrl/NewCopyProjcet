import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class EmptyReviewsWidget extends StatelessWidget {
  const EmptyReviewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 16.w),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            color: isDark ? AppColors.grey600 : AppColors.grey400,
            size: 40.r,
          ),
          SizedBox(height: 10.h),
          Text(
            'لا توجد تقييمات حتى الآن',
            style: AppTextStyles.style(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'كن أول من يشارك تجربته مع هذا الكابتن عند تفعيل اشتراكك.',
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 11.sp,
              color: isDark ? AppColors.grey500 : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
