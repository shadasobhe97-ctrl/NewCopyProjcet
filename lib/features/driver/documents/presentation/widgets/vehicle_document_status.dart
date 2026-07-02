import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class VehicleDocumentStatus extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isValid;
  final bool isDark;

  const VehicleDocumentStatus({
    super.key,
    required this.label,
    required this.icon,
    required this.isValid,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: AppTheme.boxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: AppTheme.radius(12),
          border: AppTheme.border(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.grey600, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.style(fontWeight: FontWeight.w600),
              ),
            ),
            if (isValid)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 20,
              )
            else
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
