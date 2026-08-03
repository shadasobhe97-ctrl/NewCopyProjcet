import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/app_user_avatar.dart';
import '../../data/models/active_trip_model.dart';
import 'online_badge.dart';

class DriverCard extends StatelessWidget {
  final DriverInfo driver;
  final bool isOnline;
  final VoidCallback? onCallPressed;
  final VoidCallback? onChatPressed;

  const DriverCard({
    super.key,
    required this.driver,
    this.isOnline = true,
    this.onCallPressed,
    this.onChatPressed,
  });

  void _defaultCall(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('مكالمة السائق: ${driver.phone}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _defaultChat(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('مراسلة السائق: ${driver.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.grey900 : AppColors.grey50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? AppColors.grey800 : AppColors.grey200,
        ),
      ),
      child: Row(
        children: [
          AppUserAvatar(
            imageUrl: driver.photo,
            radius: 24.r,
            backgroundColor: context.primaryColor.withValues(alpha: 0.1),
            iconColor: context.primaryColor,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      driver.name.isNotEmpty ? driver.name : 'سائق الحافلة',
                      style: AppTextStyles.style(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    OnlineBadge(isOnline: isOnline),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  driver.phone.isNotEmpty ? driver.phone : 'رقم الهاتف غير متاح',
                  style: AppTextStyles.style(
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (driver.phone.isNotEmpty) ...[
            // 📞 Call Action
            CircleAvatar(
              radius: 18.r,
              backgroundColor: AppColors.success.withValues(alpha: 0.15),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => onCallPressed != null
                    ? onCallPressed!()
                    : _defaultCall(context),
                icon: const Icon(
                  Icons.phone_rounded,
                  color: AppColors.success,
                  size: 18,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // 💬 Chat Action
            CircleAvatar(
              radius: 18.r,
              backgroundColor: context.primaryColor.withValues(alpha: 0.15),
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => onChatPressed != null
                    ? onChatPressed!()
                    : _defaultChat(context),
                icon: Icon(
                  Icons.chat_bubble_rounded,
                  color: context.primaryColor,
                  size: 18,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
