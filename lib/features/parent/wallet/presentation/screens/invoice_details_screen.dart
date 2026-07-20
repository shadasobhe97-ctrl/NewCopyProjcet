import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/parent/shared/di/parent_injection.dart';
import 'package:kids_transport/features/parent/wallet/logic/invoice_details_cubit/invoice_details_cubit.dart';
import 'package:kids_transport/features/parent/wallet/logic/invoice_details_cubit/invoice_details_state.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final int invoiceId;
  const InvoiceDetailsScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<InvoiceDetailsCubit>()..loadInvoiceDetails(invoiceId),
      child: const _InvoiceDetailsScreenContent(),
    );
  }
}

class _InvoiceDetailsScreenContent extends StatelessWidget {
  const _InvoiceDetailsScreenContent();

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

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'بانتظار الدفع';
      case 'paid':
        return 'مدفوعة';
      case 'overdue':
        return 'متأخرة';
      case 'cancelled':
        return 'ملغية';
      default:
        return 'غير معروف';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'تفاصيل الفاتورة',
          style: AppTextStyles.style(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: context.surfaceColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<InvoiceDetailsCubit, InvoiceDetailsState>(
        builder: (context, state) {
          if (state is InvoiceDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is InvoiceDetailsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message,
                      style: AppTextStyles.style(color: context.errorColor)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('رجوع'),
                  )
                ],
              ),
            );
          } else if (state is InvoiceDetailsLoaded) {
            final invoice = state.invoice;
            final statusColor = _getStatusColor(context, invoice.status);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // بطاقة الفاتورة الأساسية
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.boxDecoration(
                      color: context.primaryColor,
                      borderRadius: AppTheme.radius(16),
                      boxShadow: [
                        BoxShadow(
                          color: context.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'رقم الفاتورة',
                          style: AppTextStyles.style(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invoice.invoiceNumber,
                          style: AppTextStyles.style(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'المبلغ',
                                  style: AppTextStyles.style(
                                      color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${invoice.amount.toStringAsFixed(2)} د.ل',
                                  style: AppTextStyles.style(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'الحالة',
                                  style: AppTextStyles.style(
                                      color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getStatusLabel(invoice.status),
                                    style: AppTextStyles.style(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'تاريخ الاستحقاق',
                              style: AppTextStyles.style(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            Text(
                              invoice.dueDate,
                              style: AppTextStyles.style(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // بيانات العقد والسائق
                  _buildSectionCard(
                    context: context,
                    title: 'بيانات العقد والسائق',
                    children: [
                      _buildInfoRow(context, 'رقم العقد',
                          invoice.contractNumber ?? 'غير متوفر'),
                      const Divider(),
                      _buildInfoRow(context, 'حالة العقد',
                          invoice.contractStatus ?? 'غير متوفر',
                          isStatus: true),
                      const Divider(),
                      _buildInfoRow(
                          context, 'السائق', invoice.driverName ?? 'غير متوفر'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // معلومات الفاتورة
                  _buildSectionCard(
                    context: context,
                    title: 'معلومات الفاتورة',
                    children: [
                      _buildInfoRow(context, 'نوع الفاتورة', invoice.type),
                      const Divider(),
                      _buildInfoRow(context, 'نوع الاشتراك',
                          invoice.subscriptionType ?? 'غير متوفر'),
                      const Divider(),
                      _buildInfoRow(context, 'المبلغ المحسوب',
                          '${invoice.calculatedAmount.toStringAsFixed(2)} د.ل'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // تفاصيل الرحلات والغياب
                  _buildSectionCard(
                    context: context,
                    title: 'تفاصيل الرحلات',
                    children: [
                      _buildInfoRow(context, 'إجمالي الرحلات المحددة',
                          invoice.totalTrips.toString()),
                      const Divider(),
                      _buildInfoRow(context, 'الرحلات المنجزة',
                          invoice.completedTrips.toString()),
                      const Divider(),
                      _buildInfoRow(context, 'غياب السائق',
                          invoice.driverAbsences.toString()),
                      const Divider(),
                      _buildInfoRow(context, 'غياب الطالب',
                          invoice.studentAbsences.toString()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // التواريخ
                  _buildSectionCard(
                    context: context,
                    title: 'معلومات إضافية',
                    children: [
                      _buildInfoRow(context, 'الإجراء المتخذ',
                          invoice.actionTaken ?? 'لا يوجد'),
                      const Divider(),
                      _buildInfoRow(
                          context, 'تاريخ الإصدار', invoice.createdAt),
                      const Divider(),
                      _buildInfoRow(
                          context, 'تاريخ الدفع', invoice.paidAt ?? '—'),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: AppTheme.boxDecoration(
        color: context.isDarkMode ? AppColors.darkSurface : Colors.white,
        borderRadius: AppTheme.radius(16),
        border: AppTheme.border(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: AppTextStyles.style(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.primaryColor,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String title, String value,
      {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.style(
              fontSize: 14,
              color: context.textMuted,
            ),
          ),
          isStatus
              ? Text(
                  value,
                  style: AppTextStyles.style(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: value.toLowerCase() == 'active' || value == 'نشط'
                        ? context.successColor
                        : context.textPrimary,
                  ),
                )
              : Text(
                  value,
                  style: AppTextStyles.style(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
        ],
      ),
    );
  }
}
