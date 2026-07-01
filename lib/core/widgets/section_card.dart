import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// بطاقة موحّدة مع عنوان وأيقونة للقسم.
/// تُستخدم في شاشات الإضافة والتفاصيل وعرض المعلومات.
class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: AppTheme.radius(18),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── عنوان القسم ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: AppTheme.boxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.1),
                  borderRadius: AppTheme.radius(9),
                ),
                child: Icon(icon, color: AppColors.primaryLight, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.style(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
