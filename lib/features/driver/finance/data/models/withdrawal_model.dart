import 'dart:convert';
import 'parsers.dart';

class PaymentMethodDetails {
  final String bankName;
  final String accountNumber;
  final String? accountName;

  PaymentMethodDetails({
    required this.bankName,
    required this.accountNumber,
    this.accountName,
  });

  factory PaymentMethodDetails.fromJson(dynamic json) {
    if (json == null) {
      return PaymentMethodDetails(bankName: '', accountNumber: '');
    }
    if (json is String) {
      try {
        final map = jsonDecode(json) as Map<String, dynamic>;
        return PaymentMethodDetails.fromJson(map);
      } catch (_) {
        return PaymentMethodDetails(bankName: json, accountNumber: '');
      }
    }
    if (json is Map<String, dynamic>) {
      return PaymentMethodDetails(
        bankName: json['bank_name'] as String? ?? json['bankName'] as String? ?? '',
        accountNumber: json['account_number'] as String? ?? json['accountNumber'] as String? ?? '',
        accountName: json['account_name'] as String? ?? json['accountName'] as String?,
      );
    }
    return PaymentMethodDetails(bankName: json.toString(), accountNumber: '');
  }

  Map<String, dynamic> toJson() => {
        'bank_name': bankName,
        'account_number': accountNumber,
        if (accountName != null) 'account_name': accountName,
      };
}

class WithdrawalModel {
  final int id;
  final int? driverId;
  final double amount;
  final double? walletBalanceAtRequest;
  final String method;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;
  final PaymentMethodDetails? paymentMethodDetails;

  WithdrawalModel({
    required this.id,
    this.driverId,
    required this.amount,
    this.walletBalanceAtRequest,
    required this.method,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    this.paymentMethodDetails,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    final rawDetails = json['payment_method_details'];
    PaymentMethodDetails? details;
    String methodStr = '';

    if (rawDetails != null) {
      details = PaymentMethodDetails.fromJson(rawDetails);
      methodStr = details.bankName.isNotEmpty ? details.bankName : 'حساب مصرفي';
    } else {
      methodStr = json['method'] as String? ?? 'حساب مصرفي';
    }

    DateTime parsedDate;
    if (json['created_at'] != null) {
      parsedDate = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return WithdrawalModel(
      id: parseInt(json['id']),
      driverId: json['driver_id'] != null ? parseInt(json['driver_id']) : null,
      amount: parseDouble(json['amount']),
      walletBalanceAtRequest: json['wallet_balance_at_request'] != null
          ? parseDouble(json['wallet_balance_at_request'])
          : null,
      method: methodStr,
      status: json['status'] as String? ?? 'pending',
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: parsedDate,
      paymentMethodDetails: details,
    );
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'completed':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return 'قيد الانتظار';
    }
  }
}
