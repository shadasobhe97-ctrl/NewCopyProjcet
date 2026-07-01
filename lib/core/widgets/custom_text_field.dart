import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// حقل نص موحّد يُستخدم عبر التطبيق.
/// يدعم أيقونة بادئة / لاحقة، التحقق، والحقول متعددة الأسطر.
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool readOnly;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? Function(BuildContext)? controllerBuilder;
  final String? initialValue;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffix,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.controllerBuilder,
    this.initialValue,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      initialValue: controller == null ? initialValue : null,
      style: AppTextStyles.style(fontSize: 15),
      decoration: AppTheme.inputDecoration(
        context,
        hintText: hintText,
        labelText: labelText,
        hintStyle: AppTextStyles.style(
          color: AppColors.textMuted,
          fontSize: 13,
        ),
        prefixIcon:
            prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primaryLight, size: 20)
                : null,
        suffixIcon: suffix,
      ),
    );
  }
}
