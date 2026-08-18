import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/parent/wallet/data/models/wallet_balance_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/payment_method_model.dart';
import 'package:kids_transport/features/parent/wallet/data/repositories/wallet_repository.dart';
import 'package:kids_transport/features/parent/wallet/logic/wallet_cubit/wallet_state.dart';
import 'package:dio/dio.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository;

  WalletCubit(this._repository) : super(WalletInitial());

  /// 1 & 2. تحميل بيانات المحفظة (الرصيد + طرق الشحن)
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

  /// 3. تقديم طلب شحن رصيد جديد
  Future<void> rechargeWallet({
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
  }) async {
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

      emit(WalletRechargeSuccess(
        'تم تقديم طلب الشحن عبر $paymentMethod بنجاح. بانتظار تأكيد الإدارة.',
      ));

      // إعادة تحميل الرصيد فور النجاح
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

  /// 4. تجميد مبلغ رحلة يومية (Hold Amount)
  Future<void> holdTripAmount({
    required dynamic tripId,
    required double amount,
  }) async {
    emit(WalletHolding());
    try {
      final result = await _repository.holdTripAmount(
        tripId: tripId,
        amount: amount,
      );
      emit(WalletHoldSuccess(
        holdData: result,
        message: 'تم حجز مبلغ الرحلة بنجاح في أمانات المحفظة.',
      ));
      // تحديث الرصيد بعد تجميد المبلغ
      loadWalletData();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'فشل حجز مبلغ الرحلة';
      emit(WalletHoldError(msg.toString()));
    } catch (e) {
      emit(WalletHoldError(e.toString()));
    }
  }

  /// 5. تقديم اعتراض/نزاع مالي على رحلة (24h Dispute)
  Future<void> createTripDispute({
    required dynamic tripId,
    required String reason,
  }) async {
    emit(WalletDisputing());
    try {
      final result = await _repository.createTripDispute(
        tripId: tripId,
        reason: reason,
      );
      emit(WalletDisputeSuccess(
        disputeData: result,
        message: 'تم تقديم الاعتراض وتجميد مبلغ الرحلة لحين مراجعة الإدارة.',
      ));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'فشل تقديم الاعتراض على الرحلة';
      emit(WalletDisputeError(msg.toString()));
    } catch (e) {
      emit(WalletDisputeError(e.toString()));
    }
  }
}
