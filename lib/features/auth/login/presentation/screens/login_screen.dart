import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/widgets/custom_auth_button.dart';
import 'package:kids_transport/features/auth/login/logic/auth_cubit.dart';
import 'package:kids_transport/features/auth/login/logic/auth_state.dart';
import 'package:kids_transport/features/auth/login/presentation/widgets/login_form_fields.dart';
import 'package:kids_transport/core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: context.successColor,
                ),
              );

              final targetRoute = state.roleId == 3
                  ? AppRoutes.parentHome
                  : state.roleId == 4
                  ? (StorageService.getIsActive() == true
                        ? AppRoutes.splash
                        : '/driverWaiting')
                  : AppRoutes.adminDashboard;

              Navigator.pushNamedAndRemoveUntil(
                context,
                targetRoute,
                (route) => false,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: context.errorColor,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 50.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      isDark
                          ? 'assets/images/dark_logo.png'
                          : 'assets/images/ligth_logo.png',
                      width: 230.r,
                      height: 230.r,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.directions_bus_rounded,
                        size: 100.r,
                        color: context.primaryColor,
                      ),
                    ),
                    Text(
                      'تسجيل الدخول',
                      style: AppTextStyles.heading(
                        color: isDark ? AppColors.white : AppColors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'أهلاً بك مجدداً في تطبيق دربي',
                      style: AppTextStyles.body(color: context.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 25.h),
                    LoginFormFields(
                      phoneController: _phoneController,
                      passwordController: _passwordController,
                    ),
                    SizedBox(height: 10.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.forgotPassword,
                          );
                        },
                        child: Text(
                          'نسيت كلمة المرور؟',
                          style: AppTextStyles.body(
                            color: context.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    CustomAuthButton(
                      text: 'دخول',
                      isLoading: state is AuthLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthCubit>().login(
                            phone: _phoneController.text.trim(),
                            password: _passwordController.text,
                          );
                        }
                      },
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب؟ ',
                          style: AppTextStyles.body(color: context.textMuted),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/selectRole');
                          },
                          child: Text(
                            'إنشاء حساب',
                            style: AppTextStyles.body(
                              color: context.primaryColor,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.adminLogin);
                      },
                      icon: Icon(
                        Icons.admin_panel_settings_outlined,
                        color: context.primaryColor,
                      ),
                      label: Text(
                        'تسجيل دخول المسؤول (الأدمن)',
                        style: AppTextStyles.style(color: context.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
