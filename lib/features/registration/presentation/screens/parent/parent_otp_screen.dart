import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart'; // حقل الرموز المعتمد عندكِ
import '../../../logic/register_cubit.dart';

class ParentOtpScreen extends StatefulWidget {
  final String email; // تستقبل الإيميل الممرر عبر الـ arguments

  const ParentOtpScreen({super.key, required this.email});

  @override
  State<ParentOtpScreen> createState() => _ParentOtpScreenState();
}

class _ParentOtpScreenState extends State<ParentOtpScreen> {
  final _otpController = TextEditingController();

  @override
  void dispose() {
    // الحماية الذهبية اللي اتفقنا عليها لمنع كراش الـ Controller الميت
    try {
      _otpController.text = '';
    } catch (_) {}
    _otpController.dispose();
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // الهيدر المعتمد
              Text(
                "رمز التحقق",
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              Text(
                "تم إرسال كود التحقق المكون من 6 أرقام إلى بريدك الإلكتروني:\n${widget.email}",
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 40),

              // حقل إدخال الرموز المنسق
              Directionality(
                textDirection: TextDirection.rtl,
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _otpController,
                  autoFocus: true,
                  autoDisposeControllers: false, // 🌟 الحماية لمنع الكراش تلقائياً
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(30),
                    fieldHeight: 50,
                    fieldWidth: 45,
                    activeFillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                    inactiveColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                    selectedColor: theme.primaryColor,
                  ),
                  onChanged: (value) {},
                  onCompleted: (value) {
                    if (value.length == 6) {
                      // 1. حفظ كود التحقق مؤقتاً في الكيوبت
                      context.read<RegisterCubit>().parentOtpCode = int.tryParse(value);
                      
                      // 2. التوجيه لشاشة البيانات الأساسية الكبرى للأب
                      Navigator.pushNamed(context, '/parentBasicInfo');
                    }
                  },
                ),
              ),
              
              const Spacer(),
              
              // زر التأكيد اليدوي كبديل للاكتمال التلقائي
              ElevatedButton(
                onPressed: () {
                  if (_otpController.text.length == 6) {
                    context.read<RegisterCubit>().parentOtpCode = int.tryParse(_otpController.text);
                    Navigator.pushNamed(context, '/parentBasicInfo');
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "تأكيد الرمز",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}