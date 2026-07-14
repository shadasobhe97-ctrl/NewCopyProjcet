import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class SharedOtpForm extends StatefulWidget {
  /// النص أو الرقم الذي يتم عرض رسالة "تم إرسال الرمز إلى..." له.
  final String identifier;
  
  /// يتم استدعاؤها عندما يكتمل إدخال الـ 6 أرقام.
  final void Function(String code) onCompleted;
  
  /// يتم استدعاؤها عند الضغط على زر إعادة الإرسال. يجب أن تكون دالة غير متزامنة (Future).
  final Future<void> Function() onResend;
  
  /// يتم استدعاؤها عند الضغط على الزر الرئيسي (تأكيد / إنشاء حساب / إلخ).
  final void Function(String code) onSubmit;
  
  /// عنوان الزر الرئيسي أسفل الشاشة.
  final String submitButtonText;
  
  /// حالة التحميل للزر الرئيسي.
  final bool isSubmitting;
  
  /// لتفعيل حالة نجاح إعادة الإرسال من خارج المكون (لو كان مطلوباً، لكن غالباً نعالجه داخلياً).
  final bool externalResendSuccess;

  const SharedOtpForm({
    super.key,
    required this.identifier,
    required this.onCompleted,
    required this.onResend,
    required this.onSubmit,
    required this.submitButtonText,
    this.isSubmitting = false,
    this.externalResendSuccess = false,
  });

  @override
  State<SharedOtpForm> createState() => _SharedOtpFormState();
}

class _SharedOtpFormState extends State<SharedOtpForm> {
  final _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  int _timerSeconds = 600; // 10 دقائق
  Timer? _timer;
  bool _canResend = false;
  bool _resendLoading = false;
  bool _resendSucceeded = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _otpFocusNode.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(covariant SharedOtpForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.externalResendSuccess && !oldWidget.externalResendSuccess) {
      _handleResendSuccess();
    }
  }

  void _startTimer() {
    if (!mounted) return;
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
        setState(() => _timerSeconds--);
      }
    });
  }

  Future<void> _handleResend() async {
    setState(() {
      _resendLoading = true;
      _resendSucceeded = false;
    });

    try {
      await widget.onResend();
      _handleResendSuccess();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _resendLoading = false;
      });
    }
  }

  void _handleResendSuccess() {
    if (!mounted) return;
    setState(() {
      _resendLoading = false;
      _resendSucceeded = true;
      _canResend = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _resendSucceeded = false);
      _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
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
            "تم إرسال كود التحقق المكون من 6 أرقام إلى:\n${widget.identifier}",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
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
              focusNode: _otpFocusNode,
              autoFocus: true,
              autoDisposeControllers: false,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: AppTheme.radius(12),
                fieldHeight: 54,
                fieldWidth: 44,
                activeFillColor: isDark ? AppColors.grey900 : AppColors.white,
                inactiveFillColor: isDark ? AppColors.grey900 : AppColors.grey100,
                selectedFillColor: isDark ? AppColors.grey900 : AppColors.white,
                activeColor: theme.primaryColor,
                selectedColor: theme.primaryColor,
                inactiveColor: isDark ? AppColors.grey700 : AppColors.grey300,
              ),
              textStyle: AppTextStyles.style(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.black87,
              ),
              cursorColor: theme.primaryColor,
              enableActiveFill: true,
              onChanged: (_) {},
              onCompleted: widget.onCompleted,
            ),
          ),
          const SizedBox(height: 30),

          Center(
            child: _canResend
                ? _buildResendButton(theme)
                : Column(
                    children: [
                      Text(
                        "إعادة الإرسال بعد",
                        style: AppTextStyles.style(
                          color: AppColors.textMuted,
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
            onPressed: widget.isSubmitting
                ? null
                : () {
                    if (_otpController.text.length == 6) {
                      widget.onSubmit(_otpController.text);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("الرجاء إدخال الرمز كاملاً المكون من 6 أرقام"),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
            style: AppTheme.elevatedButtonStyle(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: widget.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    widget.submitButtonText,
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
  }

  Widget _buildResendButton(ThemeData theme) {
    if (_resendLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (_resendSucceeded || widget.externalResendSuccess) {
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
      onPressed: _handleResend,
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
