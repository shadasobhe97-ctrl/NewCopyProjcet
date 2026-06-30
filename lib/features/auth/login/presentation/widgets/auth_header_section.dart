import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/theme_context.dart';
import '../../../../../core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_colors.dart';

class AuthHeaderSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeaderSection({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text(
          title,
          style: AppTextStyles.heading(
            color: isDark ? AppColors.white : AppColors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Text(subtitle, style: AppTextStyles.body(color: context.textMuted)),
        SizedBox(height: 40.h),
      ],
    );
  }
}
