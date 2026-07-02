import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';

/// هيدر تفاصيل الطفل في شاشة ChildDetailScreen.
/// يعرض أفاتار الطفل، الاسم، وبيدج حالة الحضور.
class ChildDetailHeader extends StatelessWidget {
  final ChildModel child;

  const ChildDetailHeader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isMale = child.gender == 'MALE';
    final isPresent = child.dailyStatus == DailyStatus.present;

    return Container(
      decoration: AppTheme.boxDecoration(
        gradient: AppTheme.linearGradient(
          colors: [AppColors.primaryLight, AppColors.primaryGradientEnd],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // أفاتار الطفل
            Container(
              decoration: AppTheme.boxDecoration(
                shape: BoxShape.circle,
                border: AppTheme.border(color: AppColors.white, width: 3),
                boxShadow: [
                  AppTheme.boxShadow(
                    color: AppColors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.white.withValues(alpha: 0.2),
                backgroundImage:
                    child.photoUrl != null
                        ? NetworkImage(child.photoUrl!)
                        : null,
                child: child.photoUrl == null
                    ? Icon(
                        isMale ? Icons.boy_rounded : Icons.girl_rounded,
                        color: AppColors.white,
                        size: 48,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              child.fullName,
              style: AppTextStyles.style(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            // بيدج الحضور
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: AppTheme.boxDecoration(
                color: (isPresent ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.25),
                borderRadius: AppTheme.radius(20),
                border: AppTheme.border(
                  color: isPresent ? AppColors.success : AppColors.error,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPresent
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    size: 14,
                    color: isPresent ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isPresent ? 'حاضر اليوم' : 'غائب اليوم',
                    style: AppTextStyles.style(
                      color: isPresent ? AppColors.success : AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
