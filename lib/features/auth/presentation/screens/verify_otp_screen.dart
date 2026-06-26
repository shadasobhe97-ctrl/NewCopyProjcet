import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/auth/logic/auth_cubit.dart';
import 'package:kids_transport/features/auth/logic/auth_state.dart';
import 'package:kids_transport/features/auth/presentation/widgets/auth_header_section.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _startSeconds = 600; // 10 دقائق
  bool _isButtonDisabled = true;
  bool _resendLoading = false;
  bool _resendSucceeded = false; // يتحول لرمادي بعد نجاح الإرسال

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (!mounted) return;
    setState(() {
      _startSeconds = 600;
      _isButtonDisabled = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_startSeconds == 0) {
        setState(() {
          _timer?.cancel();
          _isButtonDisabled = false;
        });
      } else {
        setState(() => _startSeconds--);
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _resendCode() async {
    setState(() {
      _resendLoading = true;
      _resendSucceeded = false;
    });
    context.read<AuthCubit>().sendOtp(email: widget.email);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _resendLoading = false;
      _resendSucceeded = true;
      _isButtonDisabled = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _resendSucceeded = false);
    _startTimer();
  }

  void _openResetPassword(String code) {
    _timer?.cancel();
    Navigator.pushNamed(
      context,
      AppRoutes.resetPassword,
      arguments: {'email': widget.email, 'otpCode': code},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      ),
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is OtpSentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is PasswordOtpVerifiedSuccess) {
              _openResetPassword(state.code);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthHeaderSection(
                    title: 'رمز التحقق (OTP)',
                    subtitle:
                        'أدخل الرمز المكون من 6 أرقام المرسل إلى:\n${widget.email}',
                  ),
                  SizedBox(height: 20.h),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: PinCodeTextField(
                      appContext: context,
                      length: 6,
                      autoDisposeControllers: false,
                      autoFocus: true,
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.fade,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(12.r),
                        fieldHeight: 54.h,
                        fieldWidth: 44.w,
                        activeFillColor:
                            isDark ? AppColors.surfaceDark : Colors.white,
                        inactiveFillColor: isDark
                            ? AppColors.surfaceDark
                            : Colors.grey.shade100,
                        selectedFillColor:
                            isDark ? AppColors.surfaceDark : Colors.white,
                        activeColor: isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                        selectedColor: isDark
                            ? AppColors.primaryDark
                            : AppColors.primaryLight,
                        inactiveColor: isDark
                            ? Colors.grey.shade700
                            : Colors.grey.shade300,
                      ),
                      textStyle: AppTextStyles.heading(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      cursorColor:
                          isDark ? AppColors.primaryDark : AppColors.primaryLight,
                      enableActiveFill: true,
                      onChanged: (_) {},
                      onCompleted: (code) {
                        context.read<AuthCubit>().verifyOtp(email: widget.email, code: code);
                      },
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Center(
                    child: Column(
                      children: [
                        if (_isButtonDisabled && !_resendSucceeded)
                          Column(
                            children: [
                              Text(
                                'إعادة الإرسال بعد',
                                style: AppTextStyles.body(color: AppColors.textMuted),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                _formatTime(_startSeconds),
                                style: AppTextStyles.body(
                                  color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                                ).copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          )
                        else
                          TextButton(
                            onPressed: (_resendLoading || _resendSucceeded) ? null : _resendCode,
                            child: _resendLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(
                                    _resendSucceeded ? 'تم إرسال الرمز ✓' : 'إعادة إرسال الرمز',
                                    style: AppTextStyles.body(
                                      color: _resendSucceeded
                                          ? Colors.grey
                                          : (isDark ? AppColors.primaryDark : AppColors.primaryLight),
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
