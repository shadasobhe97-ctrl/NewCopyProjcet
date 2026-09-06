import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/profile/logic/cubit/parent_profile_cubit.dart';

class WelcomeHeaderWidget extends StatelessWidget {
  const WelcomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // قراءة اسم ولي الأمر من الكيوبت أو استخدام القيمة الافتراضية
    String firstName = '';
    try {
      final fullName = context.read<ParentProfileCubit>().getCachedFullName();
      if (fullName.isNotEmpty) {
        firstName = fullName.trim().split(' ').first;
      }
    } catch (_) {}

    final greetingText = firstName.isNotEmpty ? 'أهلاً بك، $firstName 👋' : 'أهلاً بك 👋';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greetingText,
            style: AppTextStyles.style(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.white : AppColors.textDark,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'نظّمي رحلات أطفالك بسهولة وأمان',
            style: AppTextStyles.style(
              fontSize: 12.sp,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
