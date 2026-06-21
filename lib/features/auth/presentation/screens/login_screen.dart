import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/widgets/custom_auth_button.dart';
import 'package:kids_transport/features/auth/logic/auth_cubit.dart';
import 'package:kids_transport/features/auth/logic/auth_state.dart';
import 'package:kids_transport/features/auth/presentation/widgets/login_form_fields.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
         listener: (context, state) async {
  if (state is AuthSuccess) {
    // 1. عرض رسالة النجاح الراجعة من السيرفر ديناميكياً
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.message),
        backgroundColor: AppColors.success,
      ),
    );

    // ==================== الباكيند والـ Storage ====================
    // حفظ الجلسة باستخدام الدالة المعدلة والمفاتيح الموحدة 🌟
    await StorageService.saveUserSession(
      token: state.token,
      roleId: state.roleId, // تعديل الاسم الإملائي هنا لـ roleId
    );
    // =============================================================

    // 2. التوجيه الديناميكي بناءً على دور المستخدم
    if (mounted) {
      if (state.roleName == "سائق") {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/driverHome', // تأكدي أن المسار هذا معرف في الـ central router تبيعك
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/parentHome', // تأكدي أن المسار هذا معرف في الـ central router تبيعك
          (route) => false,
        );
      }
    }
  } else if (state is AuthError) {
    // عرض الخطأ في حال فشل تسجيل الدخول
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.errorMessage),
        backgroundColor: AppColors.error,
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
                    SizedBox(height: 1.h),
                    // الشعار في الأعلى متناسق ذكياً مع وضع الثيم (تم تكبير الحجم للتناسب)
                    Image.asset(
                      isDark
                          ? 'assets/images/dark_logo.png'
                          : 'assets/images/ligth_logo.png',
                      width: 230.r,
                      height: 230.r,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.directions_bus_rounded,
                        size: 100.r,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 1.h),

                    Text(
                      'تسجيل الدخول',
                      style: AppTextStyles.heading(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'أهلاً بك مجدداً في تطبيق دربي',
                      style: AppTextStyles.body(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 25.h),

                    // حقول الإدخال المحمية بالـ Validation
                    LoginFormFields(
                      phoneController: _phoneController,
                      passwordController: _passwordController,
                    ),

                    SizedBox(height: 10.h),

                    // زر نسيت كلمة المرور باليسار (المكان الصحيح في واجهات الـ RTL)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          // التوجيه الاحترافي باستخدام الـ Named Routes التابعة للراوتر المركزي
                          Navigator.pushNamed(
                            context,
                            AppRoutes.forgotPassword,
                          );
                        },
                        child: Text(
                          'نسيت كلمة المرور؟',
                          style: AppTextStyles.body(
                            color: isDark
                                ? AppColors.primaryDark
                                : AppColors.primaryLight,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // زر الدخول الموحد والذكي بالـ Loading State
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

                    // ليس لدي حساب لإنشاء حساب جديد (التوجيه لـ Role Selection موقف حالياً ومحطوط كومنت)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب؟ ',
                          style: AppTextStyles.body(color: AppColors.textMuted),
                        ),
                        GestureDetector(
                          onTap: () {
                             Navigator.pushNamed(context, '/selectRole');
                          },
                          child: Text(
                            'إنشاء حساب',
                            style: AppTextStyles.body(
                              color: isDark
                                  ? AppColors.primaryDark
                                  : AppColors.primaryLight,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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
