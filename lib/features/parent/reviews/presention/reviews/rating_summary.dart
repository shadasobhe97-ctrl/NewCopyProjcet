import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'rating_stars.dart';

class RatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;

  const RatingSummary({
    super.key,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          // Left side: average rating large text
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: AppTextStyles.style(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.white : AppColors.textDark,
                ),
              ),
              RatingStars(rating: averageRating, itemSize: 16.r),
              SizedBox(height: 4.h),
              Text(
                'من 5 نجوم',
                style: AppTextStyles.style(
                  fontSize: 10.sp,
                  color: isDark ? AppColors.grey400 : AppColors.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(width: 24.w),
          Container(
            height: 60.h,
            width: 1.w,
            color: isDark ? AppColors.grey800 : AppColors.grey200,
          ),
          SizedBox(width: 24.w),
          // Right side: reviews count and status text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إجمالي التقييمات',
                  style: AppTextStyles.style(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$totalReviews تقييم ومراجعة من أولياء الأمور',
                  style: AppTextStyles.style(
                    fontSize: 11.sp,
                    color: isDark ? AppColors.grey400 : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
