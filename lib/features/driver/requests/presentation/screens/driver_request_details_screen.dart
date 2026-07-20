import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/requests/data/models/driver_request_model.dart';

/// شاشة تفاصيل طلب الاشتراك للسائق
class DriverRequestDetailsScreen extends StatelessWidget {
  final DriverRequestModel request;

  const DriverRequestDetailsScreen({super.key, required this.request});

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
              // ── بطاقة الحالة ──
              _StatusBanner(request: request),
              const SizedBox(height: 16),

              // ── بطاقة ولي الأمر ──
              _SectionCard(
                icon: Icons.person_rounded,
                iconColor: AppColors.primaryLight,
                title: 'ولي الأمر',
                child: _ParentInfoWidget(parent: request.parent),
              ),
              const SizedBox(height: 12),

              // ── بطاقة المدرسة ──
              _SectionCard(
                icon: Icons.school_rounded,
                iconColor: AppColors.warning,
                title: 'المدرسة',
                child: _SchoolInfoWidget(school: request.school),
              ),
              const SizedBox(height: 12),

              // ── بطاقة الأطفال ──
              _SectionCard(
                icon: Icons.child_care_rounded,
                iconColor: AppColors.success,
                title: 'الأطفال (${request.children.length})',
                child: _ChildrenListWidget(children: request.children),
              ),
              const SizedBox(height: 12),

              // ── بطاقة تفاصيل الرحلة ──
              _SectionCard(
                icon: Icons.schedule_rounded,
                iconColor: AppColors.pending,
                title: 'تفاصيل الرحلة',
                child: _TripDetailsWidget(request: request),
              ),

              // ── ملاحظات إن وجدت ──
              if (request.notes != null && request.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _SectionCard(
                  icon: Icons.notes_rounded,
                  iconColor: AppColors.textMuted,
                  title: 'ملاحظات',
                  child: Text(
                    request.notes!,
                    style: AppTextStyles.style(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
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
                  'تفاصيل الطلب #${request.id}',
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
}

// ── شريط الحالة ──
class _StatusBanner extends StatelessWidget {
  final DriverRequestModel request;
  const _StatusBanner({required this.request});

  Color _getStatusColor() {
    switch (request.status.toLowerCase()) {
      case 'pending':
        return AppColors.pending;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'cancelled':
        return AppColors.grey400;
      default:
        return AppColors.primaryLight;
    }
  }

  IconData _getStatusIcon() {
    switch (request.status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
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
                  'حالة الطلب',
                  style: AppTextStyles.style(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  request.statusDisplayLabel,
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
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: AppTheme.boxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppTheme.radius(20),
            ),
            child: Text(
              'طلب #${request.id}',
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

// ── معلومات ولي الأمر ──
class _ParentInfoWidget extends StatelessWidget {
  final DriverReqParent parent;
  const _ParentInfoWidget({required this.parent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(
          icon: Icons.person_outline_rounded,
          label: 'الاسم',
          value: parent.name.isNotEmpty ? parent.name : 'غير محدد',
        ),
        if (parent.phone != null && parent.phone!.isNotEmpty)
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'الهاتف',
            value: parent.phone!,
          ),
      ],
    );
  }
}

// ── معلومات المدرسة ──
class _SchoolInfoWidget extends StatelessWidget {
  final DriverReqSchool school;
  const _SchoolInfoWidget({required this.school});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(
          icon: Icons.school_outlined,
          label: 'الاسم',
          value: school.name.isNotEmpty ? school.name : 'غير محدد',
        ),
        if (school.address != null && school.address!.isNotEmpty)
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'الموقع',
            value: school.address!,
          ),
      ],
    );
  }
}

// ── قائمة الأطفال ──
class _ChildrenListWidget extends StatelessWidget {
  final List<DriverReqChild> children;
  const _ChildrenListWidget({required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return Text(
        'لا يوجد أطفال',
        style: AppTextStyles.style(fontSize: 13, color: AppColors.textMuted),
      );
    }

    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        return _ChildCard(child: child, index: index);
      }).toList(),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final DriverReqChild child;
  final int index;
  const _ChildCard({required this.child, required this.index});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      margin: EdgeInsets.only(bottom: index < 10 ? 8 : 0),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.grey900 : AppColors.backgroundLight,
        borderRadius: AppTheme.radius(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    AppColors.primaryLight.withValues(alpha: 0.12),
                child: const Icon(Icons.child_care_rounded,
                    color: AppColors.primaryLight, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name.isNotEmpty ? child.name : 'غير محدد',
                      style: AppTextStyles.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (child.grade != null && child.grade!.isNotEmpty)
                      Text(
                        child.grade!,
                        style: AppTextStyles.style(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // بيانات موقع الطفل إن وجدت
          if (child.pivot != null) ...[
            const SizedBox(height: 8),
            if (child.pivot!.homeLabel != null &&
                child.pivot!.homeLabel!.isNotEmpty)
              _InfoRow(
                icon: Icons.home_rounded,
                label: 'المنزل',
                value: child.pivot!.homeLabel!,
                isCompact: true,
              ),
          ],
        ],
      ),
    );
  }
}

// ── تفاصيل الرحلة ──
class _TripDetailsWidget extends StatelessWidget {
  final DriverRequestModel request;
  const _TripDetailsWidget({required this.request});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoRow(
          icon: Icons.schedule_rounded,
          label: 'الفترة',
          value: request.timingDisplayLabel,
        ),
        _InfoRow(
          icon: Icons.people_alt_rounded,
          label: 'عدد الأطفال',
          value: '${request.childrenCount}',
        ),
        if (request.pickupTime != null && request.pickupTime!.isNotEmpty)
          _InfoRow(
            icon: Icons.login_rounded,
            label: 'وقت الاصطحاب',
            value: request.pickupTime!,
          ),
        if (request.dropoffTime != null && request.dropoffTime!.isNotEmpty)
          _InfoRow(
            icon: Icons.logout_rounded,
            label: 'وقت التوصيل',
            value: request.dropoffTime!,
          ),
        if (request.createdAt.isNotEmpty)
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'تاريخ الطلب',
            value: _formatDate(request.createdAt),
          ),
      ],
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

// ── صف معلومات ──
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isCompact;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isCompact ? 4 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: isCompact ? 13 : 15, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppTextStyles.style(
              fontSize: isCompact ? 12 : 13,
              color: AppColors.textMuted,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.style(
                fontSize: isCompact ? 12 : 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
