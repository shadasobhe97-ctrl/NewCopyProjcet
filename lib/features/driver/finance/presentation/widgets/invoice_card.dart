import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/finance/data/models/invoice_model.dart';
import 'status_chip.dart';

class InvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;
  final VoidCallback? onTap;

  const InvoiceCard({super.key, required this.invoice, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${invoice.invoiceNumber}',
                        style: AppTextStyles.style(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.isDarkMode ? AppColors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusChip(status: invoice.statusLabel),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    invoice.parentName,
                    style: AppTextStyles.style(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${invoice.amount} د.ل',
                        style: AppTextStyles.style(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.isDarkMode ? AppColors.white : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        invoice.subscriptionType,
                        style: AppTextStyles.style(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded, color: AppColors.grey400, size: 24),
          ],
        ),
      ),
    );
  }
}
