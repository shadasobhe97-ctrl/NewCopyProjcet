import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class SharedOtpForm extends StatefulWidget {
  /// النص أو البريد الذي يتم عرض رسالة "تم إرسال الرمز إلى..." له.
  final String identifier;

  /// يتم استدعاؤها عندما يكتمل إدخال الـ 6 أرقام.
  final void Function(String code) onCompleted;

  /// يتم استدعاؤها عند الضغط على زر إعادة الإرسال.
  final Future<void> Function() onResend;

  /// يتم استدعاؤها عند الضغط على الزر الرئيسي.
  final void Function(String code) onSubmit;

  /// عنوان الزر الرئيسي أسفل الشاشة.
  final String submitButtonText;

  /// حالة التحميل للزر الرئيسي.
  final bool isSubmitting;

  /// لتفعيل حالة نجاح إعادة الإرسال من خارج المكون.
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

  int _expirySeconds = 300; // 5 دقائق صلاحية الرمز
  int _cooldownSeconds = 60; // 60 ثانية مهلة إعادة الإرسال
  int _resendCount = 0; // عدد محاولات إعادة الإرسال (حتى 3 محاولات)
  static const int _maxResendAttempts = 3;

  Timer? _expiryTimer;
  Timer? _cooldownTimer;

  bool _resendLoading = false;
  bool _resendSucceeded = false;

  @override
  void initState() {
    super.initState();
    _startTimers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _otpFocusNode.requestFocus();
        }
      });
    });
  }

  @override
  void didUpdateWidget(covariant SharedOtpForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.externalResendSuccess && !oldWidget.externalResendSuccess) {
      _handleResendSuccess();
    }
  }

  void _startTimers() {
    _startExpiryTimer();
    _startCooldownTimer();
  }

  void _startExpiryTimer() {
    _expiryTimer?.cancel();
    setState(() => _expirySeconds = 300);
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_expirySeconds > 0) {
        setState(() => _expirySeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds > 0) {
        setState(() => _cooldownSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleResend() async {
    if (_resendCount >= _maxResendAttempts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم استنفاذ الحد الأقصى لمحاولات إعادة الإرسال (3 محاولات).',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _resendLoading = true;
      _resendSucceeded = false;
    });

    try {
      await widget.onResend();
      if (!mounted) return;
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
      _resendCount++;
      _resendLoading = false;
      _resendSucceeded = true;
    });

    _startTimers();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _resendSucceeded = false);
    });
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    _cooldownTimer?.cancel();
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
          const SizedBox(height: 20),

          // ── شريط التوقيت وصلاحية الرمز (5 دقائق) ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: _expirySeconds > 0
                        ? theme.primaryColor
                        : AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _expirySeconds > 0
                        ? "ينتهي الرمز خلال: ${_formatTime(_expirySeconds)}"
                        : "انتهت صلاحية الرمز!",
                    style: AppTextStyles.style(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _expirySeconds > 0
                          ? theme.primaryColor
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
              if (_resendCount > 0)
                Text(
                  "المحاولات: $_resendCount/$_maxResendAttempts",
                  style: AppTextStyles.style(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

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
                inactiveFillColor: isDark
                    ? AppColors.grey900
                    : AppColors.grey100,
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
            child: _resendCount >= _maxResendAttempts
                ? Text(
                    "تم استنفاذ الحد الأقصى لمحاولات إعادة الإرسال (3/3)",
                    style: AppTextStyles.style(
                      color: AppColors.error,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : (_cooldownSeconds == 0
                      ? _buildResendButton(theme)
                      : Column(
                          children: [
                            Text(
                              "يمكنك طلب رمز جديد بعد",
                              style: AppTextStyles.style(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "00:${_cooldownSeconds.toString().padLeft(2, '0')}",
                              style: AppTextStyles.style(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        )),
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
                          content: Text(
                            "الرجاء إدخال الرمز كاملاً المكون من 6 أرقام",
                          ),
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
        "إعادة إرسال رمز التحقق (المحاولة ${_resendCount + 1} من $_maxResendAttempts)",
        style: AppTextStyles.style(
          color: theme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
