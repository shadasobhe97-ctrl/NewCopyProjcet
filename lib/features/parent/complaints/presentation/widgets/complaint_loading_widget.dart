import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';

class ComplaintLoadingWidget extends StatefulWidget {
  const ComplaintLoadingWidget({super.key});

  @override
  State<ComplaintLoadingWidget> createState() => _ComplaintLoadingWidgetState();
}

class _ComplaintLoadingWidgetState extends State<ComplaintLoadingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.grey800 : Colors.grey[300]!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.35 + (_controller.value * 0.45),
          child: Column(
            children: List.generate(3, (index) => _buildSkeletonCard(baseColor)),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCard(Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 12.h, width: 100.w, color: color),
              Container(height: 18.h, width: 70.w, color: color),
            ],
          ),
          SizedBox(height: 12.h),
          Container(height: 10.h, width: 140.w, color: color),
          SizedBox(height: 8.h),
          Container(height: 8.h, width: double.infinity, color: color),
          SizedBox(height: 4.h),
          Container(height: 8.h, width: 180.w, color: color),
        ],
      ),
    );
  }
}
