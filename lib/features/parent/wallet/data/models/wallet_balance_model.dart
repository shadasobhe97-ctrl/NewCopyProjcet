class WalletBalanceModel {
  final double balance;
  final String currency;

  WalletBalanceModel({
    required this.balance,
    required this.currency,
  });

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      balance: (json['balance'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'د.ل',
    );
  }
}
