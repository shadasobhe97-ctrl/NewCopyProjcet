import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

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

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Text(
            "كيف تريد البحث؟",
            style: AppTextStyles.style(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "اختر الطريقة الأنسب لك للعثور على السائق المناسب",
            style: AppTextStyles.style(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // بطاقة البحث بالاسم أو الرقم
          GestureDetector(
            onTap: onSelectNameOrNumber,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // الأيقونة الدائرية الزرقاء
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_search_rounded,
                      color: AppColors.primaryLight,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "البحث بالاسم أو رقم السائق",
                          style: AppTextStyles.style(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "إذا كنت تعرف اسم السائق أو رقم هاتفه",
                          style: AppTextStyles.style(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: AppColors.grey400,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // بطاقة البحث بناءً على أطفالي
          GestureDetector(
            onTap: onSelectByChildren,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // الأيقونة الدائرية الخضراء
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      color: AppColors.success,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "البحث بناءً على أطفالي",
                          style: AppTextStyles.style(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "نبحث لك عن السائقين المناسبين حسب بيانات أطفالك وتفضيلات نقلهم",
                          style: AppTextStyles.style(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: AppColors.grey400,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
