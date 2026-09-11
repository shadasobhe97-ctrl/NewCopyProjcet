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
          countText = '';
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
            // ── هيدر القسم: أطفالي + عدد الأطفال + عرض الكل ──
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
                    if (countText.isNotEmpty) ...[
                      SizedBox(width: 6.w),
                      Text(
                        countText,
                        style: AppTextStyles.style(
                          fontSize: 11.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
                InkWell(
                  onTap: onViewAll ??
                      () => Navigator.pushNamed(context, AppRoutes.myChildren),
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
            SizedBox(height: 12.h),

            // ── قائمة أفقية بأسلوب الماسنجر (الأفاتار + الاسم فقط) ──
            SizedBox(
              height: 94.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1️⃣ زر إضافة طفل أولاً وثابت دائماً
                  _buildAddChildMessenger(context, isDark, primaryColor),

                  // 2️⃣ كروت الأطفال (صورة دائرية + اسم الطفل فقط)
                  ...childrenList.map(
                    (child) => _buildChildMessengerItem(
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

  // 🧒 عنصر الطفل بأسلوب الماسنجر: صورة دائرية + اسم الطفل فقط
  Widget _buildChildMessengerItem(
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
    final ringColor = isFemale ? AppColors.femalePink : primaryColor;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.childDataDetails,
        arguments: child,
      ),
      child: Container(
        width: 68.w,
        margin: EdgeInsets.only(left: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. الصورة الدائرية مع إطار أنيق
            Container(
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ringColor.withValues(alpha: 0.8),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ringColor.withValues(alpha: isDark ? 0.2 : 0.12),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AppUserAvatar(
                imageUrl: child.photoUrl,
                radius: 23.r,
                backgroundColor: avatarBgColor,
                iconColor: avatarIconColor,
              ),
            ),
            SizedBox(height: 6.h),

            // 2. اسم الطفل
            Text(
              firstName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ➕ زر إضافة طفل أول القائمة وثابت دائماً
  Widget _buildAddChildMessenger(
    BuildContext context,
    bool isDark,
    Color primaryColor,
  ) {
    void doAdd() {
      if (onAddChild != null) {
        onAddChild!();
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddChildStep1Screen(),
          ),
        );
      }
    }

    return GestureDetector(
      onTap: doAdd,
      child: Container(
        width: 68.w,
        margin: EdgeInsets.only(left: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // الدائرة الحاوية للأيقونة
            Container(
              width: 50.r,
              height: 50.r,
              decoration: BoxDecoration(
                color: isDark ? AppColors.grey900 : AppColors.primarySoft,
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.5),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.07),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.add_rounded,
                  color: primaryColor,
                  size: 24.r,
                ),
              ),
            ),
            SizedBox(height: 6.h),

            // نص إضافة طفل تحت الأيقونة
            Text(
              'إضافة طفل',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.primaryLight : primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}