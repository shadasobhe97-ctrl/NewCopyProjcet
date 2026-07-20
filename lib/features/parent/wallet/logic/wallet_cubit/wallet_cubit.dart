import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/parent/wallet/data/models/wallet_balance_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/payment_method_model.dart';
import 'package:kids_transport/features/parent/wallet/data/repositories/wallet_repository.dart';
import 'package:kids_transport/features/parent/wallet/logic/wallet_cubit/wallet_state.dart';
import 'package:dio/dio.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository;

  WalletCubit(this._repository) : super(WalletInitial());

  Future<void> loadWalletData() async {
    emit(WalletLoading());
    try {
      final balance = await _repository.getBalance();
      final methods = await _repository.getPaymentMethods();
      emit(WalletLoaded(balance, methods));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'فشل في تحميل بيانات المحفظة';
      emit(WalletError(msg.toString()));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> rechargeWallet({
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
  }) async {
    // Preserve current loaded state if possible
    final currentState = state;
    WalletBalanceModel? cachedBalance;
    List<PaymentMethodModel>? cachedMethods;
    
    if (currentState is WalletLoaded) {
      cachedBalance = currentState.balance;
      cachedMethods = currentState.paymentMethods;
    }

    emit(WalletRecharging());
    try {
      await _repository.rechargeWallet(
        amount: amount,
        paymentMethod: paymentMethod,
        referenceNumber: referenceNumber,
      );
      
      emit(WalletRechargeSuccess('تم تقديم طلب الشحن بنجاح. بانتظار تأكيد الإدارة.'));
      
      // Reload balance after success
      loadWalletData();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'فشل في إرسال طلب الشحن';
      emit(WalletRechargeError(msg.toString()));
      if (cachedBalance != null && cachedMethods != null) {
        emit(WalletLoaded(cachedBalance, cachedMethods));
      }
    } catch (e) {
      emit(WalletRechargeError(e.toString()));
      if (cachedBalance != null && cachedMethods != null) {
        emit(WalletLoaded(cachedBalance, cachedMethods));
      }
    }
  }
}
