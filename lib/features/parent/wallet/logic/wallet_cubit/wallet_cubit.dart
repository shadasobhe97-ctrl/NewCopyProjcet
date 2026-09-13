import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/parent/wallet/data/models/payment_method_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/recharge_response_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/wallet_balance_model.dart';
import 'package:kids_transport/features/parent/wallet/data/repositories/wallet_repository.dart';
import 'package:kids_transport/features/parent/wallet/logic/wallet_cubit/wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository;

  WalletBalanceModel? _cachedBalance;
  List<PaymentMethodModel>? _cachedMethods;

  WalletCubit(this._repository) : super(WalletInitial());

  /// 1 & 2. تحميل بيانات المحفظة (الرصيد + طرق الشحن)
  Future<void> loadWalletData() async {
    emit(WalletLoading());
    try {
      final balance = await _repository.getBalance();
      final methods = await _repository.getPaymentMethods();
      _cachedBalance = balance;
      _cachedMethods = methods;
      emit(WalletLoaded(balance, methods));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'فشل في تحميل بيانات المحفظة';
      emit(WalletError(msg.toString()));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  /// 3a. بدء عملية الشحن — POST /recharge/initiate
  Future<void> initiateRecharge({
    required num amount,
    required int paymentMethodId,
  }) async {
    if (state is WalletRechargeInitiating) return;

    if (state is WalletLoaded) {
      final loaded = state as WalletLoaded;
      _cachedBalance = loaded.balance;
      _cachedMethods = loaded.paymentMethods;
    }

    emit(WalletRechargeInitiating());
    try {
      final result = await _repository.rechargeInitiate(
        amount: amount,
        paymentMethodId: paymentMethodId,
      );
      emit(WalletRechargeInitiated(result));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'فشل في بدء عملية الشحن';
      emit(WalletRechargeError(msg.toString()));
      _restoreLoadedIfPossible();
    } catch (e) {
      emit(WalletRechargeError(e.toString()));
      _restoreLoadedIfPossible();
    }
  }

  /// 3b. تأكيد الدفع — POST /recharge/mock-pay
  ///
  /// يستخدم `sessionToken` القادم من `RechargeInitiateResponseModel`
  /// فقط، ولا يقبل أي token من مصدر آخر.
  Future<void> confirmRecharge({
    required RechargeInitiateResponseModel initiateData,
  }) async {
    if (state is WalletRechargeConfirming) return;

    emit(WalletRechargeConfirming(initiateData));
    try {
      final result = await _repository.rechargeMockPay(
        sessionToken: initiateData.sessionToken,
      );

      if (_cachedBalance != null) {
        _cachedBalance = WalletBalanceModel(
          balance: result.currentBalance.toDouble(),
          currency: result.currency.isNotEmpty
              ? result.currency
              : _cachedBalance!.currency,
        );
      }

      emit(WalletRechargeSuccess(result));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'فشل في إتمام عملية الدفع';
      emit(WalletRechargeError(msg.toString()));
    } catch (e) {
      emit(WalletRechargeError(e.toString()));
    }
  }

  /// يعيد الحالة إلى `WalletLoaded` باستخدام الرصيد/الطرق المحدَّثة
  /// دون طلب شبكة إضافي — لعرض الرصيد الجديد فوراً في WalletScreen.
  void refreshFromCache() {
    if (_cachedBalance != null && _cachedMethods != null) {
      emit(WalletLoaded(_cachedBalance!, _cachedMethods!));
    }
  }

  /// قراءة فقط للحالة المخزَّنة — بدون emit — لاستخدامها في UI
  /// أثناء حالات الشحن المؤقتة.
  WalletLoaded? get cachedLoaded {
    if (_cachedBalance != null && _cachedMethods != null) {
      return WalletLoaded(_cachedBalance!, _cachedMethods!);
    }
    return null;
  }

  void _restoreLoadedIfPossible() {
    if (_cachedBalance != null && _cachedMethods != null) {
      emit(WalletLoaded(_cachedBalance!, _cachedMethods!));
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
