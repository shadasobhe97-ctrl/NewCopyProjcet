import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/theme/cubit/theme_cubit.dart';
import 'package:kids_transport/features/admin/logic/admin_auth_cubit.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authCubit = context.read<AdminAuthCubit>();
      if (authCubit.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authCubit = context.read<AdminAuthCubit>();

      final success = await authCubit.login(
        _phoneController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
      } else if (mounted && authCubit.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authCubit.errorMessage!),
            backgroundColor: context.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ), // لعدم تمدد الحقول في الويب
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // اللوقو المناسب للثيم
                        Image.asset(
                          isDark
                              ? 'assets/images/dark_logo.png'
                              : 'assets/images/ligth_logo.png',
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'تسجيل دخول المسؤول',
                          style: AppTextStyles.style(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: context.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // حقل رقم الهاتف
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          decoration: AppTheme.inputDecoration(context, 
                            labelText: 'رقم الهاتف',
                            hintText: '0925556666',
                            prefixIcon: Icon(Icons.phone_android_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'الرجاء إدخال رقم الهاتف';
                            }
                            final regExp = RegExp(r'^(091|092|094|095)\d{7}$');
                            if (!regExp.hasMatch(value.trim())) {
                              return 'رقم هاتف ليبي غير صحيح';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // حقل كلمة المرور
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: AppTheme.inputDecoration(context, 
                            labelText: 'كلمة المرور',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال كلمة المرور';
                            }
                            if (value.length < 6) {
                              return 'كلمة المرور قصيرة جداً';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // زر تسجيل الدخول
                        BlocBuilder<AdminAuthCubit, AdminAuthState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: state.isLoading
                                    ? null
                                    : _handleLogin,
                                child: state.isLoading
                                    ? const CircularProgressIndicator(
                                        color: AppColors.white,
                                      )
                                    : Text('تسجيل الدخول'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          icon: Icon(
                            Icons.phone_android_rounded,
                            color: context.primaryColor,
                          ),
                          label: Text(
                            'التحويل لتسجيل دخول المستخدمين (سائق / ولي أمر)',
                            style: AppTextStyles.style(color: context.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
