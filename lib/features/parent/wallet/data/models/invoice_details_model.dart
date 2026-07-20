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
    required this.dueDate,
    this.subscriptionType,
    required this.totalTrips,
    required this.completedTrips,
    required this.driverAbsences,
    required this.studentAbsences,
    required this.calculatedAmount,
    this.actionTaken,
    this.paidAt,
    required this.createdAt,
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
        dName = user['full_name'];
      }
    }

    String? pName;
    if (json['parent'] != null && json['parent'] is Map) {
      final user = json['parent']['user'];
      if (user != null && user is Map) {
        pName = user['full_name'];
      }
    }

    String? cNumber;
    String? cStatus;
    if (json['contract'] != null && json['contract'] is Map) {
      cNumber = json['contract']['contract_number'];
      cStatus = json['contract']['status'];
    }

    return InvoiceDetailsModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      dueDate: json['due_date'] ?? '',
      subscriptionType: json['subscription_type'],
      totalTrips: json['total_trips'] ?? 0,
      completedTrips: json['completed_trips'] ?? 0,
      driverAbsences: json['driver_absences'] ?? 0,
      studentAbsences: json['student_absences'] ?? 0,
      calculatedAmount: (json['calculated_amount'] ?? 0).toDouble(),
      actionTaken: json['action_taken'],
      paidAt: json['paid_at'],
      createdAt: json['created_at'] ?? '',
      contractNumber: cNumber,
      contractStatus: cStatus,
      driverName: dName,
      parentName: pName,
    );
  }
}
