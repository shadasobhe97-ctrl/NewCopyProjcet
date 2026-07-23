import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/finance/presentation/logic/finance_cubit.dart';
import 'package:kids_transport/features/driver/finance/presentation/widgets/wallet_balance_card.dart';
import 'package:kids_transport/features/driver/finance/presentation/widgets/finance_summary_card.dart';
import 'package:kids_transport/features/driver/shared/di/driver_injection.dart';
import 'withdrawal_requests_screen.dart';
import 'invoices_screen.dart';
import 'create_withdrawal_screen.dart';

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

  Future<void> _openWithdrawalScreen() async {
    final state = context.read<FinanceCubit>().state;
    double balance = 0;
    if (state is FinanceDashboardLoaded) {
      balance = state.wallet.balance;
    }

    final success = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => driverSl<FinanceCubit>(),
          child: CreateWithdrawalScreen(balance: balance),
        ),
      ),
    );
    if (success == true && mounted) {
      context.read<FinanceCubit>().loadDashboard();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال طلب السحب بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    }
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
          return RefreshIndicator(
            onRefresh: () => context.read<FinanceCubit>().loadDashboard(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
              children: [
                WalletBalanceCard(
                  balance: state.wallet.balance,
                  currency: state.wallet.currency,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: AppTheme.boxDecoration(
                    color: state.wallet.balance > 0
                        ? (context.isDarkMode ? AppColors.surfaceDark : AppColors.maleBlueBg)
                        : AppColors.grey100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: state.wallet.balance > 0 ? AppColors.maleBlue : AppColors.grey300,
                      width: 1.5,
                    ),
                    boxShadow: state.wallet.balance > 0
                        ? [
                            AppTheme.boxShadow(
                              color: AppColors.maleBlue.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: state.wallet.balance > 0 ? _openWithdrawalScreen : null,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              color: state.wallet.balance > 0 ? AppColors.maleBlue : AppColors.grey500,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'طلب سحب',
                              style: AppTextStyles.style(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: state.wallet.balance > 0 ? AppColors.maleBlue : AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                          builder: (_) => BlocProvider(
                            create: (_) => driverSl<FinanceCubit>(),
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
                          builder: (_) => BlocProvider(
                            create: (_) => driverSl<FinanceCubit>(),
                            child: const InvoicesScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        }
        if (state is FinanceError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: AppTextStyles.style(fontSize: 14, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<FinanceCubit>().loadDashboard(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}


