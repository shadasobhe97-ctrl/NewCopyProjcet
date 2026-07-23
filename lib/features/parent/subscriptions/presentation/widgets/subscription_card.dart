import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../data/models/active_subscription_model.dart';

class SubscriptionCard extends StatelessWidget {
  final ActiveSubscriptionModel subscription;
  final VoidCallback onDetailsPressed;
  final VoidCallback? onCancelPressed;
  final bool isCancelling;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.onDetailsPressed,
    this.onCancelPressed,
    this.isCancelling = false,
  });

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return parts[0][0];
  }

  bool get _isCancellable =>
      subscription.status.toLowerCase() == 'active' ||
      subscription.status.toLowerCase() == 'pending_start';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final driver = subscription.driver;
    final child = subscription.child;
    final contract = subscription.contract;

    final isFemale = driver.name.contains('ة') ||
        driver.name.contains('فاطمة') ||
        driver.name.contains('مريم');
    final driverAvatarBg = isFemale
        ? AppColors.femalePink.withValues(alpha: 0.1)
        : theme.colorScheme.primary.withValues(alpha: 0.1);
    final driverAvatarColor =
        isFemale ? AppColors.femalePink : theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: driverAvatarBg,
                child: Text(
                  _getInitials(driver.name),
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    color: driverAvatarColor,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                    if (driver.vehicle?.displayName != null &&
                        driver.vehicle!.displayName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        driver.vehicle!.displayName,
                        style: AppTextStyles.style(
                          fontSize: 11,
                          color: isDark ? AppColors.grey400 : AppColors.textMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'من ${contract.startDate.split("T").first} إلى ${contract.endDate.split("T").first}',
                      style: AppTextStyles.style(
                        fontSize: 11,
                        color: isDark ? AppColors.grey500 : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildStatusBadge(subscription.status, isDark),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: isDark ? AppColors.grey800 : AppColors.grey100, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name ?? child.schoolName,
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isDark ? AppColors.grey300 : AppColors.grey700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    child.schoolName,
                    style: AppTextStyles.style(
                      fontSize: 11,
                      color: isDark ? AppColors.grey400 : AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    subscription.formattedPrice,
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'رقم العقد: ${contract.contractNumber}',
                    style: AppTextStyles.style(
                      fontSize: 10,
                      color: isDark ? AppColors.grey500 : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (_isCancellable) ...[
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: isCancelling ? null : onCancelPressed,
                      icon: isCancelling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.error),
                            )
                          : const Icon(Icons.delete_outline_rounded,
                              size: 16, color: AppColors.error),
                      label: Text(
                        'إلغاء الاشتراك',
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.error,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: onDetailsPressed,
                    icon: Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(
                      'عرض التفاصيل',
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isDark) {
    Color color;
    Color bg;
    String text;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'active':
        color = AppColors.success;
        bg = AppColors.success.withValues(alpha: 0.08);
        text = 'نشط';
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'pending_start':
        color = AppColors.pending;
        bg = AppColors.pending.withValues(alpha: 0.08);
        text = 'بانتظار البدء';
        icon = Icons.hourglass_empty_rounded;
        break;
      case 'completed':
        color = AppColors.info;
        bg = AppColors.info.withValues(alpha: 0.08);
        text = 'مكتمل';
        icon = Icons.done_all_rounded;
        break;
      case 'cancelled':
        color = AppColors.grey500;
        bg = AppColors.grey500.withValues(alpha: 0.08);
        text = 'ملغي';
        icon = Icons.block_rounded;
        break;
      default:
        color = AppColors.grey500;
        bg = AppColors.grey500.withValues(alpha: 0.08);
        text = status;
        icon = Icons.help_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.style(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
