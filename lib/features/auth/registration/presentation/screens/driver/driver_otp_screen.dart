import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../logic/register_cubit.dart';
import '../../../logic/register_state.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

class DriverOtpScreen extends StatefulWidget {
  const DriverOtpScreen({super.key});

  @override
  State<DriverOtpScreen> createState() => _DriverOtpScreenState();
}

class _DriverOtpScreenState extends State<DriverOtpScreen> {
  final _otpController = TextEditingController();
  int _timerSeconds = 600; // 10 دقائق
  Timer? _timer;
  bool _canResend = false;
  bool _resendLoading = false; // لتتبع حالة الإرسال
  bool _resendSucceeded = false; // يتغير لون الزر بعد النجاح

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
    final cubit = context.read<RegisterCubit>();
    setState(() {
      _resendLoading = true;
      _resendSucceeded = false;
    });

    try {
      final message = await cubit.resendOtp(cubit.email ?? '');

      if (!mounted) return;

      setState(() {
        _resendLoading = false;
        _resendSucceeded = true; // يتحول لرمادي = نجح الإرسال
        _canResend = false; // نخفي الزر مؤقتاً ونبدأ التايمر
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.green),
      );

      // إعادة بدء التايمر بعد 2 ثانية
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        _resendSucceeded = false;
      });
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
    final cubit = context.read<RegisterCubit>();

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
            if (state is DriverVerifyOtpSuccess) {
              Navigator.pushNamed(context, '/driverNationalInfo');
            } else if (state is DriverVerifyOtpError) {
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
                    "تم إرسال كود التحقق المكون من 6 أرقام إلى رقم هاتفك:\n${cubit.phoneNumber ?? ''}",
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
                      onCompleted: (value) {
                        if (value.length == 6) {
                          cubit.verifyDriverOtp(value);
                        }
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
                    onPressed: state is DriverVerifyOtpLoading
                        ? null
                        : () {
                            if (_otpController.text.length == 6) {
                              cubit.verifyDriverOtp(_otpController.text);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "الرجاء إدخال الرمز كاملاً المكون من 6 أرقام",
                                  ),
                                ),
                              );
                            }
                          },
                    style: AppTheme.elevatedButtonStyle(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: state is DriverVerifyOtpLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            "تأكيد الرمز",
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

    // بعد نجاح الإرسال يتحول الزر لرمادي مؤقتاً
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

    // الحالة الافتراضية: زر أزرق قابل للضغط
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
