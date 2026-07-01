import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class EditableVehicleField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final TextEditingController controller;
  final bool isDark;
  final bool isEditing;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const EditableVehicleField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.controller,
    required this.isDark,
    required this.isEditing,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isEditing
            ? TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                validator: validator,
                decoration: AppTheme.inputDecoration(
                  context,
                  labelText: label,
                  prefixIcon: Icon(icon, color: primaryColor),
                ),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.boxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  borderRadius: AppTheme.radius(16),
                  border: AppTheme.border(
                    color: isDark ? AppColors.grey800 : AppColors.grey200,
                  ),
                  boxShadow: [
                    AppTheme.boxShadow(
                      color: AppColors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: AppTheme.boxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: AppTheme.radius(10),
                      ),
                      child: Icon(icon, color: primaryColor, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.style(
                            fontSize: 12,
                            color: AppColors.grey500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          style: AppTextStyles.style(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
