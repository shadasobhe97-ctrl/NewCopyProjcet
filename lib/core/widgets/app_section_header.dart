import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// ويدجت موحدة لعناوين الفواصل بين الأقسام باللون الرصاصي مع خط فك وسطي أنيق.
class AppSectionHeader extends StatelessWidget {
  final String title;
  final Widget? actionWidget;
  final IconData? icon;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionWidget,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.grey300 : AppColors.grey700;
    final lineColor = isDark ? AppColors.grey800 : AppColors.grey300;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18.r, color: textColor),
            SizedBox(width: 8.w),
          ],
          Text(
            title,
            style: AppTextStyles.style(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              height: 1,
              color: lineColor,
            ),
          ),
          if (actionWidget != null) ...[
            SizedBox(width: 8.w),
            actionWidget!,
          ],
        ],
      ),
    );
  }
}
