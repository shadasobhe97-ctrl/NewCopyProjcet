import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../data/models/absence_model.dart';

class AbsenceTypeSelectorWidget extends StatelessWidget {
  final AbsenceType selectedType;
  final void Function(AbsenceType type) onChanged;

  const AbsenceTypeSelectorWidget({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCard(
          context,
          type: AbsenceType.pickup,
          icon: Icons.arrow_circle_up_rounded,
          label: 'ذهاب فقط',
        ),
        const SizedBox(width: 8),
        _buildCard(
          context,
          type: AbsenceType.dropoff,
          icon: Icons.arrow_circle_down_rounded,
          label: 'عودة فقط',
        ),
        const SizedBox(width: 8),
        _buildCard(
          context,
          type: AbsenceType.both,
          icon: Icons.swap_vert_circle_rounded,
          label: 'ذهاب وعودة',
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required AbsenceType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = selectedType == type;
    final isDark = context.isDarkMode;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? context.primaryColor
                : (isDark ? AppColors.surfaceDark : AppColors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? context.primaryColor
                  : (isDark ? AppColors.grey700 : AppColors.grey200),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: context.primaryColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.white
                    : (isDark ? AppColors.grey400 : AppColors.grey500),
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.style(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.white
                      : (isDark ? AppColors.grey400 : AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
