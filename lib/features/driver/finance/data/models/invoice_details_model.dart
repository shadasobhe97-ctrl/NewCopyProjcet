import 'contract_model.dart';
import 'parsers.dart';

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
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    final parent = data['parent'] as Map<String, dynamic>?;

    return InvoiceDetailsModel(
      id: parseInt(data['id']),
      invoiceNumber: data['invoice_number'] as String? ?? '',
      parentName: parent?['name'] as String? ?? data['parent_name'] as String? ?? '',
      amount: parseDouble(data['amount']),
      subscriptionType: data['subscription_type'] as String? ?? '',
      dueDate: data['due_date'] as String? ?? '',
      status: data['status'] as String? ?? '',
      paidDate: data['paid_at'] as String? ?? data['paid_date'] as String?,
      totalTrips: parseInt(data['total_trips']),
      completedTrips: parseInt(data['completed_trips']),
      driverAbsences: parseInt(data['driver_absences']),
      studentAbsences: parseInt(data['student_absences']),
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
