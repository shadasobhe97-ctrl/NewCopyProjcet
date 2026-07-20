import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/parent/shared/di/parent_injection.dart';
import 'package:kids_transport/features/parent/wallet/data/models/invoice_model.dart';
import 'package:kids_transport/features/parent/wallet/logic/invoices_cubit/invoices_cubit.dart';
import 'package:kids_transport/features/parent/wallet/logic/invoices_cubit/invoices_state.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<InvoicesCubit>()..loadInvoices(),
      child: const _InvoicesScreenContent(),
    );
  }
}

class _InvoicesScreenContent extends StatelessWidget {
  const _InvoicesScreenContent();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.surfaceColor,
        appBar: AppBar(
          title: Text(
            'الفواتير',
            style: AppTextStyles.style(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: context.surfaceColor,
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: context.primaryColor,
            labelColor: context.primaryColor,
            unselectedLabelColor: context.textMuted,
            labelStyle:
                AppTextStyles.style(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'الكل'),
              Tab(text: 'بانتظار الدفع'),
              Tab(text: 'مدفوعة'),
            ],
          ),
        ),
        body: BlocBuilder<InvoicesCubit, InvoicesState>(
          builder: (context, state) {
            if (state is InvoicesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is InvoicesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message,
                        style: AppTextStyles.style(color: context.errorColor)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<InvoicesCubit>().loadInvoices(),
                      child: const Text('إعادة المحاولة'),
                    )
                  ],
                ),
              );
            } else if (state is InvoicesLoaded) {
              final allInvoices = state.invoices;
              final pendingInvoices = allInvoices
                  .where((i) => i.status.toLowerCase() == 'pending')
                  .toList();
              final paidInvoices = allInvoices
                  .where((i) => i.status.toLowerCase() == 'paid')
                  .toList();

              return TabBarView(
                children: [
                  _InvoicesList(invoices: allInvoices),
                  _InvoicesList(invoices: pendingInvoices),
                  _InvoicesList(invoices: paidInvoices),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _InvoicesList extends StatelessWidget {
  final List<InvoiceModel> invoices;

  const _InvoicesList({required this.invoices});

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: 80,
              color: context.dividerColor,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد فواتير حالياً',
              style: AppTextStyles.style(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر فواتيرك هنا عند إصدارها',
              style: AppTextStyles.style(
                fontSize: 14,
                color: context.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: invoices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return _InvoiceCard(invoice: invoice);
      },
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;

  const _InvoiceCard({required this.invoice});

  Color _getStatusColor(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return context.pendingColor;
      case 'paid':
        return context.successColor;
      case 'overdue':
        return context.errorColor;
      default:
        return context.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context, invoice.status);

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.parentInvoiceDetails,
            arguments: invoice.id);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.boxDecoration(
          color: context.isDarkMode ? AppColors.darkSurface : Colors.white,
          borderRadius: AppTheme.radius(16),
          border: AppTheme.border(color: context.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${invoice.amount.toStringAsFixed(2)} د.ل',
                        style: AppTextStyles.style(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        invoice.invoiceNumber,
                        style: AppTextStyles.style(
                          fontSize: 13,
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: AppTheme.boxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: AppTheme.radius(8),
                        ),
                        child: Text(
                          invoice.statusDisplayLabel,
                          style: AppTextStyles.style(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                      Text(
                        'تاريخ الاستحقاق: ${invoice.dueDate}',
                        style: AppTextStyles.style(
                          fontSize: 12,
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: context.textMuted),
          ],
        ),
      ),
    );
  }
}
