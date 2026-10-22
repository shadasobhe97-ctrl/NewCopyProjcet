import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/profile/logic/cubit/parent_profile_cubit.dart';
import 'package:kids_transport/features/parent/profile/logic/cubit/parent_profile_state.dart';

class WelcomeHeaderWidget extends StatefulWidget {
  const WelcomeHeaderWidget({super.key});

  @override
  State<WelcomeHeaderWidget> createState() => _WelcomeHeaderWidgetState();
}

class _WelcomeHeaderWidgetState extends State<WelcomeHeaderWidget> {
  bool _isDismissed = false;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    // إخفاء رسالة الترحيب تلقائياً بعد 5 ثوانٍ كالـ Toast / الإشعار
    _dismissTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isDismissed = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState:
          _isDismissed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      secondChild: const SizedBox.shrink(),
      firstChild: BlocBuilder<ParentProfileCubit, ParentProfileState>(
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

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: EdgeInsets.only(bottom: 14.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isDark ? AppColors.grey800 : AppColors.grey200,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // أيقونة الترحيب
                Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '👋',
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // نصوص الترحيب
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'مرحباً',
                              style: AppTextStyles.style(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.white : AppColors.textDark,
                              ),
                            ),
                            if (firstName.isNotEmpty) ...[
                              TextSpan(
                                text: '، $firstName',
                                style: AppTextStyles.style(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.primaryLight : primaryColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'أطفالك بأمان — في كل رحلة، كل يوم',
                        style: AppTextStyles.style(
                          fontSize: 11.5.sp,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // زر الإغلاق X
                InkWell(
                  onTap: () {
                    _dismissTimer?.cancel();
                    setState(() {
                      _isDismissed = true;
                    });
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Padding(
                    padding: EdgeInsets.all(6.r),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18.r,
                      color: isDark ? AppColors.grey400 : AppColors.grey500,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
