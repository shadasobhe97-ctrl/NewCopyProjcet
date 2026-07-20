import 'package:equatable/equatable.dart';
import 'package:kids_transport/features/parent/wallet/data/models/payment_method_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/wallet_balance_model.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final WalletBalanceModel balance;
  final List<PaymentMethodModel> paymentMethods;

  const WalletLoaded(this.balance, this.paymentMethods);

  @override
  List<Object?> get props => [balance, paymentMethods];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}

class WalletRecharging extends WalletState {}

class WalletRechargeSuccess extends WalletState {
  final String message;

  const WalletRechargeSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class WalletRechargeError extends WalletState {
  final String message;

  const WalletRechargeError(this.message);

  @override
  List<Object?> get props => [message];
}
