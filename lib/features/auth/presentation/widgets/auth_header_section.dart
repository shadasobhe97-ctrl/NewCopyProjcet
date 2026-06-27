import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text(
          title,
          style: AppTextStyles.heading(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        Text(subtitle, style: AppTextStyles.body(color: AppColors.textMuted)),
        SizedBox(height: 40.h),
      ],
    );
  }
}
