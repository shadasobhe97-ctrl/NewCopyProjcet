class InvoiceModel {
  final int id;
  final String invoiceNumber;
  final double amount;
  final String type;
  final String status;
  final String dueDate;
  final int? completedTrips;
  final String? subscriptionType;
  final String? driverName;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.amount,
    required this.type,
    required this.status,
    required this.dueDate,
    this.completedTrips,
    this.subscriptionType,
    this.driverName,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    String? dName;
    if (json['driver'] != null && json['driver'] is Map) {
      final user = json['driver']['user'];
      if (user != null && user is Map) {
        dName = user['full_name']?.toString();
      }
    }

    return InvoiceModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      completedTrips: json['completed_trips'] as int?,
      subscriptionType: json['subscription_type']?.toString(),
      driverName: dName,
    );
  }

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
        return status;
    }
  }
}
