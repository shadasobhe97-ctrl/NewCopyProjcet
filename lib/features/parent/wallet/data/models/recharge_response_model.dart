import 'package:kids_transport/features/parent/wallet/data/models/payment_method_model.dart';

class RechargeInitiateResponseModel {
  final int rechargeId;
  final String transactionRef;
  final String sessionToken;
  final num amount;
  final String currency;
  final RechargeInitiatePaymentMethod? paymentMethod;
  final String? mockGatewayUrl;
  final int? expiresInMinutes;

  RechargeInitiateResponseModel({
    required this.rechargeId,
    required this.transactionRef,
    required this.sessionToken,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.mockGatewayUrl,
    required this.expiresInMinutes,
  });

  factory RechargeInitiateResponseModel.fromJson(Map<String, dynamic> json) {
    return RechargeInitiateResponseModel(
      rechargeId: (json['recharge_id'] as num?)?.toInt() ?? 0,
      transactionRef: json['transaction_ref']?.toString() ?? '',
      sessionToken: json['session_token']?.toString() ?? '',
      amount: (json['amount'] as num?) ?? 0,
      currency: json['currency']?.toString() ?? '',
      paymentMethod: json['payment_method'] is Map<String, dynamic>
          ? RechargeInitiatePaymentMethod.fromJson(
              json['payment_method'] as Map<String, dynamic>)
          : null,
      mockGatewayUrl: json['mock_gateway_url']?.toString(),
      expiresInMinutes: (json['expires_in_minutes'] as num?)?.toInt(),
    );
  }
}

class RechargeInitiatePaymentMethod {
  final int? id;
  final String? nameAr;
  final String? code;
  final String? iconUrl;

  RechargeInitiatePaymentMethod({
    required this.id,
    required this.nameAr,
    required this.code,
    required this.iconUrl,
  });

  factory RechargeInitiatePaymentMethod.fromJson(Map<String, dynamic> json) {
    return RechargeInitiatePaymentMethod(
      id: (json['id'] as num?)?.toInt(),
      nameAr: json['name_ar']?.toString(),
      code: json['code']?.toString(),
      iconUrl: PaymentMethodModel.resolveIconUrl(json['icon_url']?.toString()),
    );
  }
}
