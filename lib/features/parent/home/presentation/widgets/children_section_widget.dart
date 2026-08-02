import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_user_avatar.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/add_child_step1_screen.dart';
import 'package:kids_transport/features/parent/dashboard/presentation/screens/parent_main_wrapper.dart';

/// 👶 2) ChildrenSectionWidget - قسم الأطفال
/// يحتوي على هيدر "أطفالي" و "عرض الكل".
/// - hasChildren = true: قائمة أفقية لكروت الأطفال وآخر كارد هو كارد "إضافة طفل".
/// - hasChildren = false: نص "لا يوجد أطفال" وتحته نفس كارد "إضافة طفل" الصغير فقط بدون مساحات فارغة كبيرة.
class ChildrenSectionWidget extends StatelessWidget {
  final bool hasChildren;
  final List<Map<String, String>>? children;
  final VoidCallback? onAddChild;
  final VoidCallback? onViewAll;

  const ChildrenSectionWidget({
    super.key,
    required this.hasChildren,
    this.children,
    this.onAddChild,
    this.onViewAll,
  });

  static const List<Map<String, String>> _defaultChildren = [
    {
      'name': 'سارة',
      'photo': 'https://i.pravatar.cc/150?img=5',
      'status': 'في الطريق',
    },
    {
      'name': 'أحمد',
      'photo': 'https://i.pravatar.cc/150?img=12',
      'status': 'في المدرسة',
    },
    {
      'name': 'محمد',
      'photo': 'https://i.pravatar.cc/150?img=11',
      'status': 'ينتظر',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final currentChildren = children ?? _defaultChildren;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // هيدر القسم: "أطفالي" على اليمين و "عرض الكل" على اليسار
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'أطفالي',
                  style: AppTextStyles.style(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                if (!hasChildren) ...[
                  SizedBox(width: 8.w),
                  Text(
                    '(لا يوجد أطفال)',
                    style: AppTextStyles.style(
                      fontSize: 11.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
            if (hasChildren)
              InkWell(
                onTap: onViewAll ?? () => ParentMainWrapper.changeTab(1),
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Text(
                    'عرض الكل',
                    style: AppTextStyles.style(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 10.h),

        // 🟢 HAS CHILDREN: قائمة أفقية تحتوي على كروت الأطفال + كارد إضافة طفل في النهاية
        // ⚪ NO CHILDREN: عرض نفس كارد "إضافة طفل" الصغير فقط
        SizedBox(
          height: 118.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              if (hasChildren) ...[
                ...currentChildren.map(
                  (c) => _buildChildCard(
                    context,
                    name: c['name'] ?? '',
                    photo: c['photo'] ?? '',
                    status: c['status'] ?? 'في الطريق',
                    isDark: isDark,
                    primaryColor: primaryColor,
                  ),
                ),
              ],
              _buildAddChildCard(context, isDark, primaryColor),
            ],
          ),
        ),
      ],
    );
  }

  // كارد الطفل
  Widget _buildChildCard(
    BuildContext context, {
    required String name,
    required String photo,
    required String status,
    required bool isDark,
    required Color primaryColor,
  }) {
    Color statusColor = AppColors.success;
    if (status == 'ينتظر') statusColor = AppColors.amber;
    if (status == 'في المدرسة') statusColor = primaryColor;

    return Container(
      width: 92.w,
      margin: EdgeInsets.only(left: 10.w),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: isDark ? context.cardSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppUserAvatar(imageUrl: photo, radius: 22.r),
          SizedBox(height: 6.h),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.style(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6.r,
                height: 6.r,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                status,
                style: AppTextStyles.style(
                  fontSize: 9.sp,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ➕ كارد "إضافة طفل" الموحد
  Widget _buildAddChildCard(
    BuildContext context,
    bool isDark,
    Color primaryColor,
  ) {
    return InkWell(
      onTap:
          onAddChild ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddChildStep1Screen(),
              ),
            );
          },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 92.w,
        margin: EdgeInsets.only(left: 10.w),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: isDark ? context.cardSurface : AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: isDark ? 0.1 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, color: primaryColor, size: 22.r),
            ),
            SizedBox(height: 8.h),
            Text(
              'إضافة طفل',
              style: AppTextStyles.style(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
