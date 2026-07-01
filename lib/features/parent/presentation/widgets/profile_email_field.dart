import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';

/// حقل البريد الإلكتروني مع زر التحقق وحوار OTP.
class ProfileEmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isVerified;
  final bool showVerifyButton;
  final void Function(String verifiedEmail) onVerified;

  const ProfileEmailField({
    super.key,
    required this.controller,
    required this.isVerified,
    required this.showVerifyButton,
    required this.onVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: AppTheme.inputDecoration(
              context,
              hintText: 'أدخل البريد الإلكتروني',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: context.primaryColor,
              ),
            ).copyWith(
              suffixIcon: isVerified
                  ? const Icon(
                      Icons.verified_rounded,
                      color: AppColors.success,
                    )
                  : const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.pending,
                    ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'يرجى إدخال البريد الإلكتروني';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(val)) {
                return 'يرجى إدخال بريد إلكتروني صالح';
              }
              return null;
            },
          ),
        ),
        if (showVerifyButton) ...[
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: ElevatedButton(
              onPressed: () => _showVerificationDialog(context),
              style: AppTheme.elevatedButtonStyle(
                backgroundColor: AppColors.pending,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                minimumSize: Size.zero,
                shape: AppTheme.roundedRectangleBorder(
                  borderRadius: AppTheme.radius(30),
                ),
              ),
              child: Text(
                'تحقق',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showVerificationDialog(BuildContext context) {
    final codeControllers = List.generate(4, (_) => TextEditingController());
    final focusNodes = List.generate(4, (_) => FocusNode());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: AppTheme.roundedRectangleBorder(
            borderRadius: AppTheme.radius(20),
          ),
          backgroundColor: Theme.of(dialogContext).cardTheme.color,
          title: Text(
            'التحقق من البريد الإلكتروني',
            style: AppTextStyles.style(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تم إرسال رمز التحقق المكون من 4 أرقام إلى بريدك الجديد:\n${controller.text}',
                textAlign: TextAlign.center,
                style: AppTextStyles.style(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextFormField(
                      controller: codeControllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: AppTextStyles.style(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: AppTheme.inputDecoration(
                        dialogContext,
                        counterText: '',
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لم يصلك الرمز؟ ',
                    style: AppTextStyles.style(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'إعادة إرسال',
                      style: AppTextStyles.style(
                        color: AppColors.primaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: AppTextStyles.style(color: AppColors.error),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onVerified(controller.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم التحقق من البريد بنجاح!'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: AppTheme.elevatedButtonStyle(
                backgroundColor: AppColors.primaryLight,
                shape: AppTheme.roundedRectangleBorder(
                  borderRadius: AppTheme.radius(12),
                ),
                minimumSize: const Size(100, 40),
              ),
              child: Text(
                'تأكيد',
                style: AppTextStyles.style(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      for (var c in codeControllers) c.dispose();
      for (var f in focusNodes) f.dispose();
    });
  }
}
