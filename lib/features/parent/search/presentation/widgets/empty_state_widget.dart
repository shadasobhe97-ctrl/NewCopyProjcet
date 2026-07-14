import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// ويدجت موحد لحالة النتائج الفارغة
/// يُستخدم عندما لا يرجع البحث أي سائقين
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
    this.icon = Icons.search_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.grey800 : AppColors.grey100),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 40,
              color: isDark ? AppColors.grey600 : AppColors.grey400,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? AppColors.grey200 : AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.style(
              fontSize: 13,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: onButtonPressed,
                icon: Icon(Icons.edit_rounded, size: 16, color: theme.colorScheme.primary),
                label: Text(
                  buttonText!,
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: theme.colorScheme.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
