import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// محدد الجنس بشكل زرين متجاورين (ذكر / أنثى).
class GenderSelector extends StatelessWidget {
  final String selectedGender;
  final ValueChanged<String> onChanged;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GenderChip(
            label: 'ولد 👦',
            selected: selectedGender == 'MALE',
            color: AppColors.maleBlue,
            onTap: () => onChanged('MALE'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GenderChip(
            label: 'بنت 👧',
            selected: selectedGender == 'FEMALE',
            color: AppColors.femalePink,
            onTap: () => onChanged('FEMALE'),
          ),
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: AppTheme.boxDecoration(
          color:
              selected ? color.withValues(alpha: 0.12) : AppColors.transparent,
          borderRadius: AppTheme.radius(12),
          border: AppTheme.border(
            color: selected ? color : AppColors.grey.withValues(alpha: 0.35),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: selected ? color : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
