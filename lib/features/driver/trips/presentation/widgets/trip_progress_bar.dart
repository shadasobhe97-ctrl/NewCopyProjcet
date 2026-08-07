import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';

/// شريط تقدّم الرحلة (completed / total)
class TripProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const TripProgressBar({super.key, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'تقدّم الرحلة',
              style: AppTextStyles.style(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Text(
              '$completed / $total',
              style: AppTextStyles.style(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: context.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: AppTheme.radius(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: AppColors.grey.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(context.primaryColor),
          ),
        ),
      ],
    );
  }
}
