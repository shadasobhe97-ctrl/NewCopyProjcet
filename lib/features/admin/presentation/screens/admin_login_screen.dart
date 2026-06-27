import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/cubit/theme_cubit.dart';
import 'package:kids_transport/features/admin/logic/admin_auth_provider.dart';

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
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);
      if (provider.isAuthenticated) {
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
      final provider = Provider.of<AdminAuthProvider>(context, listen: false);
      
      final success = await provider.login(
        _phoneController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
      } else if (mounted && provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!), backgroundColor: AppColors.errorLight),
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
              constraints: const BoxConstraints(maxWidth: 450), // لعدم تمدد الحقول في الويب
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
                        const Text(
                          'تسجيل دخول المسؤول',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                        ),
                        const SizedBox(height: 32),
                        
                        // حقل رقم الهاتف
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          decoration: const InputDecoration(
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
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'الرجاء إدخال كلمة المرور';
                            if (value.length < 6) return 'كلمة المرور قصيرة جداً';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        
                        // زر تسجيل الدخول
                        Consumer<AdminAuthProvider>(
                          builder: (context, provider, child) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: provider.isLoading ? null : _handleLogin,
                                child: provider.isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text('تسجيل الدخول'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          icon: const Icon(Icons.phone_android_rounded, color: AppColors.primaryLight),
                          label: const Text(
                            'التحويل لتسجيل دخول المستخدمين (سائق / ولي أمر)',
                            style: TextStyle(color: AppColors.primaryLight),
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
