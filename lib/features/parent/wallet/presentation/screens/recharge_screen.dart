import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/primary_button.dart';
import 'package:kids_transport/core/widgets/custom_text_field.dart';
import 'package:kids_transport/features/parent/wallet/data/models/payment_method_model.dart';
import 'package:kids_transport/features/parent/wallet/logic/wallet_cubit/wallet_cubit.dart';
import 'package:kids_transport/features/parent/wallet/logic/wallet_cubit/wallet_state.dart';

class RechargeScreen extends StatefulWidget {
  const RechargeScreen({super.key});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedMethodId;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: context.surfaceColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_rounded, color: context.successColor, size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              'تم إرسال طلب الشحن بنجاح',
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.style(
                fontSize: 14,
                color: context.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'حسناً',
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      appBar: AppBar(
        title: Text(
          'شحن المحفظة',
          style: AppTextStyles.style(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: context.surfaceColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<WalletCubit, WalletState>(
        listener: (context, state) {
          if (state is WalletRechargeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.errorColor,
              ),
            );
          } else if (state is WalletRechargeSuccess) {
            _showSuccessDialog(state.message);
          }
        },
        builder: (context, state) {
          if (state is WalletLoaded) {
            final methods = state.paymentMethods;
            PaymentMethodModel? selectedMethod;
            if (_selectedMethodId != null) {
              selectedMethod = methods.firstWhere(
                (m) => m.id == _selectedMethodId,
                orElse: () => methods.first,
              );
            } else if (methods.isNotEmpty) {
              _selectedMethodId = methods.first.id;
              selectedMethod = methods.first;
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المبلغ',
                      style: AppTextStyles.style(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _amountController,
                      hintText: 'أدخل المبلغ',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      prefixIcon: Icons.attach_money_rounded,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'يرجى إدخال المبلغ';
                        if (double.tryParse(val) == null || double.parse(val) <= 0) {
                          return 'يرجى إدخال مبلغ صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'اختر طريقة الدفع',
                      style: AppTextStyles.style(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...methods.map((method) {
                      final isSelected = _selectedMethodId == method.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedMethodId = method.id;
                              _referenceController.clear();
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: AppTheme.boxDecoration(
                              color: isSelected
                                  ? context.primaryColor.withValues(alpha: 0.05)
                                  : Colors.transparent,
                              borderRadius: AppTheme.radius(12),
                              border: AppTheme.border(
                                color: isSelected ? context.primaryColor : context.dividerColor,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? context.primaryColor : context.dividerColor,
                                      width: 2,
                                    ),
                                    color: isSelected ? context.primaryColor : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        method.name,
                                        style: AppTextStyles.style(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: context.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        method.description,
                                        style: AppTextStyles.style(
                                          fontSize: 12,
                                          color: context.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (selectedMethod != null && selectedMethod.instructions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: AppTheme.boxDecoration(
                          color: context.scaffoldBackgroundColor,
                          borderRadius: AppTheme.radius(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تعليمات التحويل',
                              style: AppTextStyles.style(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: context.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...selectedMethod.instructions.map((inst) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('•', style: TextStyle(fontSize: 16)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          inst,
                                          style: AppTextStyles.style(
                                            fontSize: 13,
                                            color: context.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                    if (selectedMethod != null && selectedMethod.requiresReference) ...[
                      const SizedBox(height: 24),
                      Text(
                        'رقم الإحالة',
                        style: AppTextStyles.style(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _referenceController,
                        hintText: 'أدخل رقم الإحالة',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'يرجى إدخال رقم الإحالة';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 40),
                    PrimaryButton(
                      label: 'إرسال طلب الشحن',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (selectedMethod != null) {
                            context.read<WalletCubit>().rechargeWallet(
                                  amount: double.parse(_amountController.text),
                                  paymentMethod: selectedMethod.id,
                                  referenceNumber: selectedMethod.requiresReference
                                      ? _referenceController.text.trim()
                                      : null,
                                );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          } else if (state is WalletRecharging) {
            return const Center(child: CircularProgressIndicator());
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
