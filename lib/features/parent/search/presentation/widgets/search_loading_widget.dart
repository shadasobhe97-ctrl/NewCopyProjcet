import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';

/// ويدجت محاكاة التحميل (Shimmer Placeholder)
/// يُستخدم أثناء انتظار استجابة الباكيند لإظهار skeleton للمستخدم
class SearchLoadingWidget extends StatefulWidget {
  final int itemCount;

  const SearchLoadingWidget({
    super.key,
    this.itemCount = 3,
  });

  @override
  State<SearchLoadingWidget> createState() => _SearchLoadingWidgetState();
}

class _SearchLoadingWidgetState extends State<SearchLoadingWidget>
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: List.generate(widget.itemCount, (index) {
              return _buildSkeletonCard(isDark);
            }),
          ),
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة السائق
              CircleAvatar(
                radius: 26,
                backgroundColor: shimmerColor,
              ),
              const SizedBox(width: 12),

              // تفاصيل
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: 80,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: 160,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),

              // السعر
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 16,
                    width: 50,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 8,
                    width: 40,
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

          // زر
          Container(
            height: 38,
            width: double.infinity,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
