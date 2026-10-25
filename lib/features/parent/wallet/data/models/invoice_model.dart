import 'package:kids_transport/core/utils/subscription_enums.dart';
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

    return InvoiceModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      dueDate: json['due_date']?.toString() ?? '',
      completedTrips: json['completed_trips'] as int?,
      subscriptionType: json['subscription_type_label']?.toString() ?? json['subscription_type']?.toString(),
      driverName: dName,
    );
  }

  String get subscriptionTypeDisplayLabel =>
      SubscriptionEnums.typeLabel(subscriptionType);

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
