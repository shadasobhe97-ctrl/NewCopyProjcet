import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/parent/wallet/data/models/hold_trip_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/payment_method_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/recharge_response_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/trip_dispute_model.dart';
import 'package:kids_transport/features/parent/wallet/data/models/wallet_balance_model.dart';

class WalletRemoteDataSource {
  final ApiClient _apiClient;

  WalletRemoteDataSource(this._apiClient);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  /// 1. GET /api/parent/wallet/balance
  Future<WalletBalanceModel> getBalance() async {
    final response = await _apiClient.get(
      ApiEndpoints.parentWalletBalance,
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل رصيد المحفظة.');
      }
    }
    return WalletBalanceModel.fromJson(data['data']);
  }

  /// 2. GET /api/parent/wallet/payment-methods
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final response = await _apiClient.get(
      ApiEndpoints.parentWalletPaymentMethods,
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تحميل طرق الدفع.');
      }
    }
    final list = data['data'] as List;
    return list.map((e) => PaymentMethodModel.fromJson(e)).toList();
  }

  /// 3. POST /api/parent/wallet/recharge
  Future<RechargeResponseModel> rechargeWallet({
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.parentWalletRecharge,
      data: {
        'amount': amount,
        'payment_method': paymentMethod,
        'reference_number': referenceNumber,
      },
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر إجراء عملية الشحن.');
      }
    }
    return RechargeResponseModel.fromJson(data['data']);
  }

  /// 4. POST /api/parent/wallet/hold-trip
  Future<HoldTripModel> holdTripAmount({
    required dynamic tripId,
    required double amount,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.parentWalletHoldTrip,
      data: {
        'trip_id': tripId,
        'amount': amount,
      },
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر حجز مبلغ الرحلة.');
      }
    }
    return HoldTripModel.fromJson(data['data']);
  }

  /// 5. POST /api/parent/trips/{tripId}/dispute
  Future<TripDisputeModel> createTripDispute({
    required dynamic tripId,
    required String reason,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.parentTripDispute(tripId),
      data: {
        'reason': reason,
      },
      headers: _authHeader,
    );
    final data = response.data;
    if (data is Map) {
      final success = data['success'];
      if (success == false) {
        final msg = ApiException.extractMessage(data);
        throw ApiException(msg ?? 'تعذر تقديم الاعتراض على الرحلة.');
      }
    }
    return TripDisputeModel.fromJson(data['data']);
  }
}
