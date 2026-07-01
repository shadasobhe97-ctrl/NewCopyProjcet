import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// بطاقة موحّدة عامة مع ظل وزوايا دائرية.
/// تُستخدم لعرض محتوى هيكلي في أي شاشة.
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.color,
    this.borderColor,
    this.borderWidth = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? (isDark ? AppColors.darkCard : AppColors.white);

    final decorated = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: AppTheme.boxDecoration(
        color: cardColor,
        borderRadius: AppTheme.radius(borderRadius),
        border:
            borderColor != null
                ? AppTheme.border(color: borderColor!, width: borderWidth)
                : null,
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppTheme.radius(borderRadius),
        child: decorated,
      );
    }
    return decorated;
  }
}

/// صف معلومات بأيقونة + تسمية + قيمة — يُستخدم في شاشات التفاصيل.
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: AppTextStyles.style(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.style(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
