import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// بطاقة معلومات مع عنوان وأيقونة وخط فاصل —
/// تُستخدم في شاشة تفاصيل الطفل.
class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: AppTheme.radius(20),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان البطاقة
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: AppTheme.boxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    borderRadius: AppTheme.radius(10),
                  ),
                  child: Icon(icon, color: AppColors.primaryLight, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: AppTextStyles.style(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark
                ? AppColors.white.withValues(alpha: 0.07)
                : AppColors.black.withValues(alpha: 0.06),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
