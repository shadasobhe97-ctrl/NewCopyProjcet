import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/requests/data/models/driver_request_model.dart';
import 'package:kids_transport/features/driver/requests/presentation/screens/driver_request_details_screen.dart';

/// قسم طلبات الاشتراك الجديدة في الصفحة الرئيسية للسائق
/// يعرض قائمة الطلبات الجديدة مع التركيز على الأطفال والمدارس لتجنب عرض بيانات ولي الأمر كعنوان رئيسي
class NewRequestsSection extends StatelessWidget {
  final List<DriverRequestModel> requests;

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
              style: AppTextStyles.style(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // عرض الطلبات أو الحالة الفارغة
        if (requests.isEmpty)
          const _EmptyRequestsState()
        else
          ...requests.map(
            (req) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _HomeRequestCard(request: req),
            ),
          ),
      ],
    );
  }
}

class _EmptyRequestsState extends StatelessWidget {
  const _EmptyRequestsState();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppTheme.radius(20),
        border: AppTheme.border(
          color: isDark
              ? AppColors.grey800
              : AppColors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: AppTheme.boxDecoration(
              color: AppColors.grey.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              color: AppColors.textMuted,
              size: 26,
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
            'ستظهر هنا طلبات اشتراك أولياء الأمور عند وصولها',
            style: AppTextStyles.style(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HomeRequestCard extends StatelessWidget {
  final DriverRequestModel request;

  const _HomeRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final hasMultipleKids = request.children.length > 1;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DriverRequestDetailsScreen(requestId: request.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.boxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: AppTheme.radius(20),
          border: AppTheme.border(
            color: isDark
                ? AppColors.grey800
                : AppColors.grey.withValues(alpha: 0.15),
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
            // ── معلومات الأطفال والمدرسة ──
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      AppColors.primaryLight.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.child_care_rounded,
                    color: AppColors.primaryLight,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // اسم الطفل والمدرسة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasMultipleKids
                            ? 'الطلاب: ${request.children.map((c) => c.name).join('، ')}'
                            : (request.children.isNotEmpty
                                ? request.children.first.name
                                : 'طلب اشتراك جديد'),
                        style: AppTextStyles.style(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                              request.school.name,
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
                  _InfoRow(
                    icon: Icons.schedule_rounded,
                    iconColor: AppColors.pending,
                    text: 'الفترة: ${request.timingDisplayLabel}',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.monetization_on_rounded,
                    iconColor: AppColors.success,
                    text: 'التكلفة الإجمالية: ${request.totalPrice} د.ل',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── عرض التفاصيل والمسار ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلب #${request.id}',
                  style: AppTextStyles.style(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'عرض التفاصيل والمسار',
                      style: AppTextStyles.style(
                        fontSize: 11,
                        color: context.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: context.primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.style(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
