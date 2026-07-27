import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../data/models/absence_model.dart';

class ScheduledAbsenceCard extends StatelessWidget {
  final AbsenceModel absence;
  final VoidCallback onCancel;

  const ScheduledAbsenceCard({
    super.key,
    required this.absence,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    // تنسيق التاريخ
    final dt = absence.dateTime;
    final monthNames = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    final formattedDate =
        '${dt.day} ${monthNames[dt.month]} ${dt.year}';

    final typeIcon = _typeIcon(absence.absenceType);
    final typeColor = _typeColor(absence.absenceType);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة نوع الغياب
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(typeIcon, color: typeColor, size: 20),
          ),
          const SizedBox(width: 12),
          // معلومات الغياب
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedDate,
                  style: AppTextStyles.style(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    absence.typeLabel,
                    style: AppTextStyles.style(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: typeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // زر الإلغاء
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'إلغاء',
              style: AppTextStyles.style(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(AbsenceType type) {
    switch (type) {
      case AbsenceType.pickup:
        return Icons.arrow_circle_up_rounded;
      case AbsenceType.dropoff:
        return Icons.arrow_circle_down_rounded;
      case AbsenceType.both:
        return Icons.swap_vert_circle_rounded;
    }
  }

  Color _typeColor(AbsenceType type) {
    switch (type) {
      case AbsenceType.pickup:
        return const Color(0xFF3B82F6); // أزرق
      case AbsenceType.dropoff:
        return const Color(0xFF8B5CF6); // بنفسجي
      case AbsenceType.both:
        return const Color(0xFFF59E0B); // برتقالي
    }
  }
}
