import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/finance/presentation/logic/finance_cubit.dart';
import 'package:kids_transport/features/driver/finance/presentation/widgets/wallet_balance_card.dart';
import 'package:kids_transport/features/driver/finance/presentation/widgets/finance_summary_card.dart';
import 'package:kids_transport/features/driver/finance/presentation/widgets/withdrawal_form.dart';
import 'withdrawal_requests_screen.dart';
import 'invoices_screen.dart';

class FinanceDashboardScreen extends StatefulWidget {
  const FinanceDashboardScreen({super.key});

  @override
  State<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends State<FinanceDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FinanceCubit>().loadDashboard();
  }

  void _showWithdrawalSheet() {
    final state = context.read<FinanceCubit>().state;
    double balance = 0;
    if (state is FinanceDashboardLoaded) {
      balance = state.wallet.balance;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => BlocProvider.value(
        value: context.read<FinanceCubit>(),
        child: _WithdrawalSheetContent(balance: balance),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FinanceCubit, FinanceState>(
      listener: (context, state) {
        if (state is FinanceSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
          );
        } else if (state is FinanceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        if (state is FinanceLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FinanceDashboardLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                WalletBalanceCard(
                  balance: state.wallet.balance,
                  currency: state.wallet.currency,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: state.wallet.balance > 0 ? _showWithdrawalSheet : null,
                    icon: const Icon(Icons.arrow_upward_rounded),
                    label: const Text('طلب سحب'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    FinanceSummaryCard(
                      title: 'طلبات السحب',
                      value: '${state.withdrawals.length}',
                      icon: Icons.vertical_distribute_rounded,
                      iconColor: AppColors.pending,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<FinanceCubit>(),
                            child: const WithdrawalRequestsScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FinanceSummaryCard(
                      title: 'الفواتير',
                      value: '${state.invoices.length}',
                      icon: Icons.receipt_long_rounded,
                      iconColor: AppColors.info,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<FinanceCubit>(),
                            child: const InvoicesScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _WithdrawalSheetContent extends StatelessWidget {
  final double balance;
  const _WithdrawalSheetContent({required this.balance});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FinanceCubit, FinanceState>(
      listener: (context, state) {
        if (state is FinanceSuccess) {
          Navigator.pop(context);
          context.read<FinanceCubit>().loadDashboard();
        }
      },
      builder: (context, state) {
        final isSubmitting = state is FinanceSubmitting;
        return WithdrawalForm(
          isSubmitting: isSubmitting,
          onSubmit: (body) async {
            final cubit = context.read<FinanceCubit>();
            final success = await cubit.createWithdrawal(body);
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إرسال طلب السحب بنجاح'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
        );
      },
    );
  }
}
