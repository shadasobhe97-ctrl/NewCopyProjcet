import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/dashboard/presentation/screens/parent_main_wrapper.dart';

class QuickServicesWidget extends StatelessWidget {
  final VoidCallback? onAbsence;
  final VoidCallback? onWallet;
  final VoidCallback? onSubscriptions;

  const QuickServicesWidget({
    super.key,
    this.onAbsence,
    this.onWallet,
    this.onSubscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // أيقونات ملونة بألوان موجودة في ملف AppColors
    final List<Map<String, dynamic>> services = [
      {
        'title': 'الغياب',
        'subtitle': 'إدارة الغياب',
        'icon': Icons.calendar_month_outlined,
        'color': AppColors.pending,
        'action': onAbsence ?? () {},
      },
      {
        'title': 'المحفظة',
        'subtitle': 'الرصيد والدفع',
        'icon': Icons.account_balance_wallet_outlined,
        'color': AppColors.success,
        'action': onWallet ?? () => ParentMainWrapper.changeTab(3),
      },
      {
        'title': 'الاشتراكات',
        'subtitle': 'حالة الاشتراك',
        'icon': Icons.card_membership_rounded,
        'color': AppColors.accentBlue,
        'action': onSubscriptions ?? () => ParentMainWrapper.changeTab(3),
      },
      {
        'title': 'الشكاوى',
        'subtitle': 'سجل الشكاوى',
        'icon': Icons.report_problem_outlined,
        'color': AppColors.error,
        'action': () =>
            Navigator.pushNamed(context, AppRoutes.parentComplaints),
      },
      {
        'title': 'العناوين',
        'subtitle': 'العناوين المحفوظة',
        'icon': Icons.location_on_outlined,
        'color': AppColors.accentGreen,
        'action': () => Navigator.pushNamed(context, AppRoutes.savedAddresses),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الخدمات السريعة',
          style: AppTextStyles.style(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.white : AppColors.textDark,
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 118.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildServiceCard(
                context,
                title: service['title'] as String,
                subtitle: service['subtitle'] as String,
                icon: service['icon'] as IconData,
                color: service['color'] as Color,
                onTap: service['action'] as VoidCallback,
                isDark: isDark,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 108.w,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.grey900 : AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? AppColors.grey800 : AppColors.grey200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
                color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20.r,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.style(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.style(
                fontSize: 8.sp,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
