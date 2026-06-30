import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/widgets/custom_auth_button.dart';
import 'package:kids_transport/features/auth/login/logic/auth_cubit.dart';
import 'package:kids_transport/features/auth/login/logic/auth_state.dart';
import 'package:kids_transport/features/auth/login/presentation/widgets/auth_header_section.dart';
import 'package:kids_transport/features/auth/login/presentation/widgets/auth_password_field.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ==================== [دالة عرض الدايلوق الاحترافي] ====================
  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // يمنع إغلاق الدايلوق عند الضغط خارج الشاشة لإجبار المستخدم على الضغط على "تم"
      builder: (BuildContext dialogContext) {
        final isDark = context.isDarkMode;
        return AlertDialog(
          shape: AppTheme.roundedRectangleBorder(
            borderRadius: AppTheme.radius(24.r),
          ),
          backgroundColor: context.darkSurface,
          title: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: context.successColor,
                size: 28.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'تم التعديل بنجاح',
                style: AppTextStyles.heading(
                  color: isDark ? AppColors.white : AppColors.black87,
                ).copyWith(fontSize: 18.sp),
              ),
            ],
          ),
          content: Text(
            'تم تغيير كلمة المرور بنجاح. يمكنك الآن العودة وتسجيل الدخول بحسابك التجاري مجدداً.',
            style: AppTextStyles.body(
              color: isDark ? AppColors.grey300 : AppColors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 1. إغلاق الدايلوق باستخدام الـ context تبيع الدايلوق نفسه
                Navigator.pop(dialogContext);

                // 2. التوجيه الآمن باستخدام الـ context تبيع الشاشة بعد التأكد أنها mounted
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
              child: Text(
                'تم، تسجيل الدخول',
                style: AppTextStyles.body(
                  color: context.primaryColor,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
  // ======================================================================

  @override
  void dispose() {
    // 🌟 تصفير وتفريغ الحقول قبل الإغلاق لمنع الحقول من قراءتهم أثناء تدمير الشاشة
    _passwordController.clear();
    _confirmPasswordController.clear();

    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is PasswordResetSuccessState) {
              // بدلاً من التوجيه الفوري، حنفتحوا الدايلوق المميز اللي يوضح نجاح العملية
              _showSuccessDialog(context, state.message);
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
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AuthHeaderSection(
                      title: 'تعيين كلمة المرور الجديدة',
                      subtitle:
                          'أدخل كلمة المرور الجديدة القوية لتحديث حسابك التجاري',
                    ),
                    SizedBox(height: 20.h),

                    AuthPasswordField(
                      controller: _passwordController,
                      hintText: 'كلمة المرور الجديدة',
                    ),
                    SizedBox(height: 20.h),

                    AuthPasswordField(
                      controller: _confirmPasswordController,
                      hintText: 'تأكيد كلمة المرور الجديدة',
                      validator: (value) {
                        if (value != _passwordController.text)
                          return 'كلمات المرور غير متطابقة';
                        return null;
                      },
                    ),
                    SizedBox(height: 40.h),

                    CustomAuthButton(
                      text: 'تحديث كلمة المرور',
                      isLoading: state is AuthLoading,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthCubit>().resetPassword(
                            email: widget.email,
                            password: _passwordController.text,
                            confirmPassword: _confirmPasswordController.text,
                          );
                        }
                      },
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
