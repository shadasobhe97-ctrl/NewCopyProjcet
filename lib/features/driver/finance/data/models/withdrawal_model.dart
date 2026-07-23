import 'dart:convert';
import 'parsers.dart';

class WithdrawalModel {
  final int id;
  final double amount;
  final String method;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;

  WithdrawalModel({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    final rawDetails = json['payment_method_details'];
    String method = '';

    if (rawDetails is String) {
      try {
        final detailsMap = jsonDecode(rawDetails) as Map<String, dynamic>;
        final bankName = detailsMap['bank_name'] as String? ?? '';
        method = bankName == 'ليبيانا' ? 'ليبيانا' : 'حساب مصرفي';
      } catch (_) {
        method = rawDetails;
      }
    } else if (rawDetails is Map) {
      final bankName = rawDetails['bank_name'] as String? ?? '';
      method = bankName == 'ليبيانا' ? 'ليبيانا' : 'حساب مصرفي';
    }

    return WithdrawalModel(
      id: parseInt(json['id']),
      amount: parseDouble(json['amount']),
      method: method,
      status: json['status'] as String? ?? '',
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'قيد الانتظار';
    }
  }
}
