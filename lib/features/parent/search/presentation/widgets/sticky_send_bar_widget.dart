import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// شريط الإرسال السفلي الثابت - يظهر فقط عند تحديد سائق واحد أو أكثر.
/// يدعم Slide + Fade animation عند الظهور والاختفاء.
/// لا يؤثر على أي Widget أو Layout آخر في الشاشة.
class StickySendBarWidget extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onSendPressed;

  const StickySendBarWidget({
    super.key,
    required this.selectedCount,
    required this.onSendPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── سطر عدد السائقين المحددين ──
          Row(
            children: [
              Icon(Icons.check_circle_rounded, size: 15, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                'تم اختيار $selectedCount ${selectedCount == 1 ? 'سائق' : 'سائقين'}',
                style: AppTextStyles.style(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // ── نص التنبيه المهم ──
          Text(
            'عند قبول أحد السائقين لطلب الاشتراك سيتم إلغاء الطلب المرسل إلى جميع السائقين الآخرين تلقائيًا.',
            style: AppTextStyles.style(
              fontSize: 11,
              color: isDark ? AppColors.grey400 : AppColors.grey600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // ── زر الإرسال ──
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: selectedCount > 0 ? onSendPressed : null,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text(
                'إرسال الطلب',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: cs.onPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                disabledBackgroundColor: isDark ? AppColors.grey800 : AppColors.grey200,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
