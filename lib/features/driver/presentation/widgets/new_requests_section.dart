import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/driver/data/models/driver_model.dart';
import 'package:kids_transport/features/driver/logic/driver_home_cubit/driver_home_cubit.dart';

class NewRequestsSection extends StatelessWidget {
  final List<SubscriptionRequest> requests;

  const NewRequestsSection({super.key, required this.requests});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم مع العداد
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: AppTheme.boxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppTheme.radius(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'طلبات الاشتراك الجديدة (${requests.length})',
              style: AppTextStyles.style(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // عرض الطلبات أو الحالة الفارغة
        if (requests.isEmpty)
          _EmptyRequestsState()
        else
          ...requests.map(
            (req) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RequestCard(request: req),
            ),
          ),
      ],
    );
  }
}

class _EmptyRequestsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppTheme.radius(20),
        border: AppTheme.border(
          color: isDark ? AppColors.grey800 : AppColors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: AppTheme.boxDecoration(
              color: AppColors.grey.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              color: AppColors.textMuted,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد طلبات جديدة',
            style: AppTextStyles.style(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ستظهر هنا طلبات اشتراك أولياء الأمور',
            style: AppTextStyles.style(fontSize: 12, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final SubscriptionRequest request;

  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppTheme.radius(20),
        border: AppTheme.border(
          color: isDark ? AppColors.grey800 : AppColors.grey.withValues(alpha: 0.15),
        ),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── معلومات الطالب ──
          Row(
            children: [
              // أفاتار الطالب
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primaryLight.withValues(alpha: 0.12),
                child: request.studentAvatarUrl == null
                    ? const Icon(
                        Icons.child_care_rounded,
                        color: AppColors.primaryLight,
                        size: 26,
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // اسم الطالب والمدرسة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.studentName,
                      style: AppTextStyles.style(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.school_rounded,
                          color: AppColors.textMuted,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            request.schoolName,
                            style: AppTextStyles.style(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── تفاصيل الطلب ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppTheme.boxDecoration(
              color: isDark ? AppColors.grey900 : AppColors.backgroundLight,
              borderRadius: AppTheme.radius(12),
            ),
            child: Column(
              children: [
                // الفترة
                _InfoRow(
                  icon: Icons.schedule_rounded,
                  iconColor: AppColors.pending,
                  text: request.tripPeriodArabic,
                ),
                const SizedBox(height: 8),
                // العنوان
                _InfoRow(
                  icon: Icons.location_on_rounded,
                  iconColor: AppColors.error,
                  text: '${request.district}، ${request.address}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── أزرار القبول والرفض ──
          Row(
            children: [
              // زر الرفض
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<DriverHomeCubit>().rejectRequest(request.id);
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                  label: Text(
                    'رفض',
                    style: AppTextStyles.style(color: AppColors.error),
                  ),
                  style: AppTheme.outlinedButtonStyle(
                    side: AppTheme.borderSide(color: AppColors.error, width: 1.5),
                    minimumSize: const Size(0, 46),
                    shape: AppTheme.roundedRectangleBorder(
                      borderRadius: AppTheme.radius(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // زر الموافقة
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<DriverHomeCubit>().acceptRequest(request.id);
                  },
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text('موافقة'),
                  style: AppTheme.elevatedButtonStyle(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(0, 46),
                    elevation: 0,
                    shape: AppTheme.roundedRectangleBorder(
                      borderRadius: AppTheme.radius(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 15),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.style(fontSize: 13, color: AppColors.textMuted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
