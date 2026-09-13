import 'package:equatable/equatable.dart';
import 'package:kids_transport/features/parent/wallet/data/models/hold_trip_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/payment_method_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/recharge_mock_pay_response_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/recharge_response_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/trip_dispute_model.dart';
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

class WalletRechargeInitiating extends WalletState {}

class WalletRechargeInitiated extends WalletState {
  final RechargeInitiateResponseModel data;

  const WalletRechargeInitiated(this.data);

  @override
  List<Object?> get props => [data];
}

class WalletRechargeConfirming extends WalletState {
  final RechargeInitiateResponseModel initiateData;

  const WalletRechargeConfirming(this.initiateData);

  @override
  List<Object?> get props => [initiateData];
}

class WalletRechargeSuccess extends WalletState {
  final RechargeMockPayResponseModel data;

  const WalletRechargeSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

class WalletRechargeError extends WalletState {
  final String message;

  const WalletRechargeError(this.message);

  @override
  List<Object?> get props => [message];
}

class WalletHolding extends WalletState {}

class WalletHoldSuccess extends WalletState {
  final HoldTripModel holdData;
  final String message;

  const WalletHoldSuccess({
    required this.holdData,
    required this.message,
  });

  @override
  List<Object?> get props => [holdData, message];
}

class WalletHoldError extends WalletState {
  final String message;

  const WalletHoldError(this.message);

  @override
  List<Object?> get props => [message];
}

class WalletDisputing extends WalletState {}

class WalletDisputeSuccess extends WalletState {
  final TripDisputeModel disputeData;
  final String message;

  const WalletDisputeSuccess({
    required this.disputeData,
    required this.message,
  });

  @override
  List<Object?> get props => [disputeData, message];
}

class WalletDisputeError extends WalletState {
  final String message;

  const WalletDisputeError(this.message);

  @override
  List<Object?> get props => [message];
}
