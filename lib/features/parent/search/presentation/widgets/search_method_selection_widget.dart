import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'search_method_card.dart';

class SearchMethodSelectionWidget extends StatelessWidget {
  final VoidCallback onSelectNameOrNumber;
  final VoidCallback onSelectByChildren;

  const SearchMethodSelectionWidget({
    super.key,
    required this.onSelectNameOrNumber,
    required this.onSelectByChildren,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            "كيف تريد البحث؟",
            style: AppTextStyles.style(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "اختر طريقة البحث التي تناسب احتياجك للوصول إلى السائق المناسب.",
            style: AppTextStyles.style(
              fontSize: 13,
              color: isDark ? AppColors.grey400 : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // كرت "أعرف السائق"
          SearchMethodCard(
            emoji: "🔍",
            title: "أعرف السائق",
            description: "ابحث باستخدام اسم السائق أو رقم هاتفه.",
            buttonText: "ابدأ البحث",
            onTap: onSelectNameOrNumber,
            isPrimary: false,
          ),
          const SizedBox(height: 20),

          // كرت "ابحث عن سائق مناسب"
          SearchMethodCard(
            emoji: "🚌",
            title: "ابحث عن سائق مناسب",
            description: "سنقترح سائقين مناسبين حسب بيانات النقل الخاصة بأطفالك.",
            buttonText: "ابحث عن سائقين",
            onTap: onSelectByChildren,
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}
