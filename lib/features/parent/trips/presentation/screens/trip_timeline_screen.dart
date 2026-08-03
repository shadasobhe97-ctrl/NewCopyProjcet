import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../data/models/trip_timeline_model.dart';
import '../widgets/timeline_card.dart';

class TripTimelineScreen extends StatelessWidget {
  final String tripTitle;
  final List<TripTimelineItemModel>? timelineItems;

  const TripTimelineScreen({
    super.key,
    this.tripTitle = 'الرحلة',
    this.timelineItems,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final items = timelineItems ?? const [];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'المخطط الزمني للرحلة',
            style: AppTextStyles.style(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          centerTitle: true,
          backgroundColor: isDark ? context.cardSurface : AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded, color: context.primaryColor, size: 18.r),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Header Info Bar
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              color: isDark ? context.cardSurface : AppColors.white,
              child: Row(
                children: [
                  Icon(Icons.timeline_rounded, color: context.primaryColor, size: 20.r),
                  SizedBox(width: 8.w),
                  Text(
                    tripTitle,
                    style: AppTextStyles.style(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'مباشر',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 48.r,
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'لا توجد أحداث في المخطط الزمني حالياً',
                            style: AppTextStyles.style(
                              fontSize: 13.sp,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.r),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return TimelineCard(
                          item: items[index],
                          isFirst: index == 0,
                          isLast: index == items.length - 1,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
