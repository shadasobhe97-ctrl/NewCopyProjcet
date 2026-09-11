import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// 🔍 ويدجت قسم البحث المباشر في الشاشة الرئيسية (القسم الثاني)
/// - حقل البحث بحدود دائرية كاملة وأيقونة بحث
/// - فاصل أنيق "أو"
/// - زر "بحث عن سائق مناسب" بحدود دائرية كاملة وباللون الأزرق الداكن المعتمد AppColors.primary
class HomeSearchSectionWidget extends StatelessWidget {
  final VoidCallback onTapSearch;
  final Function(String query)? onSubmitQuery;
  final VoidCallback? onTapSmartSearch;

  const HomeSearchSectionWidget({
    super.key,
    required this.onTapSearch,
    this.onSubmitQuery,
    this.onTapSmartSearch,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const primaryDarkBlue = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1️⃣ حقل البحث المباشر (حدود دائرية كاملة وأيقونة بحث)
        InkWell(
          onTap: onTapSearch,
          borderRadius: BorderRadius.circular(30.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: isDark ? AppColors.grey800 : AppColors.grey300,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  color: isDark ? AppColors.grey400 : AppColors.textMuted,
                  size: 22.r,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'ادخل اسم أو رقم السائق',
                    style: AppTextStyles.style(
                      fontSize: 13.sp,
                      color: isDark ? AppColors.grey400 : AppColors.textMuted,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(7.r),
                  decoration: BoxDecoration(
                    color: primaryDarkBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: primaryDarkBlue,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2️⃣ فاصل أنيق بكلمة "أو"
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  color: isDark ? AppColors.grey800 : AppColors.grey200,
                  thickness: 1,
                  indent: 24.w,
                  endIndent: 12.w,
                ),
              ),
              Text(
                'أو',
                style: AppTextStyles.style(
                  fontSize: 12.sp,
                  color: isDark ? AppColors.grey400 : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Divider(
                  color: isDark ? AppColors.grey800 : AppColors.grey200,
                  thickness: 1,
                  indent: 12.w,
                  endIndent: 24.w,
                ),
              ),
            ],
          ),
        ),

        // 3️⃣ زر CTA الأساسي: "بحث عن سائق مناسب" (حدود دائرية كاملة وباللون الأزرق الداكن)
        Container(
          height: 48.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: primaryDarkBlue.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: onTapSmartSearch ?? onTapSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryDarkBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'بحث عن سائق مناسب',
                  style: AppTextStyles.style(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
