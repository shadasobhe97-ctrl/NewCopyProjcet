import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';

class WalletBalanceCard extends StatelessWidget {
  final double balance;
  final String currency;
  final bool isLoading;

  const WalletBalanceCard({
    super.key,
    required this.balance,
    required this.currency,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      decoration: AppTheme.boxDecoration(
        gradient: AppTheme.linearGradient(
          colors: context.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          AppTheme.boxShadow(
            color: context.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'الرصيد الحالي',
            style: AppTextStyles.style(
              color: AppColors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const CircularProgressIndicator(color: AppColors.white)
          else
            Text(
              '$balance $currency',
              style: AppTextStyles.style(
                color: AppColors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
