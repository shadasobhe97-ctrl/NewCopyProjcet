import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class EditableVehicleField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final TextEditingController controller;
  final bool isEditing;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const EditableVehicleField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.controller,
    required this.isEditing,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: isEditing
          ? TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: AppTextStyles.inputTextStyle(
                color: theme.colorScheme.onSurface,
              ),
              validator: validator,
              decoration: AppTheme.inputDecoration(
                context,
                labelText: label,
                prefixIcon: Icon(icon, color: theme.primaryColor),
              ),
            )
          : Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: Icon(icon, color: theme.primaryColor),
                title: Text(label, style: AppTextStyles.hintTextStyle()),
                subtitle: Text(
                  value,
                  style: AppTextStyles.body(
                    color: theme.colorScheme.onSurface,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
    );
  }
}
