import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';

/// حقل البريد الإلكتروني للملف الشخصي.
///
/// يعرض الإيميل الحالي بشكل قراءة فقط مع أيقونة حالة التحقق.
/// عند الضغط على أيقونة التعديل، يظهر dialog يطلب الإيميل الجديد،
/// ثم يُبلّغ الـ parent عبر [onEmailChangeRequested] لإرساله للباك إند.
class ProfileEmailField extends StatefulWidget {
  /// الإيميل الحالي المعروض
  final String currentEmail;

  /// هل الإيميل محقَّق
  final bool isVerified;

  /// يُستدعى عند طلب تغيير الإيميل بإرسال الإيميل الجديد
  final void Function(String newEmail) onEmailChangeRequested;

  const ProfileEmailField({
    super.key,
    required this.currentEmail,
    required this.isVerified,
    required this.onEmailChangeRequested,
  });

  @override
  State<ProfileEmailField> createState() => _ProfileEmailFieldState();
}

class _ProfileEmailFieldState extends State<ProfileEmailField> {
  void _showChangeEmailDialog() {
    final newEmailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: AppTheme.roundedRectangleBorder(
            borderRadius: AppTheme.radius(20),
          ),
          backgroundColor: Theme.of(dialogContext).cardTheme.color,
          title: Row(
            children: [
              Icon(Icons.email_outlined,
                  color: context.primaryColor, size: 22),
              const SizedBox(width: 8),
              Text(
                'تغيير البريد الإلكتروني',
                style: AppTextStyles.style(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'البريد الحالي:',
                  style: AppTextStyles.style(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.currentEmail.isEmpty
                      ? 'غير محدد'
                      : widget.currentEmail,
                  style: AppTextStyles.style(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'البريد الجديد:',
                  style: AppTextStyles.style(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: newEmailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  style: AppTextStyles.style(fontSize: 14),
                  decoration: AppTheme.inputDecoration(
                    dialogContext,
                    hintText: 'أدخل البريد الجديد',
                    prefixIcon: Icon(
                      Icons.alternate_email_rounded,
                      color: context.primaryColor,
                      size: 20,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'يرجى إدخال البريد الإلكتروني';
                    }
                    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$')
                        .hasMatch(val.trim())) {
                      return 'يرجى إدخال بريد إلكتروني صالح';
                    }
                    if (val.trim() == widget.currentEmail) {
                      return 'البريد الجديد مطابق للحالي';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: AppTheme.boxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.08),
                    borderRadius: AppTheme.radius(10),
                    border: AppTheme.border(
                      color: context.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: context.primaryColor, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'سيُرسَل لك بريد تأكيد للعنوان الجديد.',
                          style: AppTextStyles.style(
                            color: context.primaryColor,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: AppTextStyles.style(color: AppColors.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newEmail = newEmailController.text.trim();
                  Navigator.pop(dialogContext);
                  widget.onEmailChangeRequested(newEmail);
                  _showEmailSentDialog(newEmail);
                }
              },
              style: AppTheme.elevatedButtonStyle(
                backgroundColor: context.primaryColor,
                shape: AppTheme.roundedRectangleBorder(
                  borderRadius: AppTheme.radius(12),
                ),
                minimumSize: const Size(100, 40),
              ),
              child: Text(
                'إرسال التأكيد',
                style: AppTextStyles.style(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) => newEmailController.dispose());
  }

  void _showEmailSentDialog(String newEmail) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: AppTheme.roundedRectangleBorder(
            borderRadius: AppTheme.radius(20),
          ),
          backgroundColor: Theme.of(ctx).cardTheme.color,
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: AppTheme.boxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  color: AppColors.success,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'تم إرسال رسالة التأكيد',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'أُرسلت رسالة إلى:',
                style: AppTextStyles.style(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                newEmail,
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                'تحتوي على رابط تأكيد التغيير.\n'
                '• إذا وافقت على التغيير → سيتم تحديث بريدك تلقائياً.\n'
                '• إذا لم توافق → يبقى بريدك الحالي كما هو.',
                style: AppTextStyles.style(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: AppTheme.elevatedButtonStyle(
                backgroundColor: AppColors.success,
                shape: AppTheme.roundedRectangleBorder(
                  borderRadius: AppTheme.radius(12),
                ),
                minimumSize: const Size(double.infinity, 44),
              ),
              child: Text(
                'حسناً، فهمت',
                style: AppTextStyles.style(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppTheme.boxDecoration(
        color: context.cardSurface,
        borderRadius: AppTheme.radius(14),
        border: AppTheme.border(
          color: widget.isVerified
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.pending.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.email_outlined,
            color: context.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.currentEmail.isEmpty
                      ? 'لم يُحدَّد بعد'
                      : widget.currentEmail,
                  style: AppTextStyles.style(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      widget.isVerified
                          ? Icons.verified_rounded
                          : Icons.watch_later_outlined,
                      size: 12,
                      color: widget.isVerified
                          ? AppColors.success
                          : AppColors.pending,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.isVerified ? 'محقَّق' : 'في انتظار التأكيد',
                      style: AppTextStyles.style(
                        fontSize: 11,
                        color: widget.isVerified
                            ? AppColors.success
                            : AppColors.pending,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── زر التعديل ──
          InkWell(
            onTap: _showChangeEmailDialog,
            borderRadius: AppTheme.radius(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: AppTheme.boxDecoration(
                color: context.primaryColor.withValues(alpha: 0.1),
                borderRadius: AppTheme.radius(10),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 18,
                color: context.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
