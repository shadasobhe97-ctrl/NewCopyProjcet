import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../data/models/subscription_model.dart';

class SubscriptionCard extends StatelessWidget {
  final SubscriptionModel subscription;
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

  String _getSubscriptionTypeArabic(String type) {
    switch (type.toLowerCase()) {
      case 'weekly':
        return 'طلب اشتراك أسبوعي';
      case 'daily':
        return 'طلب اشتراك يومي';
      case 'monthly':
      default:
        return 'طلب اشتراك شهري';
    }
  }

  String _getSubscriptionTypeArabicActive(String type) {
    switch (type.toLowerCase()) {
      case 'weekly':
        return 'اشتراك أسبوعي';
      case 'daily':
        return 'اشتراك يومي';
      case 'monthly':
      default:
        return 'اشتراك شهري';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPending = subscription.status.toLowerCase() == 'pending';
    final isActive = subscription.status.toLowerCase() == 'accepted' || subscription.status.toLowerCase() == 'active';

    final isFemale = subscription.driver.name.contains('ة') || 
                     subscription.driver.name.contains('فاطمة') || 
                     subscription.driver.name.contains('مريم');
    final driverAvatarBg = isFemale 
        ? AppColors.femalePink.withValues(alpha: 0.1) 
        : theme.colorScheme.primary.withValues(alpha: 0.1);
    final driverAvatarColor = isFemale ? AppColors.femalePink : theme.colorScheme.primary;

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
          // الجزء العلوي: بيانات السائق والحالة والتاريخ
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. صورة السائق (على اليمين في RTL)
              CircleAvatar(
                radius: 26,
                backgroundColor: driverAvatarBg,
                child: Text(
                  _getInitials(subscription.driver.name),
                  style: AppTextStyles.style(
                    fontWeight: FontWeight.bold,
                    color: driverAvatarColor,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 2. تفاصيل السائق (في المنتصف)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.driver.name,
                      style: AppTextStyles.style(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isActive 
                          ? _getSubscriptionTypeArabicActive(subscription.subscriptionType)
                          : _getSubscriptionTypeArabic(subscription.subscriptionType),
                      style: AppTextStyles.style(
                        fontSize: 12,
                        color: isDark ? AppColors.grey400 : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPending
                          ? 'تاريخ الطلب: ${subscription.createdAt}'
                          : 'من ${subscription.startDate.split("T").first} إلى ${subscription.endDate.split("T").first}',
                      style: AppTextStyles.style(
                        fontSize: 11,
                        color: isDark ? AppColors.grey500 : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 3. شارة الحالة (على اليسار في RTL)
              _buildStatusBadge(subscription.status, isDark),
            ],
          ),
          
          const SizedBox(height: 16),
          Divider(color: isDark ? AppColors.grey800 : AppColors.grey100, height: 1),
          const SizedBox(height: 14),

          // الجزء الأوسط: قسم الأطفال
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. عدد وأسماء الأطفال (على اليمين في RTL)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الأطفال (${subscription.childrenCount})',
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isDark ? AppColors.grey300 : AppColors.grey700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subscription.children.map((c) => c.name.split(' ')[0]).join('، '),
                    style: AppTextStyles.style(
                      fontSize: 12,
                      color: isDark ? AppColors.grey400 : AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              // 2. صور الأطفال بشكل دائري متراكب (على اليسار في RTL)
              _buildChildrenAvatars(subscription.children, isDark),
            ],
          ),
          const SizedBox(height: 16),

          // الجزء السفلي: أزرار التحكم
          Row(
            children: [
              if (isPending) ...[
                // زر إلغاء الطلب (أحمر مفرغ)
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: isCancelling ? null : onCancelPressed,
                      icon: isCancelling 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error),
                            )
                          : const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                      label: Text(
                        'إلغاء الطلب',
                        style: AppTextStyles.style(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.error,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              
              // زر عرض التفاصيل
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
      case 'accepted':
      case 'active':
        color = AppColors.success;
        bg = AppColors.success.withValues(alpha: 0.08);
        text = 'مقبول';
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'rejected':
        color = AppColors.error;
        bg = AppColors.error.withValues(alpha: 0.08);
        text = 'مرفوض';
        icon = Icons.cancel_outlined;
        break;
      case 'pending':
      default:
        color = AppColors.pending;
        bg = AppColors.pending.withValues(alpha: 0.08);
        text = 'معلق';
        icon = Icons.hourglass_empty_rounded;
        break;
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

  Widget _buildChildrenAvatars(List<SubChild> children, bool isDark) {
    final displayedCount = children.length > 3 ? 3 : children.length;
    final remains = children.length - displayedCount;
    const double avatarSize = 32.0;
    const double overlapWidth = 24.0;

    return SizedBox(
      height: avatarSize,
      width: (displayedCount * overlapWidth) + (remains > 0 ? overlapWidth : 8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (remains > 0)
            Positioned(
              left: 0,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.grey800 : AppColors.grey200,
                  border: Border.all(color: isDark ? AppColors.surfaceDark : AppColors.white, width: 1.5),
                ),
                child: Text(
                  '+$remains',
                  style: AppTextStyles.style(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
              ),
            ),
          ...List.generate(displayedCount, (index) {
            final kid = children[displayedCount - 1 - index];
            final isMale = kid.name.contains('أحمد') || 
                           kid.name.contains('يوسف') || 
                           kid.name.contains('عمر') ||
                           kid.name.contains('سعيد');
            final avatarBg = isMale 
                ? AppColors.maleBlue.withValues(alpha: 0.1) 
                : AppColors.femalePink.withValues(alpha: 0.1);
            final avatarColor = isMale ? AppColors.maleBlue : AppColors.femalePink;

            final double positionLeft = (remains > 0 ? 1 : 0) * overlapWidth + index * overlapWidth;

            return Positioned(
              left: positionLeft,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.surfaceDark : AppColors.white,
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 14.5,
                  backgroundColor: avatarBg,
                  child: Text(
                    kid.initials,
                    style: AppTextStyles.style(
                      fontWeight: FontWeight.bold,
                      color: avatarColor,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
