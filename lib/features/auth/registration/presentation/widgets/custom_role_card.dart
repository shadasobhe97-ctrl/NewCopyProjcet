import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class CustomRoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomRoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isSelected
        ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08)
        : (isDark ? AppColors.darkCard : AppColors.surfaceLight);

    final borderColor = isSelected
        ? theme.colorScheme.primary
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    final iconBgColor = isSelected
        ? theme.colorScheme.primary
        : (isDark ? AppColors.surfaceDark : AppColors.primarySoft);

    final iconColor = isSelected
        ? AppColors.white
        : (isDark ? AppColors.white70 : theme.colorScheme.primary);

    final titleColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface;

    final descriptionColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: AppTheme.boxDecoration(
          color: cardBgColor,
          borderRadius: AppTheme.radius(16),
          border: AppTheme.border(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  AppTheme.boxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  AppTheme.boxShadow(
                    color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.boxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: descriptionColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 24),
          ],
        ),
      ),
    );
  }
}
