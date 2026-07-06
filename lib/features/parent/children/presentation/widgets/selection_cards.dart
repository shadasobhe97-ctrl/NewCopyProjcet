import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';

class SelectionCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? context.primaryColor.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? context.primaryColor : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.style(
              color: isSelected ? context.primaryColor : context.textMuted,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}