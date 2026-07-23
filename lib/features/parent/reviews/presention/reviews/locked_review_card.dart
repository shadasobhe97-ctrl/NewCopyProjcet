import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class LockedReviewCard extends StatelessWidget {
  const LockedReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.pending.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.pending.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.pending.withValues(alpha: 0.15),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.pending,
              size: 26,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'تقييم السائق مغلق 🔒',
            style: AppTextStyles.style(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'يمكنك قراءة مراجعات أولياء الأمور الآخرين. لكنك تحتاج إلى اشتراك نشط وجارٍ مع هذا السائق لتتمكن من كتابة أو إضافة تقييم خاص بك.',
            textAlign: TextAlign.center,
            style: AppTextStyles.style(
              fontSize: 11.5.sp,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
