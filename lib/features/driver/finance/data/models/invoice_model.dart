import 'parsers.dart';

class InvoiceModel {
  final int id;
  final String invoiceNumber;
  final String parentName;
  final double amount;
  final String subscriptionType;
  final String dueDate;
  final String status;
  final String? paidDate;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.parentName,
    required this.amount,
    required this.subscriptionType,
    required this.dueDate,
    required this.status,
    this.paidDate,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final parent = json['parent'] as Map<String, dynamic>?;

    return InvoiceModel(
      id: parseInt(json['id']),
      invoiceNumber: json['invoice_number'] as String? ?? '',
      parentName: parent?['name'] as String? ?? json['parent_name'] as String? ?? '',
      amount: parseDouble(json['amount']),
      subscriptionType: json['subscription_type'] as String? ?? '',
      dueDate: json['due_date'] as String? ?? '',
      status: json['status'] as String? ?? '',
      paidDate: json['paid_at'] as String? ?? json['paid_date'] as String?,
    );
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'مدفوعة';
      case 'overdue':
        return 'متأخرة';
      default:
        return 'غير مدفوعة';
    }
  }
}
