import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/text_styles.dart';
import 'auth_password_field.dart';

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
          keyboardType: TextInputType.phone,
          textAlign: TextAlign.right,
          style: AppTextStyles.inputTextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: const InputDecoration(
            hintText: 'رقم الهاتف (مثال: 0925556666)',
            prefixIcon: Icon(Icons.phone_android_rounded),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'الرجاء إدخال رقم الهاتف';
            final regExp = RegExp(r'^(091|092|094|095)\d{7}$');
            if (!regExp.hasMatch(value.trim())) {
              return 'رقم هاتف ليبي غير صحيح (يجب أن يبدأ بـ 09X ويتكون من 10 أرقام)';
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
            if (value.length < 6) {
              return 'كلمة المرور يجب أن لا تقل عن 6 خانات';
            }
            return null;
          },
        ),
      ],
    );
  }
}
