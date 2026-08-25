import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_user_avatar.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';
import 'package:kids_transport/features/parent/children/logic/children_cubit/children_cubit.dart';
import 'package:kids_transport/features/parent/children/presentation/screens/add_child_step1_screen.dart';
import 'package:kids_transport/features/parent/dashboard/presentation/screens/parent_main_wrapper.dart';

class ChildrenSectionWidget extends StatelessWidget {
  final VoidCallback? onAddChild;
  final VoidCallback? onViewAll;

  const ChildrenSectionWidget({
    super.key,
    this.onAddChild,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return BlocBuilder<ChildrenCubit, ChildrenState>(
      builder: (context, state) {
        List<ChildModel> childrenList = [];
        if (state is ChildrenLoaded) {
          childrenList = state.children;
        } else if (state is ChildrenActionLoading) {
          childrenList = state.children;
        } else if (state is ChildrenActionSuccess) {
          childrenList = state.children;
        } else if (state is ChildrenActionError) {
          childrenList = state.children;
        }

        final count = childrenList.length;

        String countText;
        if (count == 0) {
          countText = '(لا يوجد أطفال)';
        } else if (count == 1) {
          countText = '(طفل واحد)';
        } else if (count == 2) {
          countText = '(طفلان)';
        } else {
          countText = '($count أطفال)';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // هيدر القسم: "أطفالي" وعدد الأطفال على اليمين و "عرض الكل" على اليسار
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
                        color: isDark ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      countText,
                      style: AppTextStyles.style(
                        fontSize: 11.sp,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: onViewAll ?? () => ParentMainWrapper.changeTab(1),
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
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

            // قائمة أفقية: كارد "إضافة طفل" ثابت على اليمين (Index 0)، يليه كروت الأطفال
            SizedBox(
              height: 120.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1️⃣ كارد "إضافة طفل" - ثابت دائماً في البداية (جهة اليمين)
                  _buildAddChildCard(context, isDark, primaryColor),

                  // 2️⃣ كروت الأطفال المسجلين (الصورة واسم الطفل الأول فقط)
                  ...childrenList.map(
                    (child) => _buildChildCard(
                      context,
                      child: child,
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // كارد الطفل (عرض الاسم الأول والصورة فقط)
  Widget _buildChildCard(
    BuildContext context, {
    required ChildModel child,
    required bool isDark,
    required Color primaryColor,
  }) {
    final firstName = child.fullName.trim().isNotEmpty
        ? child.fullName.trim().split(' ').first
        : 'طفل';

    final isFemale = child.gender == 'female';
    final avatarBgColor = isFemale ? context.femalePinkBg : context.maleBlueBg;
    final avatarIconColor =
        isFemale ? context.genderFemaleColor : context.genderMaleColor;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.childDataDetails,
          arguments: child,
        );
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 92.w,
        margin: EdgeInsets.only(left: 10.w),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey900 : AppColors.white,
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
            AppUserAvatar(
              imageUrl: child.photoUrl,
              radius: 22.r,
              backgroundColor: avatarBgColor,
              iconColor: avatarIconColor,
            ),
            SizedBox(height: 8.h),
            Text(
              firstName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.style(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
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
      onTap: onAddChild ??
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
          color: isDark ? AppColors.grey900 : AppColors.white,
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
              child: Icon(
                Icons.add_rounded,
                color: primaryColor,
                size: 22.r,
              ),
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