import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../data/models/driver_statistics_model.dart';

class EarningsSummaryCard extends StatelessWidget {
  final FinancialStatsModel financialStats;

  const EarningsSummaryCard({
    super.key,
    required this.financialStats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final net = financialStats.netEarnings;
    final pending = financialStats.pendingAndDue;
    final currency = pending.currency;

    final isUp = net.growthTrend.toLowerCase() == 'up';
    final isDown = net.growthTrend.toLowerCase() == 'down';

    final trendColor = isUp
        ? AppColors.success
        : (isDown ? AppColors.error : AppColors.grey500);

    final trendIcon = isUp
        ? Icons.trending_up_rounded
        : (isDown ? Icons.trending_down_rounded : Icons.trending_flat_rounded);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.88)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 16.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.white,
                      size: 22.r,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'صافي الأرباح',
                    style: AppTextStyles.style(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: trendColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(trendIcon, color: AppColors.white, size: 15.r),
                    SizedBox(width: 4.w),
                    Text(
                      '${net.growthPercentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.style(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            '${_formatMoney(net.currentMonth)} $currency',
            style: AppTextStyles.style(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'أرباح الشهر الحالي',
            style: AppTextStyles.style(
              fontSize: 12.sp,
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _subEarningsItem(
                    'الإجمالي التراكمي',
                    '${_formatMoney(net.total)} $currency',
                  ),
                ),
                Container(
                  height: 32.h,
                  width: 1.w,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                Expanded(
                  child: _subEarningsItem(
                    'الشهر السابق',
                    '${_formatMoney(net.previousMonth)} $currency',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoPill(
                Icons.hourglass_top_rounded,
                'الأرباح المتوقعة:',
                '${_formatMoney(financialStats.expectedActiveEarnings)} $currency',
              ),
              _infoPill(
                Icons.account_balance_outlined,
                'رصيد المحفظة:',
                '${_formatMoney(pending.walletBalance)} $currency',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _subEarningsItem(String title, String amount) {
    return Column(
      children: [
        Text(
          title,
          style: AppTextStyles.style(
            fontSize: 11.sp,
            color: AppColors.white.withValues(alpha: 0.75),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          amount,
          style: AppTextStyles.style(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _infoPill(IconData icon, String label, String value) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.white.withValues(alpha: 0.85), size: 14.r),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyles.style(
              fontSize: 11.sp,
              color: AppColors.white.withValues(alpha: 0.75),
            ),
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.style(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMoney(double v) {
    return v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
  }
}
