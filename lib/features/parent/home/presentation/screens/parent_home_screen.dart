import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/utils/theme_context.dart';

// تأكدي من مسارات الاستدعاء هذي حسب مجلدات مشروعك
import 'package:kids_transport/features/parent/home/presentation/widgets/top_card_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/children_section_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/quick_services_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/notifications_widget.dart';

/// الشاشة الأساسية (نفس الاسم اللي يدور عليه الـ Router والـ Wrapper)
class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : const Color(0xFFF8FAFC),
        body: const SafeArea(
          child: HomeScreenBody(), // استدعاء البودي من نفس الملف
        ),
      ),
    );
  }
}

/// 🏠 HomeScreenBody - الويدجت الرئيسي لمحتوى الشاشة الرئيسية
class HomeScreenBody extends StatelessWidget {
  final Future<void> Function()? onRefresh;

  const HomeScreenBody({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // 🟢 تم فرض الحالات هنا (تقدرين تغيريهم لـ true أو false لاحقاً) 🟢
    const bool hasTrips = true; // حالة الكارد العلوي (يوجد رحلات)
    const bool hasChildren = false; // حالة قسم الأطفال (لا يوجد أطفال)
    const bool hasNotifications = false; // حالة قسم الإشعارات (لا توجد إشعارات)

    return RefreshIndicator(
      onRefresh:
          onRefresh ??
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
          // 🧠 1) الكارد العلوي
          const TopCardWidget(hasTrips: hasTrips),
          SizedBox(height: 22.h),

          // 👶 2) قسم الأطفال
          const ChildrenSectionWidget(hasChildren: hasChildren),
          SizedBox(height: 22.h),

          // ⚡ 3) قسم الخدمات السريعة
          const QuickServicesWidget(),
          SizedBox(height: 22.h),

          // 🔔 4) قسم الإشعارات
          const NotificationsWidget(hasNotifications: hasNotifications),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
