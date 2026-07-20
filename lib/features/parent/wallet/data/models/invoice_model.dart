class InvoiceModel {
  final int id;
  final String invoiceNumber;
  final double amount;
  final String type;
  final String status;
  final String dueDate;
  final String? subscriptionType;
  final String? driverName;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.amount,
    required this.type,
    required this.status,
    required this.dueDate,
    this.subscriptionType,
    this.driverName,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    // Handling nested driver to extract driverName if available
    String? dName;
    if (json['driver'] != null && json['driver'] is Map) {
      final user = json['driver']['user'];
      if (user != null && user is Map) {
        dName = user['full_name'];
      }
    }

    return InvoiceModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      dueDate: json['due_date'] ?? '',
      subscriptionType: json['subscription_type'],
      driverName: dName,
    );
  }

  // Helper method for display status
  String get statusDisplayLabel {
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
}
