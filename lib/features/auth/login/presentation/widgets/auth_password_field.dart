import 'package:flutter/material.dart';
import '../../../../../core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String>? validator;

  const AuthPasswordField({
    super.key,
    required this.controller,
    this.hintText = 'كلمة المرور',
    this.validator,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscured,
      textAlign: TextAlign.right,
      style: AppTextStyles.inputTextStyle(
        color: isDark ? AppColors.white : AppColors.black87,
      ),
      decoration: AppTheme.inputDecoration(context, 
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        ),
      ),
      validator:
          widget.validator ??
          (value) {
            if (value == null || value.isEmpty)
              return 'الرجاء إدخال كلمة المرور';
            if (value.length < 6) return 'كلمة المرور يجب أن لا تقل عن 6 خانات';

            final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
            final hasDigit = RegExp(r'[0-9]').hasMatch(value);
            if (!hasLetter || !hasDigit) {
              return 'يجب أن تحتوي كلمة المرور على حروف وأرقام معاً';
            }
            return null;
          },
    );
  }
}
