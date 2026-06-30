import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/register_cubit.dart';
import '../../../logic/register_state.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class DriverAlternativePhoneScreen extends StatefulWidget {
  const DriverAlternativePhoneScreen({super.key});

  @override
  State<DriverAlternativePhoneScreen> createState() =>
      _DriverAlternativePhoneScreenState();
}

class _DriverAlternativePhoneScreenState
    extends State<DriverAlternativePhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _altPhoneController = TextEditingController();

  @override
  void dispose() {
    _altPhoneController.dispose();
    super.dispose();
  }

  void _submitFirstStageRegistration({bool isSkipped = false}) {
    final cubit = context.read<RegisterCubit>();

    // 1. حفظ رقم الهاتف البديل لو تم إدخاله ولم يتم التخطي
    cubit.alternativePhone = isSkipped ? null : _altPhoneController.text.trim();

    // 2. استدعاء الدالة الأولى لريان لإنشاء الحساب وإرسال الـ OTP
    cubit.registerDriverFirstStage();
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
        actions: [
          // زر تخطي من فوق لإرسال البيانات بدون الهاتف البديل
          TextButton(
            onPressed: () => _submitFirstStageRegistration(isSkipped: true),
            child: Text(
              "تخطي",
              style: AppTextStyles.style(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is DriverRegisterFirstStageSuccess) {
              // 🌟 نجاح المرحلة الأولى وتوليد كود التحقق -> التوجيه لشاشة الـ OTP تبيع السائق
              Navigator.pushNamed(context, '/driverOtp');
            } else if (state is DriverRegisterFirstStageError) {
              // عرض رسالة الخطأ في حالة وجود مشكلة بالسيرفر أو تكرار البيانات
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppColors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "رقم هاتف بديل للسائق",
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "يمكنكِ إضافة رقم هاتف احتياطي آخر للاتصال به في حالات الطوارئ أو انقطاع الشبكة (اختياري).",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 40),

                    // حقل إدخال رقم الهاتف البديل
                    TextFormField(
                      controller: _altPhoneController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      decoration: AppTheme.inputDecoration(context, 
                        labelText: "رقم الهاتف البديل",
                        hintText: "09XXXXXXXX",
                        prefixIcon: Icon(Icons.phone_enabled_outlined),
                      ),
                      validator: (value) {
                        if (value != null &&
                            value.trim().isNotEmpty &&
                            value.trim().length < 7) {
                          return "يجب ألا يقل رقم الهاتف عن 7 أرقام";
                        }
                        return null;
                      },
                    ),

                    const Spacer(),

                    // زر إرسال البيانات والارسال للباكيند مع الـ Loading
                    ElevatedButton(
                      onPressed: state is DriverRegisterFirstStageLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _submitFirstStageRegistration(isSkipped: false);
                              }
                            },
                      style: AppTheme.elevatedButtonStyle(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state is DriverRegisterFirstStageLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Text(
                              "إنشاء الحساب والمتابعة",
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
            );
          },
        ),
      ),
    );
  }
}
