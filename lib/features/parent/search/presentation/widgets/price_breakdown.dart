import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class PriceBreakdown extends StatelessWidget {
  final double totalPrice;
  final List<Map<String, dynamic>> childPricingList;
  final VoidCallback onSendPressed;
  final bool isButtonEnabled;
  final String buttonText;

  const PriceBreakdown({
    super.key,
    required this.totalPrice,
    required this.childPricingList,
    required this.onSendPressed,
    this.isButtonEnabled = true,
    this.buttonText = 'إرسال طلب الاشتراك',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الإجمالي الكلي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السعر الإجمالي الكلي',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                '${totalPrice.toStringAsFixed(2)} د.ل',
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // الفاصل الأول
          Divider(color: isDark ? AppColors.grey800 : AppColors.grey200, thickness: 1),
          const SizedBox(height: 12),

          // تفاصيل السعر لكل طفل
          Text(
            'تفاصيل السعر لكل طفل:',
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? AppColors.grey300 : AppColors.grey600,
            ),
          ),
          const SizedBox(height: 10),
          ...childPricingList.map((item) {
            final name = item['name'] as String;
            final subText = item['subText'] as String;
            final price = item['price'] as double;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$name ($subText)',
                    style: AppTextStyles.style(
                      fontSize: 13,
                      color: isDark ? AppColors.grey300 : AppColors.grey800,
                    ),
                  ),
                  Text(
                    '${price.toStringAsFixed(2)} د.ل',
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: isDark ? AppColors.white : AppColors.textDark,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),

          // الفاصل الثاني
          Divider(color: isDark ? AppColors.grey800 : AppColors.grey200, thickness: 1),
          const SizedBox(height: 16),

          // زر إرسال الطلب
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isButtonEnabled ? onSendPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                disabledBackgroundColor: isDark ? AppColors.grey800 : AppColors.grey200,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                buttonText,
                style: AppTextStyles.style(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isButtonEnabled 
                      ? theme.colorScheme.onPrimary 
                      : (isDark ? AppColors.grey600 : AppColors.grey400),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
