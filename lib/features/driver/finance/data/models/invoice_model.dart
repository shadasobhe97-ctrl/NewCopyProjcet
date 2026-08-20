import 'parsers.dart';

class InvoiceModel {
  final int id;
  final String invoiceNumber;
  final String? parentName;
  final double amount;
  final String type;
  final String? subscriptionType;
  final int completedTrips;
  final String dueDate;
  final String status;
  final String? paidDate;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    this.parentName,
    required this.amount,
    required this.type,
    this.subscriptionType,
    required this.completedTrips,
    required this.dueDate,
    required this.status,
    this.paidDate,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final parent = json['parent'] as Map<String, dynamic>?;

    return InvoiceModel(
      id: parseInt(json['id']),
      invoiceNumber: json['invoice_number'] as String? ?? '',
      parentName: parent?['name'] as String? ?? json['parent_name'] as String?,
      amount: parseDouble(json['amount']),
      type: json['type'] as String? ?? 'final',
      subscriptionType: json['subscription_type'] as String?,
      completedTrips: json['completed_trips'] != null ? parseInt(json['completed_trips']) : 0,
      dueDate: json['due_date'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
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

  String get typeLabel {
    switch (type.toLowerCase()) {
      case 'final':
        return 'نهائية';
      case 'advance':
        return 'مقدمة';
      default:
        return type;
    }
  }
}
