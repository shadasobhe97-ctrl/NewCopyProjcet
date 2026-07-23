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
    return WithdrawalModel(
      id: json['id'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: json['payment_method'] as String? ?? '',
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
