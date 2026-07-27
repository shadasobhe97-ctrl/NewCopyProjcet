import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../data/models/active_subscription_model.dart';

class SubscriptionCard extends StatelessWidget {
  final ActiveSubscriptionModel subscription;
  final VoidCallback onDetailsPressed;
  final VoidCallback onCancelPressed;
  final bool isCancelling;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.onDetailsPressed,
    required this.onCancelPressed,
    required this.isCancelling,
  });

  bool get _isCancellable =>
      subscription.status.toLowerCase() == 'active' ||
      subscription.status.toLowerCase() == 'pending_start';

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw.split('T').first);
      return intl.DateFormat('yyyy/MM/dd').format(dt);
    } catch (_) {
      return raw.split('T').first;
    }
  }

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
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
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
                radius: 26.r,
                backgroundColor: driverAvatarBg,
                backgroundImage: driver.avatarUrl != null && driver.avatarUrl!.isNotEmpty
                    ? NetworkImage(driver.avatarUrl!)
                    : null,
                child: driver.avatarUrl == null || driver.avatarUrl!.isEmpty
                    ? Text(
                        _getInitials(driver.name),
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.bold,
                          color: driverAvatarColor,
                          fontSize: 14.sp,
                        ),
                      )
                    : null,
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
                        fontSize: 15.sp,
                        color: isDark ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'من ${_formatDate(contract.startDate)} إلى ${_formatDate(contract.endDate)}',
                      style: AppTextStyles.style(
                        fontSize: 11.sp,
                        color: isDark ? AppColors.grey500 : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildStatusBadge(subscription),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: isDark ? AppColors.grey800 : AppColors.grey100, height: 1),
          const SizedBox(height: 14),
          Text(
            'اسم الطفل: ${child.name ?? 'بدون اسم'}',
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
              color: isDark ? AppColors.grey300 : AppColors.grey700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (_isCancellable) ...[
                Expanded(
                  child: SizedBox(
                    height: 44.h,
                    child: OutlinedButton.icon(
                      onPressed: isCancelling ? null : onCancelPressed,
                      icon: isCancelling
                          ? SizedBox(
                              width: 16.sp,
                              height: 16.sp,
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.error),
                            )
                          : Icon(Icons.delete_outline_rounded,
                              size: 16.sp, color: AppColors.error),
                      label: Text(
                        'إلغاء الاشتراك',
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.sp,
                          color: AppColors.error,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r)),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: SizedBox(
                  height: 44.h,
                  child: OutlinedButton.icon(
                    onPressed: onDetailsPressed,
                    icon: Icon(
                      Icons.visibility_outlined,
                      size: 16.sp,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(
                      'عرض التفاصيل',
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r)),
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

  Widget _buildStatusBadge(ActiveSubscriptionModel sub) {
    Color color;
    Color bg;
    final text = sub.statusDisplayLabel;

    switch (sub.status.toLowerCase()) {
      case 'active':
        color = AppColors.success;
        bg = AppColors.success.withValues(alpha: 0.08);
        break;
      case 'pending':
      case 'pending_start':
        color = AppColors.pending;
        bg = AppColors.pending.withValues(alpha: 0.08);
        break;
      case 'completed':
        color = AppColors.info;
        bg = AppColors.info.withValues(alpha: 0.08);
        break;
      case 'cancelled':
        color = AppColors.error;
        bg = AppColors.error.withValues(alpha: 0.08);
        break;
      default:
        color = AppColors.grey500;
        bg = AppColors.grey500.withValues(alpha: 0.08);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: AppTextStyles.style(
          color: color,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
