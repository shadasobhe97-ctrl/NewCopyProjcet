import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_colors.dart';

class CustomAuthButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const CustomAuthButton({
    super.key,
    required this.text,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // يخيل الزر ممتد بكامل العرض المتناسق للشاشة
      height: 52.h, // ارتفاع متجاوب ومريح للضغط تجارياً
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton(
              onPressed: onPressed,
              child: Text(
                text,
                style: AppTextStyles.button(color: AppColors.white),
              ),
            ),
    );
  }
}
