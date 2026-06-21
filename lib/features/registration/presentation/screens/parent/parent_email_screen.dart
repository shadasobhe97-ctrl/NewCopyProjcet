import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/register_cubit.dart';
import '../../../logic/register_state.dart';

class ParentEmailScreen extends StatefulWidget {
  const ParentEmailScreen({super.key});

  @override
  State<ParentEmailScreen> createState() => _ParentEmailScreenState();
}

class _ParentEmailScreenState extends State<ParentEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is ParentOtpSentSuccess) {
              // نجاح إرسال الـ OTP -> التوجيه لشاشة الـ OTP الخاصة بالأب
              // نمرر الإيميل كـ argument عشان نحتاجوه بعدين
              Navigator.pushNamed(context, '/parentOtp', arguments: _emailController.text.trim());
            } else if (state is ParentOtpSentError) {
              // عرض خطأ السيرفر (مثلاً الإيميل مسجل مسبقاً)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
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
                    // 🌟 هنا الـ AuthHeaderSection المعتمد عندكِ
                    Text(
                      "التحقق من البريد",
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "يرجى إدخال بريدك الإلكتروني لإرسال كود التحقق (OTP) وتأمين حسابك.",
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 40),

                    // حقل الإدخال بنفس ديزاين الـ Custom Text Field تبيعكِ
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      decoration: const InputDecoration(
                        labelText: "البريد الإلكتروني",
                        hintText: "example@gmail.com",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "الرجاء إدخال البريد الإلكتروني";
                        }
                        // ريجكس بسيط للتحقق من صيغة الإيميل
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                          return "الرجاء إدخال بريد إلكتروني صالح";
                        }
                        return null;
                      },
                    ),
                    const Spacer(),

                    // زر الإرسال التفاعلي مع الـ Loading
                    ElevatedButton(
                      onPressed: state is ParentOtpSentLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                // استدعاء دالة الكيوبت لإرسال الـ OTP
                                context.read<RegisterCubit>().sendParentOtp(_emailController.text.trim());
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state is ParentOtpSentLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              "إرسال رمز التحقق",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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