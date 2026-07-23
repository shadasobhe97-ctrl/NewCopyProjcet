import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/finance/presentation/logic/finance_cubit.dart';
import 'package:kids_transport/features/driver/finance/presentation/widgets/invoice_card.dart';
import 'package:kids_transport/features/driver/finance/presentation/widgets/empty_finance_widget.dart';
import 'package:kids_transport/features/driver/finance/presentation/widgets/loading_finance_widget.dart';
import 'invoice_details_screen.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FinanceCubit>().loadInvoices();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('الفواتير'),
          backgroundColor: context.isDarkMode ? AppColors.surfaceDark : AppColors.white,
          foregroundColor: context.isDarkMode ? AppColors.white : AppColors.textDark,
          elevation: 0,
        ),
        body: BlocBuilder<FinanceCubit, FinanceState>(
          builder: (context, state) {
            if (state is FinanceLoading) {
              return const LoadingFinanceWidget();
            }
            if (state is FinanceInvoicesLoaded) {
              final invoices = state.invoices;
              if (invoices.isEmpty) {
                return const EmptyFinanceWidget(
                  message: 'لا توجد فواتير.',
                  icon: Icons.receipt_long_rounded,
                );
              }
              return RefreshIndicator(
                onRefresh: () => context.read<FinanceCubit>().loadInvoices(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) => InvoiceCard(
                    invoice: invoices[index],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<FinanceCubit>(),
                          child: InvoiceDetailsScreen(invoiceId: invoices[index].id),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
