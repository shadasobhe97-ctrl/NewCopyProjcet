import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';

enum StatusType { inBus, waiting, arrived, absent }

class TripStatusChip extends StatelessWidget {
  final String statusText;
  final StatusType type;
  final bool isCompact;

  const TripStatusChip({
    super.key,
    required this.statusText,
    required this.type,
    this.isCompact = false,
  });

  factory TripStatusChip.fromStatusString(String status, {bool isCompact = false}) {
    final s = status.toLowerCase();
    if (s.contains('waiting') || s.contains('ينتظر') || s.contains('انتظار')) {
      return TripStatusChip(
        statusText: 'ينتظر',
        type: StatusType.waiting,
        isCompact: isCompact,
      );
    }
    if (s.contains('in_bus') || s.contains('picked_up') || s.contains('صعود') || s.contains('طريق')) {
      return TripStatusChip(
        statusText: 'في الطريق',
        type: StatusType.inBus,
        isCompact: isCompact,
      );
    }
    if (s.contains('arrived') || s.contains('dropped_off') || s.contains('وصل')) {
      return TripStatusChip(
        statusText: 'تم الوصول',
        type: StatusType.arrived,
        isCompact: isCompact,
      );
    }
    if (s.contains('absent') || s.contains('غائب')) {
      return TripStatusChip(
        statusText: 'غائب',
        type: StatusType.absent,
        isCompact: isCompact,
      );
    }
    return TripStatusChip(
      statusText: status,
      type: StatusType.inBus,
      isCompact: isCompact,
    );
  }

  Color get _color {
    switch (type) {
      case StatusType.inBus:
        return AppColors.success;
      case StatusType.waiting:
        return AppColors.warning;
      case StatusType.arrived:
        return AppColors.maleBlue;
      case StatusType.absent:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final isDark = context.isDarkMode;

    if (isCompact) {
      return Container(
        width: 8.r,
        height: 8.r,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.r,
            height: 7.r,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            statusText,
            style: AppTextStyles.style(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
