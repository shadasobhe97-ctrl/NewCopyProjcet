import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/utils/theme_context.dart';

class EmailVerificationDialog extends StatefulWidget {
  final Future<void> Function() onCancel;
  final Future<void> Function() onCheckStatus;

  const EmailVerificationDialog({
    super.key,
    required this.onCancel,
    required this.onCheckStatus,
  });

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function() onCancel,
    required Future<void> Function() onCheckStatus,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EmailVerificationDialog(
        onCancel: onCancel,
        onCheckStatus: onCheckStatus,
      ),
    );
  }

  @override
  State<EmailVerificationDialog> createState() => _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  bool _isCancelling = false;
  bool _isChecking = false;

  Future<void> _handleCancel() async {
    if (_isCancelling || _isChecking) return;
    setState(() {
      _isCancelling = true;
    });

    try {
      await widget.onCancel();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isCancelling = false;
      });
    }
  }

  Future<void> _handleCheckStatus() async {
    if (_isCancelling || _isChecking) return;
    setState(() {
      _isChecking = true;
    });

    try {
      await widget.onCheckStatus();
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.mark_email_read_outlined, color: context.primaryColor),
              const SizedBox(width: 8),
              const Text('تأكيد البريد الإلكتروني'),
            ],
          ),
          content: const Text(
            'تم إرسال رابط تأكيد إلى بريدك الإلكتروني الجديد.\nيرجى فتح البريد والموافقة على تعديل الحساب.',
            style: TextStyle(height: 1.5, fontSize: 14),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: (_isCancelling || _isChecking) ? null : _handleCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.errorColor,
                      side: BorderSide(color: context.errorColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isCancelling
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.errorColor,
                              ),
                            ),
                          )
                        : const Text(
                            'إلغاء التعديل',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_isCancelling || _isChecking) ? null : _handleCheckStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isChecking
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'تم التعديل',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
