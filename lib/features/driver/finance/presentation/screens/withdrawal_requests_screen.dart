import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
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
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<FinanceCubit>().loadWithdrawals();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: withdrawals.length + (state.hasMore || state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == withdrawals.length) {
                      return _buildLoaderOrButton(state);
                    }
                    return WithdrawalCard(withdrawal: withdrawals[index]);
                  },
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
                        onPressed: () => context.read<FinanceCubit>().loadWithdrawals(),
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
        ),
      ),
    );
  }

  Widget _buildLoaderOrButton(FinanceWithdrawalsLoaded state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.read<FinanceCubit>().loadMoreWithdrawals(),
            icon: const Icon(Icons.expand_more_rounded),
            label: const Text('عرض المزيد'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: BorderSide(color: context.primaryColor),
              foregroundColor: context.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
