import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: AppTextStyles.style(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _bgColor,
        ),
      ),
    );
  }

  Color get _bgColor {
    switch (status) {
      case 'مقبول':
      case 'مدفوعة':
        return AppColors.success;
      case 'مرفوض':
        return AppColors.red;
      case 'متأخرة':
        return AppColors.red;
      case 'قيد الانتظار':
      case 'غير مدفوعة':
        return AppColors.pending;
      default:
        return AppColors.grey500;
    }
  }
}
