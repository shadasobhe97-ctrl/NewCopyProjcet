import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/finance/presentation/logic/finance_cubit.dart';

class CreateWithdrawalScreen extends StatefulWidget {
  final double balance;
  const CreateWithdrawalScreen({super.key, required this.balance});

  @override
  State<CreateWithdrawalScreen> createState() => _CreateWithdrawalScreenState();
}

class _CreateWithdrawalScreenState extends State<CreateWithdrawalScreen> {
  String _method = 'bank';
  final _amountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    _bankNameController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    final Map<String, dynamic> body;
    if (_method == 'bank') {
      body = {
        'amount': amount,
        'payment_method_details': {
          'bank_name': _bankNameController.text,
          'account_number': _accountNumberController.text,
          'account_name': _accountNameController.text,
        },
      };
    } else {
      body = {
        'amount': amount,
        'payment_method_details': {
          'mobile_number': _mobileNumberController.text,
          'bank_name': 'ليبيانا',
        },
      };
    }

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
                    const SizedBox(height: 20),
                    _buildMethodSection(isDark),
                    const SizedBox(height: 20),
                    if (_method == 'bank') _buildBankFields(isDark) else _buildLibyanaFields(isDark),
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

  Widget _buildMethodSection(bool isDark) {
    return Container(
      width: double.infinity,
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
            'طريقة السحب',
            style: AppTextStyles.style(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.isDarkMode ? AppColors.white : AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _methodOption('حساب مصرفي', 'bank', isDark)),
              const SizedBox(width: 12),
              Expanded(child: _methodOption('ليبيانا', 'libyana', isDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _methodOption(String label, String value, bool isDark) {
    final isSelected = _method == value;
    return GestureDetector(
      onTap: () => setState(() => _method = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: AppTheme.boxDecoration(
          color: isSelected
              ? context.primaryColor.withValues(alpha: 0.1)
              : (isDark ? AppColors.surfaceDark : AppColors.grey100),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? context.primaryColor : AppColors.grey200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              value == 'bank' ? Icons.account_balance_rounded : Icons.phone_android_rounded,
              color: isSelected ? context.primaryColor : AppColors.textMuted,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.style(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (isDark ? AppColors.white : AppColors.textDark)
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankFields(bool isDark) {
    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Icon(Icons.account_balance_rounded, size: 18, color: context.primaryColor),
              const SizedBox(width: 8),
              Text(
                'بيانات الحساب المصرفي',
                style: AppTextStyles.style(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.isDarkMode ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _bankNameController,
            decoration: const InputDecoration(
              labelText: 'اسم المصرف',
              hintText: 'أدخل اسم المصرف',
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'اسم المصرف مطلوب' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _accountNameController,
            decoration: const InputDecoration(
              labelText: 'اسم صاحب الحساب',
              hintText: 'أدخل اسم صاحب الحساب',
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'اسم صاحب الحساب مطلوب' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _accountNumberController,
            decoration: const InputDecoration(
              labelText: 'رقم الحساب',
              hintText: 'أدخل رقم الحساب',
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'رقم الحساب مطلوب' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLibyanaFields(bool isDark) {
    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Icon(Icons.phone_android_rounded, size: 18, color: context.primaryColor),
              const SizedBox(width: 8),
              Text(
                'بيانات ليبيانا',
                style: AppTextStyles.style(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.isDarkMode ? AppColors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _mobileNumberController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              hintText: 'أدخل رقم الهاتف',
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'رقم الهاتف مطلوب' : null,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: AppTheme.boxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success, size: 22),
                const SizedBox(width: 10),
                Text(
                  'سيتم الإرسال عبر ليبيانا',
                  style: AppTextStyles.style(
                    fontSize: 14,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
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
