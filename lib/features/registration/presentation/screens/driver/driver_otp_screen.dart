import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../logic/register_cubit.dart';
import '../../../logic/register_state.dart';

class DriverOtpScreen extends StatefulWidget {
  const DriverOtpScreen({super.key});

  @override
  State<DriverOtpScreen> createState() => _DriverOtpScreenState();
}

class _DriverOtpScreenState extends State<DriverOtpScreen> {
  final _otpController = TextEditingController();
  int _timerSeconds = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        setState(() {
          _canResend = true;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    final cubit = context.read<RegisterCubit>();

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
            if (state is DriverVerifyOtpSuccess) {
              // 🌟 عند نجاح التحقق، نتوجه فوراً للمرحلة التالية: البيانات الشخصية والوثائق
              Navigator.pushNamed(context, '/driverNationalInfo');
            } else if (state is DriverVerifyOtpError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "رمز التحقق",
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "تم إرسال كود التحقق المكون من 6 أرقام إلى بريدك الإلكتروني:\n${cubit.email ?? ''}",
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 40),

                  // حقل إدخال الرموز المنسق بنفس تصميم الأب بالظبط
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: _otpController,
                      autoFocus: true,
                      autoDisposeControllers: false,
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
                          cubit.verifyDriverOtp(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🌟 الجزء الخاص بالمؤقت التنازلي وإعادة إرسال الرمز
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _canResend
                          ? TextButton(
                              onPressed: () {
                                _startTimer();
                                cubit.resendOtp(cubit.email ?? '');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("تم إعادة إرسال رمز التحقق.")),
                                );
                              },
                              child: Text(
                                "إعادة ارسال رمز التحقق",
                                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                              ),
                            )
                          : Text(
                              "إعادة الإرسال خلال $_timerSeconds ثانية",
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // زر التأكيد اليدوي
                  ElevatedButton(
                    onPressed: state is DriverVerifyOtpLoading
                        ? null
                        : () {
                            if (_otpController.text.length == 6) {
                              cubit.verifyDriverOtp(_otpController.text);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("الرجاء إدخال الرمز كاملاً المكون من 6 أرقام")),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state is DriverVerifyOtpLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            "تأكيد الرمز",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}