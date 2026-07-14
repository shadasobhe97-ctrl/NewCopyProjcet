import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/register_cubit.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class DriverBasicInfoScreen extends StatefulWidget {
  const DriverBasicInfoScreen({super.key});

  @override
  State<DriverBasicInfoScreen> createState() => _DriverBasicInfoScreenState();
}

class _DriverBasicInfoScreenState extends State<DriverBasicInfoScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String selectedGender = 'male';

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "كلمة المرور مطلوبة";
    }
    if (value.length < 7) {
      return "يجب ألا تقل كلمة المرور عن 7 خانات";
    }

    // التحقق من وجود حرف ورقم على الأقل
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    bool hasDigits = value.contains(RegExp(r'[0-9]'));

    if (!hasDigits || (!hasUppercase && !hasLowercase)) {
      return "يجب أن تحتوي كلمة المرور على 6 ارقام وحرف على الاقل ";
    }

    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? AppColors.white : AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Text(
                  "بيانات السائق الأساسية",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),
                Text(
                  "يرجى إدخال البيانات الشخصية الأساسية لإنشاء حسابك.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 30),

                // الاسم الكامل (الثلاثي)
                TextFormField(
                  controller: _nameController,
                  textAlign: TextAlign.right,
                  decoration: AppTheme.inputDecoration(
                    context,
                    labelText: "الاسم الكامل (الثلاثي على الأقل)",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return "الرجاء إدخال الاسم الكامل";
                    if (v.trim().length < 10 || v.trim().length > 100)
                      return "يجب أن يكون الاسم بين 10 إلى 100 حرف";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // البريد الإلكتروني
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: AppTheme.inputDecoration(
                    context,
                    labelText: "البريد الإلكتروني",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v == null || !v.contains('@')
                      ? "يرجى إدخال بريد إلكتروني صالح"
                      : null,
                ),
                const SizedBox(height: 16),

                // رقم الهاتف (10 أرقام ويبدأ بـ 09 حتماً)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  decoration: AppTheme.inputDecoration(
                    context,
                    labelText: "رقم الهاتف",
                    hintText: "09XXXXXXXX",
                    prefixIcon: Icon(Icons.phone_android),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return "رقم الهاتف إجباري";
                    if (v.trim().length != 10)
                      return "يجب أن يتكون الرقم من 10 أرقام بالضبط";
                    if (!v.trim().startsWith("09"))
                      return "يجب أن يبدأ الرقم بـ 09 حصراً";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: AppTheme.inputDecoration(
                    context,
                    labelText: "كلمة المرور",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),

                // حقل تأكيد كلمة المرور (مع أيقونة العين)
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: AppTheme.inputDecoration(
                    context,
                    labelText: "تأكيد كلمة المرور",
                    prefixIcon: const Icon(Icons.lock_reset),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => setState(
                        () => _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return "الرجاء تأكيد كلمة المرور";
                    if (v != _passwordController.text)
                      return "كلمة المرور غير متطابقة";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // زر التالي
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // حفظ البيانات المبدئية في الكيوبت
                      final cubit = context.read<RegisterCubit>();
                      cubit.fullName = _nameController.text.trim();
                      cubit.email = _emailController.text.trim();
                      cubit.phoneNumber = _phoneController.text.trim();
                      cubit.password = _passwordController.text;

                      // الانتقال للشاشة التالية: شاشة الصورة الشخصية المشتركة
                      Navigator.pushNamed(context, '/driverAvatar');
                    }
                  },
                  style: AppTheme.elevatedButtonStyle(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    "التالي",
                    style: AppTextStyles.style(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
