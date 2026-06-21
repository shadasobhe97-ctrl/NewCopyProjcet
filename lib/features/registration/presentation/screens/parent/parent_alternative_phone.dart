import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/register_cubit.dart';
import '../../../logic/register_state.dart';

class ParentAlternativePhoneScreen extends StatefulWidget {
  const ParentAlternativePhoneScreen({super.key});

  @override
  State<ParentAlternativePhoneScreen> createState() => _ParentAlternativePhoneScreenState();
}

class _ParentAlternativePhoneScreenState extends State<ParentAlternativePhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _altPhoneController = TextEditingController();

  @override
  void dispose() {
    _altPhoneController.dispose();
    super.dispose();
  }

  void _submitFinalRegistration({bool isSkipped = false}) {
    final cubit = context.read<RegisterCubit>();
    
    // 1. حفظ رقم الهاتف البديل لو تم إدخاله ولم يتم التخطي
    cubit.alternativePhone = isSkipped ? null : _altPhoneController.text.trim();
    
    // 2. إطلاق دالة التسجيل النهائي لريان وتمرير الـ OTP المحفوظ في الـ Cubit مسبقاً
    if (cubit.parentOtpCode != null) {
      cubit.registerParent(cubit.parentOtpCode!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("خطأ: رمز التحقق غير موجود، يرجى إعادة المحاولة.")),
      );
    }
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
        actions: [
          // 🌟 زر تخطي من فوق لإرسال البيانات بدون الهاتف البديل
          TextButton(
            onPressed: () => _submitFinalRegistration(isSkipped: true),
            child: Text(
              "تخطي",
              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is ParentRegisterSuccess) {
              // 🌟 نجاح تسجيل الحساب وتوليد التوكن -> التوجيه لشاشة خريطة OpenStreetMap الحقيقية
              Navigator.pushNamed(context, '/parentLocation');
            } else if (state is ParentRegisterError) {
              // عرض رسالة الخطأ لو الـ OTP منتهي أو الهاتف مكرر
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red),
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
                      "رقم هاتف بديل",
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "يمكنكِ إضافة رقم هاتف احتياطي آخر للاتصال به في حالات الطوارئ (اختياري).",
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 40),

                    // حقل إدخال رقم الهاتف البديل
                    TextFormField(
                      controller: _altPhoneController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left,
                      decoration: const InputDecoration(
                        labelText: "رقم الهاتف البديل",
                        hintText: "09XXXXXXXX",
                        prefixIcon: Icon(Icons.phone_enabled_outlined),
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty && value.trim().length < 7) {
                          return "يجب ألا يقل رقم الهاتف عن 7 أرقام";
                        }
                        return null;
                      },
                    ),
                    
                    const Spacer(),

                    // زر إرسال البيانات وإتمام التسجيل بالـ Loading
                    ElevatedButton(
                      onPressed: state is ParentRegisterLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _submitFinalRegistration(isSkipped: false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state is ParentRegisterLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              "إنشاء الحساب",
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