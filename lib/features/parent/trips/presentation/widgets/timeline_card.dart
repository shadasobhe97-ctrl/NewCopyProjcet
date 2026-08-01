import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../data/models/trip_timeline_model.dart';

class TimelineCard extends StatefulWidget {
  final TripTimelineItemModel item;
  final bool isFirst;
  final bool isLast;

  const TimelineCard({
    super.key,
    required this.item,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<TimelineCard> createState() => _TimelineCardState();
}

class _TimelineCardState extends State<TimelineCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.28).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.item.isCurrent) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant TimelineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.isCurrent && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.item.isCurrent && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getNodeColor(BuildContext context) {
    if (widget.item.isCompleted) return AppColors.success;
    if (widget.item.isCurrent) return AppColors.amber;
    return AppColors.grey400;
  }

  IconData _getIcon() {
    final status = widget.item.statusKey.toLowerCase();
    if (status == 'started' || status.contains('start') || status.contains('انطلاق')) {
      return Icons.play_arrow_rounded;
    }
    if (status == 'picked_up' || status.contains('pickup') || status.contains('صعود')) {
      return Icons.directions_bus_rounded;
    }
    if (status == 'arrived_school' || status.contains('arrive') || status.contains('مدرسة')) {
      return Icons.school_rounded;
    }
    if (status == 'completed' || status.contains('complete') || status.contains('مكتمل')) {
      return Icons.task_alt_rounded;
    }
    return Icons.check_circle_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final nodeColor = _getNodeColor(context);
    final isCurrent = widget.item.isCurrent;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1) Time Column
          SizedBox(
            width: 54.w,
            child: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                widget.item.time,
                textAlign: TextAlign.center,
                style: AppTextStyles.style(
                  fontSize: 12.sp,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                  color: isCurrent ? context.primaryColor : context.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // 2) Timeline Node & Connecting Line
          Column(
            children: [
              // Top connecting line
              if (!widget.isFirst)
                Container(
                  width: 2.w,
                  height: 12.h,
                  color: widget.item.isCompleted
                      ? AppColors.success
                      : (isDark ? AppColors.grey700 : AppColors.grey300),
                )
              else
                SizedBox(height: 12.h),

              // Animated Node Circle
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isCurrent ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: isCurrent ? 28.r : 22.r,
                      height: isCurrent ? 28.r : 22.r,
                      decoration: BoxDecoration(
                        color: nodeColor,
                        shape: BoxShape.circle,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: nodeColor.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: Icon(
                        _getIcon(),
                        color: AppColors.white,
                        size: isCurrent ? 16.r : 13.r,
                      ),
                    ),
                  );
                },
              ),

              // Bottom connecting line
              if (!widget.isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    color: widget.item.isCompleted
                        ? AppColors.success
                        : (isDark ? AppColors.grey700 : AppColors.grey300),
                  ),
                ),
            ],
          ),
          SizedBox(width: 14.w),

          // 3) Event Detail Card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 14.h),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey900 : AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isCurrent
                      ? context.primaryColor
                      : (isDark ? AppColors.grey800 : AppColors.grey200),
                  width: isCurrent ? 1.8 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
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
                      Expanded(
                        child: Text(
                          widget.item.title,
                          style: AppTextStyles.style(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: isCurrent ? context.primaryColor : context.textPrimary,
                          ),
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'مباشر',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.amber,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (widget.item.description != null && widget.item.description!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      widget.item.description!,
                      style: AppTextStyles.style(
                        fontSize: 11.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
