import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';

class SubscriptionSkeleton extends StatefulWidget {
  final int itemCount;

  const SubscriptionSkeleton({
    super.key,
    this.itemCount = 2,
  });

  @override
  State<SubscriptionSkeleton> createState() => _SubscriptionSkeletonState();
}

class _SubscriptionSkeletonState extends State<SubscriptionSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.itemCount,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemBuilder: (context, index) {
            return _buildSkeletonCard(isDark);
          },
        );
      },
    );
  }

  Widget _buildSkeletonCard(bool isDark) {
    final baseColor = isDark ? AppColors.grey800 : AppColors.grey200;
    final highlightColor = isDark ? AppColors.grey700 : AppColors.grey100;
    final shimmerColor =
        Color.lerp(baseColor, highlightColor, _animation.value) ?? baseColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge status container
              Container(
                width: 65,
                height: 24,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Spacer(),
              // Driver Details block
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 14,
                    width: 110,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 90,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 130,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Driver avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: shimmerColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: isDark ? AppColors.grey800 : AppColors.grey100, height: 1),
          const SizedBox(height: 14),

          // Kids stacked photos row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Kids Avatars stacked
              Row(
                children: List.generate(3, (i) {
                  return Container(
                    margin: const EdgeInsets.only(right: 4),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: shimmerColor,
                      border: Border.all(
                        color: isDark ? AppColors.surfaceDark : AppColors.white,
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
              // Kids names & counts
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 10,
                    width: 100,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Buttons block
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
