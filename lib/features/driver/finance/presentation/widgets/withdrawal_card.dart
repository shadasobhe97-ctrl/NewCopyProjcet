import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/finance/data/models/withdrawal_model.dart';
import 'status_chip.dart';

class WithdrawalCard extends StatelessWidget {
  final WithdrawalModel withdrawal;

  const WithdrawalCard({super.key, required this.withdrawal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: AppTheme.boxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          AppTheme.boxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${withdrawal.amount} د.ل',
                style: AppTextStyles.style(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.isDarkMode ? AppColors.white : AppColors.textDark,
                ),
              ),
              StatusChip(status: withdrawal.statusLabel),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.account_balance_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                withdrawal.method,
                style: AppTextStyles.style(fontSize: 13, color: AppColors.textMuted),
              ),
              const Spacer(),
              Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                _formatDate(withdrawal.createdAt),
                style: AppTextStyles.style(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
          if (withdrawal.status.toLowerCase() == 'rejected' &&
              withdrawal.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: AppTheme.boxDecoration(
                color: AppColors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.red, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      withdrawal.rejectionReason!,
                      style: AppTextStyles.style(
                        fontSize: 12,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
