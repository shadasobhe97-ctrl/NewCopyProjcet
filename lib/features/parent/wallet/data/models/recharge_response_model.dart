class RechargeResponseModel {
  final int id;
  final int parentId;
  final String amount;
  final String paymentMethod;
  final String? referenceNumber;
  final String status;
  final String? notes;
  final String createdAt;

  RechargeResponseModel({
    required this.id,
    required this.parentId,
    required this.amount,
    required this.paymentMethod,
    this.referenceNumber,
    required this.status,
    this.notes,
    this.createdAt = '',
  });

  factory RechargeResponseModel.fromJson(Map<String, dynamic> json) {
    return RechargeResponseModel(
      id: json['id'] ?? 0,
      parentId: json['parent_id'] ?? 0,
      amount: json['amount']?.toString() ?? '0.0',
      paymentMethod: json['payment_method']?.toString() ?? '',
      referenceNumber: json['reference_number']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
