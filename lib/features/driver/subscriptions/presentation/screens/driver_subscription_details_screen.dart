import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/subscriptions/data/models/driver_subscription_model.dart';

/// شاشة تفاصيل الاشتراك النشط للسائق
/// تعرض بيانات الطفل، المدرسة، المسار، وتفاصيل العقد المالي والبنود
class DriverSubscriptionDetailsScreen extends StatelessWidget {
  final DriverSubscriptionModel subscription;

  const DriverSubscriptionDetailsScreen({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة حالة الاشتراك
              _SubscriptionStatusBanner(subscription: subscription),
              const SizedBox(height: 16),

              // بطاقة الطفل والمدرسة
              _SectionCard(
                icon: Icons.child_care_rounded,
                iconColor: AppColors.success,
                title: 'بيانات الطالب والرحلة',
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.face_rounded,
                      label: 'الاسم',
                      value: subscription.child.displayName,
                    ),
                    _InfoRow(
                      icon: Icons.school_rounded,
                      label: 'المدرسة',
                      value: subscription.child.schoolName,
                    ),
                    if (subscription.pickupLabel != null)
                      _InfoRow(
                        icon: Icons.home_rounded,
                        label: 'نقطة الانطلاق',
                        value: subscription.pickupLabel!,
                      ),
                    if (subscription.dropoffLabel != null)
                      _InfoRow(
                        icon: Icons.location_on_rounded,
                        label: 'نقطة الوصول',
                        value: subscription.dropoffLabel!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // أوقات وتفاصيل التوصيل
              _SectionCard(
                icon: Icons.schedule_rounded,
                iconColor: AppColors.pending,
                title: 'أوقات وتفاصيل التوصيل',
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.login_rounded,
                      label: 'وقت الاصطحاب (الذهاب)',
                      value: subscription.pickupTime ?? 'غير محدد',
                    ),
                    _InfoRow(
                      icon: Icons.logout_rounded,
                      label: 'وقت التوصيل (العودة)',
                      value: subscription.dropoffTime ?? 'غير محدد',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // بيانات العقد والمالية
              if (subscription.contract != null) ...[
                _SectionCard(
                  icon: Icons.assignment_rounded,
                  iconColor: AppColors.primaryLight,
                  title: 'بيانات العقد المالي',
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.receipt_rounded,
                        label: 'رقم العقد',
                        value: subscription.contract!.contractNumber,
                      ),
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'تاريخ البدء',
                        value: _formatDate(subscription.contract!.startDate),
                      ),
                      _InfoRow(
                        icon: Icons.calendar_month_rounded,
                        label: 'تاريخ الانتهاء',
                        value: _formatDate(subscription.contract!.endDate),
                      ),
                      _InfoRow(
                        icon: Icons.monetization_on_rounded,
                        label: 'تكلفة الاشتراك الإجمالية',
                        value: '${subscription.contract!.totalPrice} د.ل',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ولي الأمر (بيانات التواصل)
              _SectionCard(
                icon: Icons.contact_phone_rounded,
                iconColor: AppColors.warning,
                title: 'بيانات التواصل مع ولي الأمر',
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: 'الاسم',
                      value: subscription.parent.name,
                    ),
                    if (subscription.parent.phone != null &&
                        subscription.parent.phone!.isNotEmpty)
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'الهاتف',
                        value: subscription.parent.phone!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: AppTheme.boxDecoration(
          gradient: AppTheme.linearGradient(
            colors: context.primaryGradient,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded,
                      color: AppColors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 4),
                Text(
                  'تفاصيل الاشتراك #${subscription.id}',
                  style: AppTextStyles.style(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}

// ── شريط حالة الاشتراك ──
class _SubscriptionStatusBanner extends StatelessWidget {
  final DriverSubscriptionModel subscription;

  const _SubscriptionStatusBanner({required this.subscription});

  Color _getStatusColor() {
    switch (subscription.status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'pending_start':
        return AppColors.pending;
      case 'completed':
        return AppColors.primaryLight;
      case 'cancelled':
        return AppColors.grey400;
      default:
        return AppColors.primaryLight;
    }
  }

  IconData _getStatusIcon() {
    switch (subscription.status.toLowerCase()) {
      case 'active':
        return Icons.check_circle_rounded;
      case 'pending_start':
        return Icons.hourglass_empty_rounded;
      case 'completed':
        return Icons.done_all_rounded;
      case 'cancelled':
        return Icons.block_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final color = _getStatusColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.boxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: AppTheme.radius(16),
        border: AppTheme.border(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: AppTheme.boxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_getStatusIcon(), color: color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حالة الاشتراك',
                  style: AppTextStyles.style(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subscription.statusDisplayLabel,
                  style: AppTextStyles.style(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: AppTheme.boxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppTheme.radius(20),
            ),
            child: Text(
              'نشط',
              style: AppTextStyles.style(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── بطاقة قسم عامة ──
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppTheme.radius(16),
        border: AppTheme.border(
          color: isDark
              ? AppColors.grey800
              : AppColors.grey.withValues(alpha: 0.12),
        ),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: AppTheme.boxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: AppTheme.radius(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.style(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── صف معلومات ──
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppTextStyles.style(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.style(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
