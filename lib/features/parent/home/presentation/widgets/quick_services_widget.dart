import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/dashboard/presentation/screens/parent_main_wrapper.dart';
import 'package:kids_transport/features/parent/trips/presentation/screens/trip_tracking_screen.dart';

class QuickServicesWidget extends StatelessWidget {
  final VoidCallback? onTrackCurrentTrip;
  final VoidCallback? onAbsence;
  final VoidCallback? onWallet;
  final VoidCallback? onSubscriptions;

  const QuickServicesWidget({
    super.key,
    this.onTrackCurrentTrip,
    this.onAbsence,
    this.onWallet,
    this.onSubscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    // تم تعديل المسميات والأيقونات لتكون موحدة وبسيطة
    final List<Map<String, dynamic>> services = [
      {
        'title': 'تتبع الرحلة',
        'subtitle': 'موقع الحافلة',
        'icon': Icons.location_on_outlined,
        'action':
            onTrackCurrentTrip ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TripTrackingScreen(),
                ),
              );
            },
      },
      {
        'title': 'الغياب',
        'subtitle': 'إدارة الغياب',
        'icon': Icons.calendar_month_outlined,
        'action': onAbsence ?? () {},
      },
      {
        'title': 'المحفظة',
        'subtitle': 'الرصيد والدفع',
        'icon': Icons.account_balance_wallet_outlined,
        'action': onWallet ?? () => ParentMainWrapper.changeTab(3),
      },
      {
        'title': 'الاشتراكات',
        'subtitle': 'حالة الاشتراك',
        'icon': Icons.card_membership_rounded,
        'action': onSubscriptions ?? () => ParentMainWrapper.changeTab(3),
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
        Row(
          children: services.map((service) {
            return Expanded(
              child: _buildServiceCard(
                context,
                title: service['title'] as String,
                subtitle: service['subtitle'] as String,
                icon: service['icon'] as IconData,
                onTap: service['action'] as VoidCallback,
                isDark: isDark,
                primaryColor: primaryColor,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 3.5.w),
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
                // لون موحد خفيف للخلفية
                color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                // لون موحد للأيقونة
                color: primaryColor,
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
