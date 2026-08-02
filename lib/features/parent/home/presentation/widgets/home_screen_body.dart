import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/top_card_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/children_section_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/quick_services_widget.dart';
import 'package:kids_transport/features/parent/home/presentation/widgets/notifications_widget.dart';

/// 🏠 5) HomeScreenBody - الويدجت الرئيسي لمحتوى الشاشة الرئيسية
/// يجمع الودجات الأربعة الرئيسية:
/// 1. TopCardWidget (الكارد العلوي)
/// 2. ChildrenSectionWidget (قسم الأطفال)
/// 3. QuickServicesWidget (قسم الخدمات السريعة)
/// 4. NotificationsWidget (قسم الإشعارات)
///
/// ⚠️ لا يحتوي على Scaffold أو AppBar أو BottomNavigationBar.
/// يدعم الوضعين (Light & Dark Mode) والاتجاه (RTL).
class HomeScreenBody extends StatefulWidget {
  final bool initialHasTrips;
  final bool initialHasChildren;
  final bool initialHasNotifications;
  final bool showStateFilterBar;
  final Future<void> Function()? onRefresh;

  const HomeScreenBody({
    super.key,
    this.initialHasTrips = true,
    this.initialHasChildren = true,
    this.initialHasNotifications = true,
    this.showStateFilterBar = true,
    this.onRefresh,
  });

  @override
  State<HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<HomeScreenBody> {
  late bool hasTrips;
  late bool hasChildren;
  late bool hasNotifications;

  @override
  void initState() {
    super.initState();
    hasTrips = widget.initialHasTrips;
    hasChildren = widget.initialHasChildren;
    hasNotifications = widget.initialHasNotifications;
  }

  @override
  void didUpdateWidget(covariant HomeScreenBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialHasTrips != widget.initialHasTrips) {
      hasTrips = widget.initialHasTrips;
    }
    if (oldWidget.initialHasChildren != widget.initialHasChildren) {
      hasChildren = widget.initialHasChildren;
    }
    if (oldWidget.initialHasNotifications != widget.initialHasNotifications) {
      hasNotifications = widget.initialHasNotifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RefreshIndicator(
        onRefresh:
            widget.onRefresh ??
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
            // ⚙️ شريط تجربة وتبديل الحالات (مفيد للاختبار والتحكم السريع)
            if (widget.showStateFilterBar) ...[
              _buildStateFilterBar(context, primaryColor),
              SizedBox(height: 14.h),
            ],

            // 🧠 1) الكارد العلوي
            TopCardWidget(hasTrips: hasTrips),
            SizedBox(height: 22.h),

            // 👶 2) قسم الأطفال
            ChildrenSectionWidget(hasChildren: hasChildren),
            SizedBox(height: 22.h),

            // ⚡ 3) قسم الخدمات السريعة
            const QuickServicesWidget(),
            SizedBox(height: 22.h),

            // 🔔 4) قسم الإشعارات
            NotificationsWidget(hasNotifications: hasNotifications),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // شريط فلترة وتبديل الحالات لاختبار وتجربة الـ UI
  Widget _buildStateFilterBar(BuildContext context, Color primaryColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'تصفية الحالة:',
            style: AppTextStyles.style(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          Row(
            children: [
              _buildFilterPill(
                title: 'رحلات نشطة',
                isSelected: hasTrips && hasChildren,
                primaryColor: primaryColor,
                onTap: () {
                  setState(() {
                    hasTrips = true;
                    hasChildren = true;
                    hasNotifications = true;
                  });
                },
              ),
              SizedBox(width: 6.w),
              _buildFilterPill(
                title: 'بدون رحلات',
                isSelected: !hasTrips && hasChildren,
                primaryColor: primaryColor,
                onTap: () {
                  setState(() {
                    hasTrips = false;
                    hasChildren = true;
                    hasNotifications = false;
                  });
                },
              ),
              SizedBox(width: 6.w),
              _buildFilterPill(
                title: 'بدون أطفال',
                isSelected: !hasChildren,
                primaryColor: primaryColor,
                onTap: () {
                  setState(() {
                    hasTrips = false;
                    hasChildren = false;
                    hasNotifications = false;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill({
    required String title,
    required bool isSelected,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: primaryColor, width: 1),
        ),
        child: Text(
          title,
          style: AppTextStyles.style(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.white : primaryColor,
          ),
        ),
      ),
    );
  }
}
