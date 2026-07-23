import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';

class LoadingReviewsWidget extends StatefulWidget {
  const LoadingReviewsWidget({super.key});

  @override
  State<LoadingReviewsWidget> createState() => _LoadingReviewsWidgetState();
}

class _LoadingReviewsWidgetState extends State<LoadingReviewsWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
            children: List.generate(2, (index) => _buildSkeletonItem(baseColor)),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonItem(Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 18.r, backgroundColor: color),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 10.h, width: 80.w, color: color),
                    SizedBox(height: 6.h),
                    Container(height: 8.h, width: 50.w, color: color),
                  ],
                ),
              ),
              Container(height: 12.h, width: 60.w, color: color),
            ],
          ),
          SizedBox(height: 16.h),
          Container(height: 8.h, width: double.infinity, color: color),
          SizedBox(height: 6.h),
          Container(height: 8.h, width: 140.w, color: color),
        ],
      ),
    );
  }
}
