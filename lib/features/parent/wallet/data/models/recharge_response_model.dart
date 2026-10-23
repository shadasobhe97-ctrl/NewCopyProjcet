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

  RechargeInitiateResponseModel copyWith({
    int? rechargeId,
    String? transactionRef,
    String? sessionToken,
    num? amount,
    String? currency,
    RechargeInitiatePaymentMethod? paymentMethod,
    String? mockGatewayUrl,
    int? expiresInMinutes,
  }) {
    return RechargeInitiateResponseModel(
      rechargeId: rechargeId ?? this.rechargeId,
      transactionRef: transactionRef ?? this.transactionRef,
      sessionToken: sessionToken ?? this.sessionToken,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      mockGatewayUrl: mockGatewayUrl ?? this.mockGatewayUrl,
      expiresInMinutes: expiresInMinutes ?? this.expiresInMinutes,
    );
  }

  factory RechargeInitiateResponseModel.fromJson(Map<String, dynamic> json) {
    RechargeInitiatePaymentMethod? method;
    if (json['payment_method'] is Map<String, dynamic>) {
      method = RechargeInitiatePaymentMethod.fromJson(
          json['payment_method'] as Map<String, dynamic>);
    } else if (json['payment_method'] is String) {
      method = RechargeInitiatePaymentMethod(
        id: null,
        nameAr: json['payment_method']?.toString(),
        code: null,
        iconUrl: null,
      );
    } else if (json['name_ar'] != null) {
      method = RechargeInitiatePaymentMethod.fromJson(json);
    }

    return RechargeInitiateResponseModel(
      rechargeId: (json['recharge_id'] as num?)?.toInt() ?? 0,
      transactionRef: json['transaction_ref']?.toString() ?? '',
      sessionToken: json['session_token']?.toString() ?? '',
      amount: (json['amount'] as num?) ?? 0,
      currency: json['currency']?.toString() ?? '',
      paymentMethod: method,
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
      id: (json['id'] as num?)?.toInt() ?? (json['payment_method_id'] as num?)?.toInt(),
      nameAr: json['name_ar']?.toString() ?? json['name']?.toString(),
      code: json['code']?.toString(),
      iconUrl: PaymentMethodModel.resolveIconUrl(json['icon_url']?.toString()),
    );
  }
}
