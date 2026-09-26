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

  /// عرض التنبيه بسهولة وإرجاع اختيار السائق (true للمتابعة والبدء، false لتوصيل الشاحن)
  static Future<bool?> show(BuildContext context, {required int batteryLevel}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
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
        contentPadding: const EdgeInsets.all(22),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.battery_alert_rounded,
                size: 32,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'تنبيه مستوى البطارية',
              style: AppTextStyles.style(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.black,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'نسبة البطارية الحالية: $batteryLevel%',
                style: AppTextStyles.style(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'عزيزي السائق، تتبع الرحلة المباشر يعتمد على استمرار شحن الهاتف لضمان سلامة الأطفال وراحة بال أولياء الأمور.\nانقطاع الشحن أثناء الرحلة قد يتسبب في قلق الأهل، ونحيطكم علماً بأن البدء دون توصيل الشاحن يكون تحت مسؤوليتكم الكريمة.',
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 12.5,
                height: 1.55,
                color: context.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark ? AppColors.grey700 : AppColors.grey300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'توصيل الشاحن أولاً',
                      style: AppTextStyles.style(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: context.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryButton(
                    label: 'متابعة وبدء الرحلة',
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
