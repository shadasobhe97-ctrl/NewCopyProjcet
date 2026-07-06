import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/text_styles.dart';
import '../../../../../core/utils/theme_context.dart';

/// مؤشر التقدم بين خطوتي إضافة الطفل
class AddChildStepIndicator extends StatelessWidget {
  final int currentStep;
  const AddChildStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.isDarkMode ? AppColors.darkCard : AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _StepCircle(
            number: 1,
            label: 'بيانات الطفل',
            isActive: currentStep == 1,
            isDone: currentStep > 1,
          ),
          Expanded(
            child: Container(
              height: 2,
              color: currentStep > 1 ? context.primaryColor : AppColors.grey200,
            ),
          ),
          _StepCircle(
            number: 2,
            label: 'تفضيلات النقل',
            isActive: currentStep == 2,
            isDone: currentStep > 2,
          ),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;
  final bool isDone;
  const _StepCircle({
    required this.number,
    required this.label,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final color = (isActive || isDone) ? context.primaryColor : AppColors.grey300;
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isActive || isDone) ? context.primaryColor : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : Text(
                    '$number',
                    style: TextStyle(
                      color: isActive ? Colors.white : color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.style(
            fontSize: 11,
            color: (isActive || isDone) ? context.primaryColor : AppColors.grey400,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

/// بطاقة قسم قابلة لإعادة الاستخدام في شاشات إضافة الطفل
class AddChildSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const AddChildSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.boxDecoration(
        color: context.isDarkMode ? AppColors.darkCard : AppColors.white,
        borderRadius: AppTheme.radius(16),
        border: AppTheme.border(color: AppColors.grey200),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: context.isDarkMode ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: context.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.style(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }
}

/// زر اختيار الجنس
class GenderSelectionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;
  const GenderSelectionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withOpacity(0.12) : Colors.transparent,
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: AppTheme.radius(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? selectedColor : AppColors.grey400, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.style(
                color: isSelected ? selectedColor : AppColors.grey500,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
