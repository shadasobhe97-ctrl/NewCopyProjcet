import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class SearchMethodCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onTap;
  final bool isPrimary;

  const SearchMethodCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isPrimary
        ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.4 : 0.2)
        : (isDark ? AppColors.grey800 : AppColors.grey200);

    final shadowColor = isPrimary
        ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.05)
        : AppColors.black.withValues(alpha: isDark ? 0.2 : 0.03);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: isPrimary ? 1.5 : 1),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: isPrimary ? 20 : 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color:
                        (isPrimary
                                ? AppColors.success
                                : theme.colorScheme.primary)
                            .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTextStyles.style(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.white
                                    : AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: AppTextStyles.style(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.grey400
                              : AppColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPrimary
                      ? theme.colorScheme.primary
                      : (isDark ? AppColors.grey800 : AppColors.grey100),
                  foregroundColor: isPrimary
                      ? theme.colorScheme.onPrimary
                      : (isDark ? AppColors.white : theme.colorScheme.primary),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isPrimary
                        ? theme.colorScheme.onPrimary
                        : (isDark
                              ? AppColors.white
                              : theme.colorScheme.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
