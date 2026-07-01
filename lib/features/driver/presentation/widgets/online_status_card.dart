import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/features/driver/logic/driver_home_cubit/driver_home_cubit.dart';

class OnlineStatusCard extends StatelessWidget {
  final bool isOnline;

  const OnlineStatusCard({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppTheme.radius(20),
        border: AppTheme.border(
          color: isOnline
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.grey.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          AppTheme.boxShadow(
            color: isOnline
                ? AppColors.success.withValues(alpha: 0.1)
                : AppColors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة الحالة
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: AppTheme.boxDecoration(
              color: isOnline
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              color: isOnline ? AppColors.success : AppColors.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // النص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'أنت الآن متصل' : 'أنت الآن غير متصل',
                  style: AppTextStyles.style(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isOnline ? AppColors.success : AppColors.textMuted,
                  ),
                ),
                Text(
                  isOnline
                      ? 'يمكنك الآن استقبال الطلبات'
                      : 'فعّل وضع الاتصال لاستقبال الطلبات',
                  style: AppTextStyles.style(
                    fontSize: 12,
                    color: AppColors.textMuted.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          // مفتاح التبديل
          Transform.scale(
            scale: 1.1,
            child: Switch.adaptive(
              value: isOnline,
              activeThumbColor: AppColors.success,
              activeTrackColor: AppColors.success.withValues(alpha: 0.4),
              inactiveThumbColor: AppColors.grey400,
              inactiveTrackColor: AppColors.grey.withValues(alpha: 0.2),
              onChanged: (val) {
                context.read<DriverHomeCubit>().toggleOnlineStatus();
              },
            ),
          ),
        ],
      ),
    );
  }
}
