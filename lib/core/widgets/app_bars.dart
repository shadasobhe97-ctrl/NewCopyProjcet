import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// AppBar موحّد يُستخدم عبر شاشات التطبيق.
/// يوفر زر الرجوع، عنوان مركزي، وخلفية من لون التطبيق الأساسي.
class AppPrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onBackPressed;

  const AppPrimaryAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.backgroundColor = AppColors.primaryLight,
    this.foregroundColor = AppColors.white,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: AppTextStyles.style(
          color: foregroundColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading:
          showBack
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: foregroundColor,
                  ),
                  onPressed:
                      onBackPressed ?? () => Navigator.of(context).pop(),
                )
              : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// قاع ثابت للأزرار (BottomActionBar).
/// يُستخدم لتثبيت زر الحفظ/الإرسال في أسفل الشاشات.
class BottomActionBar extends StatelessWidget {
  final Widget child;

  const BottomActionBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: AppTheme.verticalRadius(
          top: AppTheme.cornerRadius(20),
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
