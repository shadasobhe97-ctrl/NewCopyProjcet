import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// زر رئيسي موحّد يُستخدم عبر التطبيق بالكامل.
/// يدعم حالة التحميل، وأيقونة اختيارية، وتخصيص كامل للألوان.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double fontSize;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor = AppColors.primaryLight,
    this.foregroundColor = AppColors.white,
    this.padding = const EdgeInsets.symmetric(vertical: 16),
    this.borderRadius = 16,
    this.fontSize = 16,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: AppTheme.elevatedButtonStyle(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: padding,
        shape: AppTheme.roundedRectangleBorder(
          borderRadius: AppTheme.radius(borderRadius),
        ),
        elevation: 2,
      ),
      child: isLoading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: foregroundColor,
                strokeWidth: 2.5,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: icon != null ? MainAxisSize.min : MainAxisSize.max,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: AppTextStyles.style(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: foregroundColor,
                  ),
                ),
              ],
            ),
    );

    if (width != null) {
      return SizedBox(width: width, child: btn);
    }
    return btn;
  }
}
