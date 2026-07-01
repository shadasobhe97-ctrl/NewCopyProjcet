import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class ActiveTripCard extends StatelessWidget {
  final bool hasActiveTrip;

  const ActiveTripCard({super.key, required this.hasActiveTrip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
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
              'الرحلة الحالية',
              style: AppTextStyles.style(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // بطاقة الرحلة
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
          child: hasActiveTrip
              // TODO: عرض بيانات الرحلة النشطة الحقيقية هنا
              ? Center(child: Text('رحلة نشطة'))
              : _EmptyTripState(),
        ),
      ],
    );
  }
}

class _EmptyTripState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // أيقونة مسار رمادي
        Container(
          width: 72,
          height: 72,
          decoration: AppTheme.boxDecoration(
            color: AppColors.grey.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.route_rounded,
            color: AppColors.textMuted,
            size: 36,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'لا توجد رحلة نشطة حالياً',
          style: AppTextStyles.style(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'ستظهر هنا تفاصيل رحلتك عند البدء',
          style: AppTextStyles.style(fontSize: 12, color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
