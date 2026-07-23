import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';

class FinanceSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const FinanceSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.boxDecoration(
            color: context.cardSurface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              AppTheme.boxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor ?? context.primaryColor, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: AppTextStyles.style(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.isDarkMode ? AppColors.white : AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTextStyles.style(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
