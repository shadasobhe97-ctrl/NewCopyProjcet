import 'contract_model.dart';

class InvoiceDetailsModel {
  final int id;
  final String invoiceNumber;
  final String parentName;
  final double amount;
  final String subscriptionType;
  final String dueDate;
  final String status;
  final String? paidDate;
  final int totalTrips;
  final int completedTrips;
  final int driverAbsences;
  final int studentAbsences;
  final ContractModel? contract;

  InvoiceDetailsModel({
    required this.id,
    required this.invoiceNumber,
    required this.parentName,
    required this.amount,
    required this.subscriptionType,
    required this.dueDate,
    required this.status,
    this.paidDate,
    required this.totalTrips,
    required this.completedTrips,
    required this.driverAbsences,
    required this.studentAbsences,
    this.contract,
  });

  factory InvoiceDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] : json;
    return InvoiceDetailsModel(
      id: data['id'] as int? ?? 0,
      invoiceNumber: data['invoice_number'] as String? ?? '',
      parentName: data['parent_name'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      subscriptionType: data['subscription_type'] as String? ?? '',
      dueDate: data['due_date'] as String? ?? '',
      status: data['status'] as String? ?? '',
      paidDate: data['paid_date'] as String?,
      totalTrips: data['total_trips'] as int? ?? 0,
      completedTrips: data['completed_trips'] as int? ?? 0,
      driverAbsences: data['driver_absences'] as int? ?? 0,
      studentAbsences: data['student_absences'] as int? ?? 0,
      contract: data['contract'] != null
          ? ContractModel.fromJson(data['contract'] as Map<String, dynamic>)
          : null,
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
