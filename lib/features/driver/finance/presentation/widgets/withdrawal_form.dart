import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';

class WithdrawalForm extends StatefulWidget {
  final bool isSubmitting;
  final Function(Map<String, dynamic> body) onSubmit;

  const WithdrawalForm({
    super.key,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  State<WithdrawalForm> createState() => _WithdrawalFormState();
}

class _WithdrawalFormState extends State<WithdrawalForm> {
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

  void _submit() {
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

    widget.onSubmit(body);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'طلب سحب',
              style: AppTextStyles.style(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.isDarkMode ? AppColors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'اختر طريقة السحب',
              style: AppTextStyles.style(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            _methodOption('حساب مصرفي', 'bank'),
            const SizedBox(height: 4),
            _methodOption('ليبيانا', 'libyana'),
            const SizedBox(height: 20),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                hintText: 'أدخل المبلغ',
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'المبلغ مطلوب';
                final amount = double.tryParse(v);
                if (amount == null || amount <= 0) return 'أدخل مبلغ صحيح';
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (_method == 'bank') ...[
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
            ] else ...[
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: AppTheme.boxDecoration(
                  color: context.cardSurface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'ليبيانا',
                      style: AppTextStyles.style(
                        fontSize: 16,
                        color: context.isDarkMode ? AppColors.white : AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.isSubmitting ? null : _submit,
                child: widget.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                      )
                    : const Text('إرسال الطلب'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodOption(String label, String value) {
    final isSelected = _method == value;
    return GestureDetector(
      onTap: () => setState(() => _method = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: AppTheme.boxDecoration(
          color: isSelected
              ? context.primaryColor.withValues(alpha: 0.1)
              : context.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.primaryColor : AppColors.grey300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? context.primaryColor : AppColors.grey400,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.style(
                fontSize: 15,
                color: isSelected
                    ? (context.isDarkMode ? AppColors.white : AppColors.textDark)
                    : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
