import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/text_styles.dart';
import 'auth_password_field.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/utils/app_validators.dart';

class LoginFormFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: AppTextStyles.inputTextStyle(
            color: isDark ? AppColors.white : AppColors.black87,
          ),
          decoration: AppTheme.inputDecoration(
            context,
            hintText: 'البريد الإلكتروني',
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          validator: AppValidators.validateEmail,
        ),
        SizedBox(height: 20.h),
        AuthPasswordField(
          controller: passwordController,
        ),
      ],
    );
  }
}
