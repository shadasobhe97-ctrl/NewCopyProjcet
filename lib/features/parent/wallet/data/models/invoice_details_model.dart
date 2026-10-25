import 'package:kids_transport/core/utils/subscription_enums.dart';
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
    if (json['driver_name'] != null && json['driver_name'].toString().trim().isNotEmpty) {
      dName = json['driver_name'].toString().trim();
    } else if (json['driver'] != null && json['driver'] is Map) {
      final dMap = json['driver'] as Map;
      final user = dMap['user'];
      if (user != null && user is Map) {
        dName = user['full_name']?.toString().trim() ?? user['name']?.toString().trim();
      }
      dName ??= dMap['full_name']?.toString().trim() ?? dMap['name']?.toString().trim();
    }

    if ((dName == null || dName.isEmpty) && json['contract'] != null && json['contract'] is Map) {
      final contract = json['contract'] as Map;
      if (contract['driver'] != null && contract['driver'] is Map) {
        final cDriver = contract['driver'] as Map;
        final cUser = cDriver['user'];
        if (cUser != null && cUser is Map) {
          dName = cUser['full_name']?.toString().trim() ?? cUser['name']?.toString().trim();
        }
        dName ??= cDriver['full_name']?.toString().trim() ?? cDriver['name']?.toString().trim();
      }
      dName ??= contract['driver_name']?.toString().trim();
    }

    if ((dName == null || dName.isEmpty) && json['subscription'] != null && json['subscription'] is Map) {
      final sub = json['subscription'] as Map;
      if (sub['driver'] != null && sub['driver'] is Map) {
        final sDriver = sub['driver'] as Map;
        final sUser = sDriver['user'];
        if (sUser != null && sUser is Map) {
          dName = sUser['full_name']?.toString().trim() ?? sUser['name']?.toString().trim();
        }
        dName ??= sDriver['full_name']?.toString().trim() ?? sDriver['name']?.toString().trim();
      }
      dName ??= sub['driver_name']?.toString().trim();
    }

    String? pName;
    if (json['parent_name'] != null && json['parent_name'].toString().trim().isNotEmpty) {
      pName = json['parent_name'].toString().trim();
    } else if (json['parent'] != null && json['parent'] is Map) {
      final pMap = json['parent'] as Map;
      final user = pMap['user'];
      if (user != null && user is Map) {
        pName = user['full_name']?.toString().trim() ?? user['name']?.toString().trim();
      }
      pName ??= pMap['full_name']?.toString().trim() ?? pMap['name']?.toString().trim();
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
      subscriptionType: json['subscription_type_label']?.toString() ?? json['subscription_type']?.toString(),
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

  String get subscriptionTypeDisplayLabel =>
      SubscriptionEnums.typeLabel(subscriptionType);
}
