import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';

/// حقل البريد الإلكتروني للملف الشخصي.
///
/// حقل عادي (TextFormField) داخل نفس الفورم — بدون أي Dialog.
/// يعرض حالة التحقق (محقَّق / بانتظار تأكيد) تحت الحقل مباشرة.
/// عند الضغط على "حفظ التغييرات" في الشاشة الرئيسية، لو القيمة اتغيرت
/// عن الإيميل الأصلي، تُرسل مع باقي الحقول لنفس Endpoint التحديث،
/// والباك إند هو من يقرر إرسال رابط التأكيد للإيميل الجديد.
class ProfileEmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isVerified;

  const ProfileEmailField({
    super.key,
    required this.controller,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: AppTheme.inputDecoration(
            context,
            hintText: 'أدخل بريدك الإلكتروني',
            prefixIcon: Icon(Icons.email_outlined, color: context.primaryColor),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'يرجى إدخال البريد الإلكتروني';
            }
            if (!RegExp(
              r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
            ).hasMatch(val.trim())) {
              return 'يرجى إدخال بريد إلكتروني صالح';
            }
            return null;
          },
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              isVerified ? Icons.verified_rounded : Icons.watch_later_outlined,
              size: 13,
              color: isVerified ? AppColors.success : AppColors.pending,
            ),
            const SizedBox(width: 4),
            Text(
              isVerified ? 'محقَّق' : 'بانتظار تأكيد آخر تغيير',
              style: AppTextStyles.style(
                fontSize: 11,
                color: isVerified ? AppColors.success : AppColors.pending,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
