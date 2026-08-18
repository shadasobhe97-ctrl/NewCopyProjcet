import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/text_styles.dart';
import 'auth_password_field.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class LoginFormFields extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController passwordController;

  const LoginFormFields({
    super.key,
    required this.phoneController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.emailAddress,
          textAlign: TextAlign.right,
          style: AppTextStyles.inputTextStyle(
            color: isDark ? AppColors.white : AppColors.black87,
          ),
          decoration: AppTheme.inputDecoration(
            context, 
            hintText: 'رقم الهاتف أو البريد الإلكتروني',
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'الرجاء إدخال رقم الهاتف أو البريد الإلكتروني';
            }
            final input = value.trim();
            final isEmailFormat = input.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(input);

            if (isEmailFormat) {
              final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegExp.hasMatch(input)) {
                return 'صيغة البريد الإلكتروني غير صحيحة';
              }
            } else {
              final libyanPhoneRegExp = RegExp(r'^(091|092|093|094|095)\d{7}$');
              if (!libyanPhoneRegExp.hasMatch(input)) {
                return 'رقم هاتف ليبي غير صحيح (يجب أن يبدأ بـ 09X ويتكون من 10 أرقام)';
              }
            }
            return null;
          },
        ),
        SizedBox(height: 20.h),
        AuthPasswordField(
          controller: passwordController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال كلمة المرور';
            }
            // تم إيقاف التحقق الإضافي مؤقتاً للتجربة
            // final digitCount = RegExp(r'\d').allMatches(value).length;
            // final hasLetter = RegExp(r'[a-zA-Z\u0600-\u06FF]').hasMatch(value);

            // if (digitCount < 6) {
            //   return 'كلمة المرور يجب أن تحتوي على 6 أرقام على الأقل';
            // }
            // if (!hasLetter) {
            //   return 'كلمة المرور يجب أن تحتوي على حرف واحد على الأقل';
            // }
            return null;
          },
        ),
      ],
    );
  }
}
