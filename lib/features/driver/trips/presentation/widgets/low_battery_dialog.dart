import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/primary_button.dart';

/// تنبيه انخفاض مستوى البطارية قبل بدء الرحلة
class LowBatteryDialog extends StatelessWidget {
  final int batteryLevel;

  const LowBatteryDialog({super.key, required this.batteryLevel});

  /// عرض التنبيه بسهولة
  static Future<void> show(BuildContext context, {required int batteryLevel}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LowBatteryDialog(batteryLevel: batteryLevel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
        shape: AppTheme.roundedRectangleBorder(borderRadius: AppTheme.radius(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.battery_alert_rounded,
                size: 34,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'تنبيه',
              style: AppTextStyles.style(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'مستوى شحن هاتفك منخفض. يرجى توصيل هاتفك بالشاحن قبل بدء الرحلة لضمان استمرار التتبع.',
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 13,
                height: 1.5,
                color: context.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'نسبة البطارية الحالية: $batteryLevel%',
                style: AppTextStyles.style(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'حسنًا',
              width: double.infinity,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
