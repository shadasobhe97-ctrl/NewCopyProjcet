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
    return InvoiceModel(
      id: json['id'] as int? ?? 0,
      invoiceNumber: json['invoice_number'] as String? ?? '',
      parentName: json['parent_name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      subscriptionType: json['subscription_type'] as String? ?? '',
      dueDate: json['due_date'] as String? ?? '',
      status: json['status'] as String? ?? '',
      paidDate: json['paid_date'] as String?,
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
