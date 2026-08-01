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

  List<TripTimelineItemModel> _getMockTimeline() {
    return const [
      TripTimelineItemModel(
        time: '07:30 ص',
        title: 'بدأت الرحلة',
        description: 'تم انطلاق الحافلة من النقطة الأولى',
        status: 'start',
        isDone: true,
        isCurrent: false,
      ),
      TripTimelineItemModel(
        time: '07:35 ص',
        title: 'تم صعود أحمد علي',
        description: 'تم الصعود والحضور بنجاح',
        status: 'pickup',
        isDone: true,
        isCurrent: false,
      ),
      TripTimelineItemModel(
        time: '07:38 ص',
        title: 'تم صعود سارة محمد',
        description: 'تم الصعود والحضور بنجاح',
        status: 'pickup',
        isDone: true,
        isCurrent: false,
      ),
      TripTimelineItemModel(
        time: '07:40 ص',
        title: 'في الطريق إلى المدرسة',
        description: 'الرحلة مستمرة بأمان نحو مدرسة المعرفة',
        status: 'on_the_way',
        isDone: false,
        isCurrent: true,
      ),
      TripTimelineItemModel(
        time: '08:00 ص',
        title: 'الوصول إلى المدرسة',
        description: 'الوصول والنزول الآمن لجميع الطلاب',
        status: 'arrive',
        isDone: false,
        isCurrent: false,
      ),
      TripTimelineItemModel(
        time: '13:30 م',
        title: 'بدء رحلة العودة',
        description: 'لم تبدأ بعد',
        status: 'return_start',
        isDone: false,
        isCurrent: false,
      ),
      TripTimelineItemModel(
        time: '14:00 م',
        title: 'الوصول إلى المنزل',
        description: 'لم تبدأ بعد',
        status: 'return_arrive',
        isDone: false,
        isCurrent: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final items = (timelineItems != null && timelineItems!.isNotEmpty) ? timelineItems! : _getMockTimeline();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'الخط الزمني للرحلة',
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
            icon: Icon(Icons.arrow_back_ios_rounded, color: context.primaryColor, size: 20.r),
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
                      fontSize: 14.sp,
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
                      'مباشر حقيقي',
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
              child: ListView.builder(
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
