import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class DailyStatsRow extends StatelessWidget {
  final int tripsCount;
  final int studentsCount;

  const DailyStatsRow({super.key, required this.tripsCount, required this.studentsCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.directions_bus_rounded,
            iconColor: AppColors.primaryLight,
            iconBgColor: AppColors.primaryLight.withValues(alpha: 0.1),
            title: 'رحلات اليوم',
            value: tripsCount.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.people_alt_rounded,
            iconColor: AppColors.accentPurple,
            iconBgColor: AppColors.accentPurple.withValues(alpha: 0.1),
            title: 'الطلاب',
            value: studentsCount.toString(),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppTheme.radius(20),
        border: AppTheme.border(
          color: isDark ? AppColors.grey800 : AppColors.grey.withValues(alpha: 0.15),
        ),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة
          Container(
            width: 44,
            height: 44,
            decoration: AppTheme.boxDecoration(
              color: iconBgColor,
              borderRadius: AppTheme.radius(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 12),

          // الرقم الكبير
          Text(
            value,
            style: AppTextStyles.style(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),

          // العنوان
          Text(
            title,
            style: AppTextStyles.style(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
