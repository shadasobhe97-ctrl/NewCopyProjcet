class WalletModel {
  final double balance;
  final String currency;

  WalletModel({required this.balance, required this.currency});

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'د.ل',
    );
  }
}
