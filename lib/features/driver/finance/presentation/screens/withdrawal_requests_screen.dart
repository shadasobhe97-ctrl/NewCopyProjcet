import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/finance/presentation/logic/finance_cubit.dart';
import 'package:kids_transport/features/driver/finance/presentation/widgets/withdrawal_card.dart';
import 'package:kids_transport/features/driver/finance/presentation/widgets/empty_finance_widget.dart';
import 'package:kids_transport/features/driver/finance/presentation/widgets/loading_finance_widget.dart';

class WithdrawalRequestsScreen extends StatefulWidget {
  const WithdrawalRequestsScreen({super.key});

  @override
  State<WithdrawalRequestsScreen> createState() => _WithdrawalRequestsScreenState();
}

class _WithdrawalRequestsScreenState extends State<WithdrawalRequestsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FinanceCubit>().loadWithdrawals();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('طلبات السحب'),
          backgroundColor: context.isDarkMode ? AppColors.surfaceDark : AppColors.white,
          foregroundColor: context.isDarkMode ? AppColors.white : AppColors.textDark,
          elevation: 0,
        ),
        body: BlocBuilder<FinanceCubit, FinanceState>(
          builder: (context, state) {
            if (state is FinanceLoading) {
              return const LoadingFinanceWidget();
            }
            if (state is FinanceWithdrawalsLoaded) {
              final withdrawals = state.withdrawals;
              if (withdrawals.isEmpty) {
                return const EmptyFinanceWidget(
                  message: 'لا توجد طلبات سحب.',
                  icon: Icons.vertical_distribute_rounded,
                );
              }
              return RefreshIndicator(
                onRefresh: () => context.read<FinanceCubit>().loadWithdrawals(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: withdrawals.length,
                  itemBuilder: (context, index) =>
                      WithdrawalCard(withdrawal: withdrawals[index]),
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
