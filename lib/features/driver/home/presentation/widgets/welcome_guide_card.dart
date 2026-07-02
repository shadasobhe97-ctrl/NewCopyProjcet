import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class WelcomeGuideCard extends StatelessWidget {
  final String driverName;

  const WelcomeGuideCard({super.key, required this.driverName});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.boxDecoration(
        gradient: AppTheme.linearGradient(
          colors: isDark
              ? [
                  AppColors.primaryDark.withValues(alpha: 0.15),
                  AppColors.primaryDark.withValues(alpha: 0.05),
                ]
              : [AppColors.primaryContainerLight, AppColors.primarySoft],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: AppTheme.radius(20),
        border: AppTheme.border(
          color: AppColors.primaryLight.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة ترحيبية
          Container(
            width: 46,
            height: 46,
            decoration: AppTheme.boxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
               Icons.waving_hand_rounded,
              color: AppColors.primaryLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // النص الإرشادي
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أهلاً بك يا $driverName! 👋',
                  style: AppTextStyles.style(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "يسعدنا انضمامك إلينا. للبدء في استقبال طلبات أولياء الأمور وتنسيق رحلات المدارس، تأكد من تفعيل وضع 'متصل' من الزر في الأعلى.",
                  style: AppTextStyles.style(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
