import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class AppDrawerItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final String? badge;
  final VoidCallback onTap;

  const AppDrawerItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final pendingColor = AppColors.pending;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: AppTheme.boxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: AppTheme.radius(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.style(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: AppTheme.boxDecoration(
                color: pendingColor.withValues(alpha: 0.15),
                borderRadius: AppTheme.radius(20),
              ),
              child: Text(
                badge!,
                style: AppTextStyles.style(
                  fontSize: 10,
                  color: pendingColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: Icon(
        Icons.chevron_left_rounded,
        color: AppColors.textMuted,
        size: 20,
      ),
      onTap: onTap,
      shape: AppTheme.roundedRectangleBorder(borderRadius: AppTheme.radius(12)),
    );
  }
}
