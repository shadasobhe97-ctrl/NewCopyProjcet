import 'parsers.dart';

class WalletModel {
  final double balance;
  final String currency;

  WalletModel({required this.balance, required this.currency});

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: parseDouble(json['balance']),
      currency: json['currency'] as String? ?? 'د.ل',
    );
  }
}
