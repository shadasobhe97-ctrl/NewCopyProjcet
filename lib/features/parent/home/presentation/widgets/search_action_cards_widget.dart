import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/search/presentation/screens/parent_search_screen.dart';

class SearchActionCardsWidget extends StatelessWidget {
  final VoidCallback? onQuickSearchTap;

  const SearchActionCardsWidget({
    super.key,
    this.onQuickSearchTap,
  });

  void _navigateToSubscriptionSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ParentSearchScreen(),
      ),
    );
  }

  void _showQuickSearchModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.grey900 : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.grey700 : AppColors.grey300,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flash_on_rounded,
                        color: AppColors.secondaryDark,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'البحث السريع لليوم',
                            style: AppTextStyles.style(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.white : AppColors.textDark,
                            ),
                          ),
                          Text(
                            'البحث عن أقرب سائق متاح حالياً للتوصيل اليوم',
                            style: AppTextStyles.style(
                              fontSize: 11.sp,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.grey800.withValues(alpha: 0.5)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: primaryColor,
                        size: 20.r,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'سيتم البحث عن السائقين القريبين من موقعك المتاحين للتوصيل الفوري اليوم.',
                          style: AppTextStyles.style(
                            fontSize: 11.sp,
                            color: isDark ? AppColors.white : AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _navigateToSubscriptionSearch(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'ابدئي البحث الفوري',
                      style: AppTextStyles.style(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final darkerPrimary = Color.lerp(primaryColor, Colors.black, 0.2)!;

    return Column(
      children: [
        // 1️⃣ Card الرئيسية: البحث عن سائق للاشتراك
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [darkerPrimary, primaryColor],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: isDark ? 0.3 : 0.2),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(18.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'اشتراك الفصل / السنة',
                        style: AppTextStyles.style(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.search_rounded,
                      color: AppColors.white.withValues(alpha: 0.6),
                      size: 22.r,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  'البحث عن سائق',
                  style: AppTextStyles.style(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'ابحثي عن سائق مناسب لاشتراك أطفالك',
                  style: AppTextStyles.style(
                    fontSize: 11.5.sp,
                    color: AppColors.white.withValues(alpha: 0.88),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 38.h,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToSubscriptionSearch(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      elevation: 0,
                    ),
                    icon: Icon(
                      Icons.search_rounded,
                      size: 16.r,
                      color: primaryColor,
                    ),
                    label: Text(
                      'ابدئي البحث',
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // 2️⃣ Card الثانوية: البحث السريع لليوم
        InkWell(
          onTap: () {
            if (onQuickSearchTap != null) {
              onQuickSearchTap!();
            } else {
              _showQuickSearchModal(context);
            }
          },
          borderRadius: BorderRadius.circular(18.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.grey900 : AppColors.white,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: AppColors.secondaryDark.withValues(alpha: isDark ? 0.6 : 0.4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryDark.withValues(alpha: isDark ? 0.15 : 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: isDark ? 0.25 : 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flash_on_rounded,
                    color: AppColors.secondaryDark,
                    size: 22,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '⚡ تحتاجين سائق اليوم؟',
                            style: AppTextStyles.style(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.white : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'سنبحث عن أقرب سائق متاح الآن',
                        style: AppTextStyles.style(
                          fontSize: 10.5.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'البحث السريع',
                    style: AppTextStyles.style(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSecondary,
                    ),
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
