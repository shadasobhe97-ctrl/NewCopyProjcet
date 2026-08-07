import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// شارة حالة الطفل ضمن محطة/رحلة (قيم trip_stops.status الحقيقية من الباك إند)
class TripChildStatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const TripChildStatusBadge({super.key, required this.status, this.compact = false});

  String get _label {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'absent_pre':
        return 'غياب مسبق';
      case 'boarded':
        return 'على متن الحافلة';
      case 'absent_late':
        return 'غائب';
      case 'skipped_unresponsive':
        return 'تم تجاوزه';
      case 'dropped_off_school':
        return 'وصل للمدرسة';
      case 'delivered_home':
        return 'وصل للمنزل';
      case 'dropoff_failed':
        return 'تعذر التسليم';
      case 'direct_parent_handling':
        return 'تسليم مباشر لولي الأمر';
      default:
        return status;
    }
  }

  Color get _color {
    switch (status) {
      case 'pending':
        return AppColors.grey500;
      case 'absent_pre':
      case 'absent_late':
        return AppColors.error;
      case 'boarded':
        return AppColors.info;
      case 'skipped_unresponsive':
        return AppColors.pending;
      case 'dropped_off_school':
      case 'delivered_home':
        return AppColors.success;
      case 'dropoff_failed':
        return AppColors.error;
      case 'direct_parent_handling':
        return AppColors.accentPurple;
      default:
        return AppColors.grey500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: AppTextStyles.style(
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
