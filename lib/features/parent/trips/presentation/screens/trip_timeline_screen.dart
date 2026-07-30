import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../data/models/trip_timeline_model.dart';

class TripTimelineScreen extends StatelessWidget {
  final String tripTitle;
  final List<TripTimelineItemModel> timelineItems;

  const TripTimelineScreen({
    super.key,
    required this.tripTitle,
    required this.timelineItems,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final items = timelineItems.isEmpty ? _getMockTimeline() : timelineItems;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'Timeline $tripTitle',
            style: AppTextStyles.style(
              fontWeight: FontWeight.bold,
              fontSize: 17.sp,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          foregroundColor: isDark ? AppColors.white : AppColors.textDark,
        ),
        body: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isFirst = index == 0;
            final isLast = index == items.length - 1;
            return _buildTimelineTile(context, item, isFirst, isLast);
          },
        ),
      ),
    );
  }

  Widget _buildTimelineTile(
    BuildContext context,
    TripTimelineItemModel item,
    bool isFirst,
    bool isLast,
  ) {
    final isDark = context.isDarkMode;
    Color nodeColor = item.isDone ? AppColors.success : (item.isCurrent ? context.primaryColor : AppColors.grey400);
    IconData nodeIcon = item.isDone ? Icons.check_circle_rounded : (item.isCurrent ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded);

    if (item.status.contains('absent') || item.status.contains('غائب')) {
      nodeColor = AppColors.error;
      nodeIcon = Icons.cancel_rounded;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Column
          SizedBox(
            width: 70.w,
            child: Text(
              item.time,
              style: AppTextStyles.style(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: item.isDone || item.isCurrent ? context.textPrimary : AppColors.textMuted,
              ),
            ),
          ),

          // Vertical Line & Node Column
          Column(
            children: [
              Container(
                width: 2.w,
                height: 12.h,
                color: isFirst ? Colors.transparent : (item.isDone ? AppColors.success : AppColors.grey300),
              ),
              Icon(nodeIcon, color: nodeColor, size: 22.r),
              Expanded(
                child: Container(
                  width: 2.w,
                  color: isLast ? Colors.transparent : (item.isDone ? AppColors.success : AppColors.grey300),
                ),
              ),
            ],
          ),
          SizedBox(width: 14.w),

          // Event Card Content Column
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 20.h),
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: isDark ? context.cardSurface : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: item.isCurrent ? Border.all(color: context.primaryColor, width: 1.5) : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.title,
                        style: AppTextStyles.style(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      if (item.isCurrent)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'المرحلة الحالية',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: context.primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      item.description!,
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
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

  List<TripTimelineItemModel> _getMockTimeline() {
    return const [
      TripTimelineItemModel(status: 'started', title: 'بدأت الرحلة', time: '07:00 ص', description: 'انطلق السائق من نقطة البداية', isDone: true),
      TripTimelineItemModel(status: 'driver_arrived', title: 'وصل السائق إلى المنزل', time: '07:15 ص', description: 'وصلت الحافلة أمام المنزل', isDone: true),
      TripTimelineItemModel(status: 'boarded', title: 'تم صعود الطفل الحافلة', time: '07:17 ص', description: 'تم مسح QR Code الخاص بالطفل', isDone: true),
      TripTimelineItemModel(status: 'in_transit', title: 'الحافلة في الطريق إلى المدرسة', time: '07:20 ص', description: 'المركبة تسير في المسار المعتاد', isDone: false, isCurrent: true),
      TripTimelineItemModel(status: 'arrived_school', title: 'الوصول إلى المدرسة', time: '07:45 ص', description: 'الوصول المتوقع بسلام', isDone: false),
    ];
  }
}
