import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// شارة حالة الرحلة (pending / in_progress / completed / suspended_breakdown)
class TripStatusBadge extends StatelessWidget {
  final String status;

  const TripStatusBadge({super.key, required this.status});

  String get _label {
    switch (status) {
      case 'pending':
        return 'لم تبدأ';
      case 'in_progress':
        return 'جارية الآن';
      case 'completed':
        return 'مكتملة';
      case 'suspended_breakdown':
        return 'متوقفة (عطل)';
      default:
        return status;
    }
  }

  Color get _color {
    switch (status) {
      case 'pending':
        return AppColors.pending;
      case 'in_progress':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      case 'suspended_breakdown':
        return AppColors.error;
      default:
        return AppColors.grey500;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: AppTextStyles.style(fontSize: 12, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
