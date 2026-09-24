import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../data/models/article_model.dart';

class ArticleCardWidget extends StatefulWidget {
  final ArticleModel article;
  final int index;

  const ArticleCardWidget({
    super.key,
    required this.article,
    required this.index,
  });

  @override
  State<ArticleCardWidget> createState() => _ArticleCardWidgetState();
}

class _ArticleCardWidgetState extends State<ArticleCardWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final articleNum = widget.article.articleNumber > 0
        ? widget.article.articleNumber
        : widget.index + 1;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppTheme.radius(16.r),
        border: AppTheme.border(
          color: isDark
              ? AppColors.grey800
              : context.primaryColor.withValues(alpha: 0.12),
          width: 1.2.w,
        ),
        boxShadow: [
          AppTheme.boxShadow(
            color: context.primaryColor.withValues(alpha: isDark ? 0.05 : 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppTheme.radius(16.r),
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: AppTheme.radius(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // رقم المادة / البند
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: AppTheme.boxDecoration(
                        color: context.primaryColor.withValues(alpha: 0.12),
                        borderRadius: AppTheme.radius(10.r),
                      ),
                      child: Text(
                        'المادة $articleNum',
                        style: AppTextStyles.style(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    // عنوان المادة
                    Expanded(
                      child: Text(
                        widget.article.title,
                        style: AppTextStyles.style(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: context.textMuted,
                      size: 22.r,
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  SizedBox(height: 12.h),
                  Divider(
                    height: 1,
                    thickness: 1.w,
                    color: isDark
                        ? AppColors.grey800
                        : AppColors.grey200.withValues(alpha: 0.6),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    widget.article.body,
                    style: AppTextStyles.style(
                      fontSize: 13.sp,
                      height: 1.6,
                      color: context.textPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
