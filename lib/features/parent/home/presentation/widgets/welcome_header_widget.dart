import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/profile/logic/cubit/parent_profile_cubit.dart';
import 'package:kids_transport/features/parent/profile/logic/cubit/parent_profile_state.dart';

class WelcomeHeaderWidget extends StatelessWidget {
  const WelcomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return BlocBuilder<ParentProfileCubit, ParentProfileState>(
      builder: (context, profileState) {
        String fullName = '';
        if (profileState is ParentProfileLoaded) {
          fullName = profileState.parent.fullName;
        } else if (profileState is ParentProfileSuccess) {
          fullName = profileState.parent.fullName;
        } else {
          try {
            fullName = context.read<ParentProfileCubit>().getCachedFullName();
          } catch (_) {}
        }

        final firstName = fullName.trim().isNotEmpty
            ? fullName.trim().split(' ').first
            : '';

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. النص الترحيبي
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // السطر الأول: الترحيب + الاسم
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'مرحباً',
                            style: AppTextStyles.style(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.white : AppColors.textDark,
                            ),
                          ),
                          if (firstName.isNotEmpty) ...[
                            TextSpan(
                              text: '، $firstName',
                              style: AppTextStyles.style(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? AppColors.primaryLight
                                    : primaryColor,
                              ),
                            ),
                          ],
                          TextSpan(
                            text: ' 👋',
                            style: TextStyle(fontSize: 20.sp),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5.h),

                    // السطر الثاني: رسالة قصيرة احترافية
                    Text(
                      'أطفالك بأمان — في كل رحلة، كل يوم',
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. شارة درب (لوغو صغير / بادج)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: AppColors.secondaryDark,
                      size: 14.r,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'دربي',
                      style: AppTextStyles.style(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
