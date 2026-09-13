class RechargeMockPayResponseModel {
  final String status;
  final String message;
  final String transactionRef;
  final num amount;
  final String currency;
  final num currentBalance;
  final RechargeInvoiceRef? invoice;

  RechargeMockPayResponseModel({
    required this.status,
    required this.message,
    required this.transactionRef,
    required this.amount,
    required this.currency,
    required this.currentBalance,
    required this.invoice,
  });

  factory RechargeMockPayResponseModel.fromJson(Map<String, dynamic> json) {
    return RechargeMockPayResponseModel(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      transactionRef: json['transaction_ref']?.toString() ?? '',
      amount: (json['amount'] as num?) ?? 0,
      currency: json['currency']?.toString() ?? '',
      currentBalance: (json['current_balance'] as num?) ?? 0,
      invoice: json['invoice'] is Map<String, dynamic>
          ? RechargeInvoiceRef.fromJson(json['invoice'] as Map<String, dynamic>)
          : null,
    );
  }
}

class RechargeInvoiceRef {
  final int id;
  final String invoiceNumber;
  final String? paidAt;

  RechargeInvoiceRef({
    required this.id,
    required this.invoiceNumber,
    required this.paidAt,
  });

  factory RechargeInvoiceRef.fromJson(Map<String, dynamic> json) {
    return RechargeInvoiceRef(
      id: (json['id'] as num?)?.toInt() ?? 0,
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      paidAt: json['paid_at']?.toString(),
    );
  }
}
