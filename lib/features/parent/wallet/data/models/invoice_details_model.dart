class InvoiceDetailsModel {
  final int id;
  final String invoiceNumber;
  final double amount;
  final String type;
  final String status;
  final String dueDate;
  final String? subscriptionType;
  final int totalTrips;
  final int completedTrips;
  final int driverAbsences;
  final int studentAbsences;
  final double calculatedAmount;
  final String? actionTaken;
  final String? paidAt;
  final String createdAt;

  // Contract info
  final String? contractNumber;
  final String? contractStatus;

  // Driver & Parent info
  final String? driverName;
  final String? parentName;

  InvoiceDetailsModel({
    required this.id,
    required this.invoiceNumber,
    required this.amount,
    required this.type,
    required this.status,
    this.dueDate = '',
    this.subscriptionType,
    required this.totalTrips,
    required this.completedTrips,
    required this.driverAbsences,
    required this.studentAbsences,
    this.calculatedAmount = 0.0,
    this.actionTaken,
    this.paidAt,
    this.createdAt = '',
    this.contractNumber,
    this.contractStatus,
    this.driverName,
    this.parentName,
  });

  factory InvoiceDetailsModel.fromJson(Map<String, dynamic> json) {
    String? dName;
    if (json['driver'] != null && json['driver'] is Map) {
      final user = json['driver']['user'];
      if (user != null && user is Map) {
        dName = user['full_name']?.toString();
      }
    }

    String? pName;
    if (json['parent'] != null && json['parent'] is Map) {
      final user = json['parent']['user'];
      if (user != null && user is Map) {
        pName = user['full_name']?.toString();
      }
    }

    String? cNumber;
    String? cStatus;
    if (json['contract'] != null && json['contract'] is Map) {
      cNumber = json['contract']['contract_number']?.toString();
      cStatus = json['contract']['status']?.toString();
    }

    return InvoiceDetailsModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      subscriptionType: json['subscription_type']?.toString(),
      totalTrips: (json['total_trips'] as num?)?.toInt() ?? 0,
      completedTrips: (json['completed_trips'] as num?)?.toInt() ?? 0,
      driverAbsences: (json['driver_absences'] as num?)?.toInt() ?? 0,
      studentAbsences: (json['student_absences'] as num?)?.toInt() ?? 0,
      calculatedAmount: (json['calculated_amount'] as num?)?.toDouble() ?? (json['amount'] as num?)?.toDouble() ?? 0.0,
      actionTaken: json['action_taken']?.toString(),
      paidAt: json['paid_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      contractNumber: cNumber,
      contractStatus: cStatus,
      driverName: dName,
      parentName: pName,
    );
  }
}
