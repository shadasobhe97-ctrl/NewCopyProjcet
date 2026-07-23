import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/finance/presentation/logic/finance_cubit.dart';
import 'package:kids_transport/features/driver/finance/presentation/widgets/status_chip.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final int invoiceId;
  const InvoiceDetailsScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FinanceCubit>().loadInvoiceDetails(widget.invoiceId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('تفاصيل الفاتورة'),
          backgroundColor: context.isDarkMode ? AppColors.surfaceDark : AppColors.white,
          foregroundColor: context.isDarkMode ? AppColors.white : AppColors.textDark,
          elevation: 0,
        ),
        body: BlocBuilder<FinanceCubit, FinanceState>(
          builder: (context, state) {
            if (state is FinanceLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FinanceInvoiceDetailsLoaded) {
              final d = state.details;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoCard(
                      children: [
                        _InfoRow(label: 'رقم الفاتورة', value: '#${d.invoiceNumber}'),
                        _InfoRow(label: 'ولي الأمر', value: d.parentName),
                        _InfoRow(label: 'المبلغ', value: '${d.amount} د.ل'),
                        _InfoRow(label: 'نوع الاشتراك', value: d.subscriptionType),
                        _InfoRow(
                          label: 'الحالة',
                          valueWidget: StatusChip(status: d.statusLabel),
                        ),
                        _InfoRow(label: 'تاريخ الاستحقاق', value: d.dueDate),
                        if (d.paidDate != null)
                          _InfoRow(label: 'تاريخ الدفع', value: d.paidDate!),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(
                      title: 'الرحلات',
                      children: [
                        _InfoRow(label: 'عدد الرحلات', value: '${d.totalTrips}'),
                        _InfoRow(label: 'الرحلات المكتملة', value: '${d.completedTrips}'),
                        _InfoRow(label: 'غياب السائق', value: '${d.driverAbsences}'),
                        _InfoRow(label: 'غياب الطالب', value: '${d.studentAbsences}'),
                      ],
                    ),
                    if (d.contract != null) ...[
                      const SizedBox(height: 16),
                      _InfoCard(
                        title: 'العقد',
                        children: [
                          _InfoRow(label: 'رقم العقد', value: d.contract!.contractNumber),
                          _InfoRow(
                            label: 'حالة العقد',
                            valueWidget: StatusChip(status: _contractLabel(d.contract!.status)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  String _contractLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _InfoCard({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          if (title != null) ...[
            Text(
              title!,
              style: AppTextStyles.style(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.isDarkMode ? AppColors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _InfoRow({required this.label, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.style(fontSize: 14, color: AppColors.textMuted),
          ),
          if (valueWidget != null)
            valueWidget!
          else
            Text(
              value ?? '',
              style: AppTextStyles.style(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.isDarkMode ? AppColors.white : AppColors.textDark,
              ),
            ),
        ],
      ),
    );
  }
}
