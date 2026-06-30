import 'dart:async';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../logic/register_cubit.dart';
import '../../../logic/register_state.dart';

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
  bool _resendSucceeded = false;

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

  /// إعادة إرسال OTP - يستخدم نفس دالة /api/parent/send-otp
  Future<void> _resendOtp() async {
    setState(() {
      _resendLoading = true;
      _resendSucceeded = false;
    });

    try {
      // استدعاء نفس دالة الإيميل (send-otp endpoint)
      final message = await context.read<RegisterCubit>().resendParentOtp(
        widget.email,
      );
      if (!mounted) return;

      setState(() {
        _resendLoading = false;
        _resendSucceeded = true;
        _canResend = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.green),
      );

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => _resendSucceeded = false);
      _startTimer();
    } on ApiException catch (error) {
      _showResendError(error.message);
    } catch (_) {
      _showResendError('فشل إعادة إرسال الرمز، يرجى المحاولة مرة أخرى.');
    }
  }

  void _showResendError(String message) {
    if (!mounted) return;
    setState(() {
      _resendLoading = false;
      _resendSucceeded = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red),
    );
  }

  /// عند اكتمال الـ OTP → إرسال طلب التسجيل النهائي مباشرة
  void _submitRegistration(String otpValue) {
    if (otpValue.length == 6) {
      context.read<RegisterCubit>().registerParent(otpValue);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("الرجاء إدخال الرمز كاملاً المكون من 6 أرقام"),
        ),
      );
    }
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
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? AppColors.white : AppColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<RegisterCubit, RegisterState>(
          listener: (context, state) {
            if (state is ParentRegisterSuccess) {
              // تسجيل ناجح → الانتقال لشاشة الموقع
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.green,
                ),
              );
              Navigator.pushNamed(context, '/parentLocation');
            } else if (state is ParentRegisterError) {
              // خطأ في التسجيل (OTP خاطئ، إيميل مكرر، إلخ)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppColors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is ParentRegisterLoading;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "رمز التحقق",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "تم إرسال كود التحقق المكون من 6 أرقام إلى بريدك الإلكتروني:\n${widget.email}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey,
                    ),
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
                        borderRadius: AppTheme.radius(30),
                        fieldHeight: 50,
                        fieldWidth: 45,
                        activeFillColor: isDark
                            ? AppColors.grey900
                            : AppColors.grey50,
                        inactiveColor: isDark
                            ? AppColors.grey800
                            : AppColors.grey300,
                        selectedColor: theme.primaryColor,
                      ),
                      onChanged: (value) {},
                      // عند اكتمال الـ OTP → إرسال التسجيل مباشرة
                      onCompleted: _submitRegistration,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: _canResend
                        ? _buildResendButton(theme)
                        : Column(
                            children: [
                              Text(
                                "إعادة الإرسال بعد",
                                style: AppTextStyles.style(
                                  color: AppColors.grey600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatTime(_timerSeconds),
                                style: AppTextStyles.style(
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
                    onPressed: isSubmitting
                        ? null
                        : () => _submitRegistration(_otpController.text),
                    style: AppTheme.elevatedButtonStyle(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            "تأكيد وإنشاء الحساب",
                            style: AppTextStyles.style(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
          style: AppTextStyles.style(
            color: AppColors.grey500,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return TextButton(
      onPressed: _resendOtp,
      child: Text(
        "إعادة إرسال رمز التحقق",
        style: AppTextStyles.style(
          color: theme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
