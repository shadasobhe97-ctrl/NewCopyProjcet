class WalletBalanceModel {
  final double balance;
  final String currency;

  WalletBalanceModel({
    required this.balance,
    required this.currency,
  });

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'د.ل',
    );
  }
}
