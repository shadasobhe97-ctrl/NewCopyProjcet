import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:kids_transport/features/registration/logic/register_cubit.dart';
import 'package:kids_transport/features/registration/logic/register_state.dart';

class ParentOtpScreen extends StatefulWidget {
  final String email;

  const ParentOtpScreen({super.key, required this.email});

  @override
  State<ParentOtpScreen> createState() => _ParentOtpScreenState();
}

class _ParentOtpScreenState extends State<ParentOtpScreen> {
  final _otpController = TextEditingController();
  int _timerSeconds = 600; // 10 دقائق
  Timer? _timer;
  bool _canResend = false;
  bool _resendLoading = false;
  bool _resendSucceeded = false; // يتحول لرمادي بعد نجاح الإرسال

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _timerSeconds = 600;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
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

  Future<void> _resendOtp() async {
    setState(() {
      _resendLoading = true;
      _resendSucceeded = false;
    });

    await context.read<RegisterCubit>().resendParentOtp(widget.email);

    if (!mounted) return;

    setState(() {
      _resendLoading = false;
      _resendSucceeded = true; // تحول الزر لرمادي = نجح الإرسال
      _canResend = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم إعادة إرسال رمز التحقق إلى بريدك الإلكتروني."),
        backgroundColor: Colors.green,
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _resendSucceeded = false;
    });
    _startTimer();
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

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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

              Directionality(
                textDirection: TextDirection.ltr,
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _otpController,
                  autoFocus: true,
                  autoDisposeControllers: false,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.slide,
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
                    context.read<RegisterCubit>().parentOtpCode = int.tryParse(value);
                    Navigator.pushNamed(context, '/parentBasicInfo');
                  },
                ),
              ),
              const SizedBox(height: 24),

              // صف إعادة الإرسال
              Center(
                child: _canResend
                    ? _buildResendButton(theme)
                    : Column(
                        children: [
                          Text(
                            "إعادة الإرسال بعد",
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(_timerSeconds),
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () {
                  if (_otpController.text.length == 6) {
                    context.read<RegisterCubit>().parentOtpCode = int.tryParse(_otpController.text);
                    Navigator.pushNamed(context, '/parentBasicInfo');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("الرجاء إدخال الرمز كاملاً المكون من 6 أرقام")),
                    );
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

  Widget _buildResendButton(ThemeData theme) {
    if (_resendLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_resendSucceeded) {
      return TextButton(
        onPressed: null,
        child: Text(
          "تم إرسال الرمز ✓",
          style: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return TextButton(
      onPressed: _resendOtp,
      child: Text(
        "إعادة إرسال رمز التحقق",
        style: TextStyle(
          color: theme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}