import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/finance/logic/cubit/finance_cubit.dart';
import 'package:kids_transport/features/driver/finance/logic/state/finance_state.dart';

class CreateWithdrawalScreen extends StatefulWidget {
  final double balance;
  const CreateWithdrawalScreen({super.key, required this.balance});

  @override
  State<CreateWithdrawalScreen> createState() => _CreateWithdrawalScreenState();
}

class _CreateWithdrawalScreenState extends State<CreateWithdrawalScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount < 50 || amount > widget.balance) return;

    final body = {'amount': amount};

    final success = await context.read<FinanceCubit>().createWithdrawal(body);
    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('طلب سحب'),
          backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
          foregroundColor: isDark ? AppColors.white : AppColors.textDark,
          elevation: 0,
        ),
        body: BlocConsumer<FinanceCubit, FinanceState>(
          listener: (context, state) {
            if (state is FinanceSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is FinanceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is FinanceSubmitting;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildBalanceCard(isDark),
                    const SizedBox(height: 16),
                    _buildAmountField(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(isSubmitting),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalanceCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: AppTheme.boxDecoration(
        gradient: AppTheme.linearGradient(
          colors: [context.primaryColor, context.primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          AppTheme.boxShadow(
            color: context.primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance_wallet_rounded, color: AppColors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الرصيد المتاح',
                style: AppTextStyles.style(color: AppColors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.balance} د.ل',
                style: AppTextStyles.style(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.boxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          AppTheme.boxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المبلغ',
            style: AppTextStyles.style(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? AppColors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'أدخل المبلغ',
              prefixText: 'د.ل  ',
              prefixStyle: AppTextStyles.style(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.isDarkMode ? AppColors.white : AppColors.textDark,
              ),
            ),
            style: AppTextStyles.style(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? AppColors.white : AppColors.textDark,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'المبلغ مطلوب';
              final amount = double.tryParse(v);
              if (amount == null || amount <= 0) return 'أدخل مبلغ صحيح';
              if (amount > widget.balance) return 'المبلغ يتجاوز الرصيد المتاح';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isSubmitting) {
    return Container(
      width: double.infinity,
      decoration: AppTheme.boxDecoration(
        gradient: AppTheme.linearGradient(
          colors: [context.primaryColor, context.primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          AppTheme.boxShadow(
            color: context.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSubmitting ? null : _submit,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSubmitting) ...[
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                  ),
                  const SizedBox(width: 10),
                ] else ...[
                  const Icon(Icons.send_rounded, color: AppColors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  isSubmitting ? 'جاري الإرسال...' : 'إرسال الطلب',
                  style: AppTextStyles.style(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
