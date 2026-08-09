import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/top_card_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/children_section_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/quick_services_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/notifications_widget.dart';

class HomeScreenBody extends StatelessWidget {
  final Future<void> Function()? onRefresh;

  const HomeScreenBody({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // تم تثبيت الحالات بناءً على طلبك (فرضناها فرض)
    const bool hasTrips = true; // يوجد رحلات
    const bool hasChildren = false; // لا يوجد أطفال
    const bool hasNotifications = false; // لا توجد إشعارات

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RefreshIndicator(
        onRefresh: onRefresh ??
            () async {
              await Future.delayed(const Duration(milliseconds: 600));
            },
        color: primaryColor,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          children: [
            // 🧠 1) الكارد العلوي (رحلات نشطة)
            const TopCardWidget(
              hasTrips: hasTrips,
            ),
            SizedBox(height: 22.h),

            // 👶 2) قسم الأطفال (بدون أطفال)
            const ChildrenSectionWidget(
              hasChildren: hasChildren,
            ),
            SizedBox(height: 22.h),

            // ⚡ 3) قسم الخدمات السريعة
            const QuickServicesWidget(),
            SizedBox(height: 22.h),

            // 🔔 4) قسم الإشعارات (بدون إشعارات)
            const NotificationsWidget(
              hasNotifications: hasNotifications,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}