import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// بطاقة اختيار الوقت (ذهاب أو رجوع).
class TimePickerCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final Color color;
  final VoidCallback onPick;

  const TimePickerCard({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.color,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      borderRadius: AppTheme.radius(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: AppTheme.boxDecoration(
          border: AppTheme.border(color: color.withValues(alpha: 0.4)),
          borderRadius: AppTheme.radius(12),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.style(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    value ?? 'اضغط للاختيار',
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: value != null ? null : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
