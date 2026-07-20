import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';
import 'package:kids_transport/features/parent/addresses/data/repositories/address_repository.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRepository _repository;

  List<AddressModel> _addresses = [];

  AddressCubit(this._repository) : super(AddressInitial());

  /// تحميل جميع العناوين (استراتيجية Cache-First)
  Future<void> loadAddresses() async {
    // 1. قراءة البيانات من Hive أولاً وعرضها مباشرة
    final (cachedAddresses, _) = await _repository.getCachedAddresses();
    if (cachedAddresses != null && cachedAddresses.isNotEmpty) {
      _addresses = cachedAddresses;
      debugPrint(
        '💾 [AddressCubit] عرض ${_addresses.length} عنوان من الكاش المحلي',
      );
      emit(AddressLoaded(List.from(_addresses)));
    } else {
      // إذا لم يكن هناك كاش محلي، نظهر مؤشر التحميل الكامل للشاشة
      emit(AddressLoading());
    }

    // 2. طلب أحدث البيانات من Laravel API
    final (remoteAddresses, error) = await _repository.getAddresses();
    if (error != null) {
      debugPrint('❌ [AddressCubit] loadAddresses فشل من السيرفر: $error');
      // إذا فشل الطلب وكان هناك كاش معروض، نبقى على حالة الاستقرار ولا نعرض شاشة خطأ كاملة
      if (_addresses.isEmpty) {
        emit(AddressError(error));
      }
      return;
    }

    // 3. تحديث البيانات والحالة عند نجاح الطلب
    debugPrint('✅ [AddressCubit] السيرفر أرجع ${remoteAddresses?.length ?? 0} عنوان');
    if (remoteAddresses == null || remoteAddresses.isEmpty) {
      // إذا السيرفر أرجع قائمة فارغة ولكن كان عندنا كاش، نبقى على الكاش
      if (_addresses.isNotEmpty) {
        debugPrint('ℹ️ [AddressCubit] الإبقاء على الكاش (${_addresses.length}) لأن السيرفر أرجع فارغ');
        return;
      }
      emit(AddressEmpty());
    } else {
      _addresses = remoteAddresses;
      emit(AddressLoaded(List.from(_addresses)));
    }
  }

  /// إضافة عنوان جديد
  Future<void> addAddress(AddressModel address) async {
    emit(AddressActionLoading(List.from(_addresses)));
    final (success, message) = await _repository.addAddress(address);
    if (!success) {
      debugPrint('❌ [AddressCubit] addAddress فشلت: $message');
      emit(AddressActionError(List.from(_addresses), message));
      return;
    }
    // تحديث القائمة من السيرفر بعد الإضافة
    await _refreshSilently(message);
  }

  /// تعديل عنوان موجود
  Future<void> updateAddress(AddressModel address) async {
    emit(AddressActionLoading(List.from(_addresses)));
    final (success, message) = await _repository.updateAddress(address);
    if (!success) {
      debugPrint('❌ [AddressCubit] updateAddress فشلت: $message');
      emit(AddressActionError(List.from(_addresses), message));
      return;
    }
    await _refreshSilently(message);
  }

  /// حذف عنوان
  Future<void> deleteAddress(String id) async {
    emit(AddressActionLoading(List.from(_addresses)));
    final (success, message) = await _repository.deleteAddress(id);
    if (!success) {
      debugPrint('❌ [AddressCubit] deleteAddress فشلت: $message');
      emit(AddressActionError(List.from(_addresses), message));
      return;
    }
    await _refreshSilently(message);
  }

  /// إعادة تحميل القائمة بصمت وإرسال Success state ثم الاستقرار
  Future<void> _refreshSilently(String successMessage) async {
    final (addresses, error) = await _repository.getAddresses();
    if (error != null) {
      debugPrint(
        '⚠️ [AddressCubit] _refreshSilently فشل تحديث القائمة بعد العملية: $error',
      );
      emit(AddressActionSuccess(List.from(_addresses), successMessage));
      return;
    }
    debugPrint(
      '🔄 [AddressCubit] تحديث بعد العملية: ${addresses?.length ?? 0} عنوان',
    );
    if (addresses == null || addresses.isEmpty) {
      // إذا السيرفر أرجع فارغ نعرض نجاح ونبقى على القائمة القديمة
      emit(AddressActionSuccess(List.from(_addresses), successMessage));
      if (_addresses.isNotEmpty) return; // نبقى على القديم
      emit(AddressEmpty());
    } else {
      _addresses = addresses;
      emit(AddressActionSuccess(List.from(_addresses), successMessage));
      emit(AddressLoaded(List.from(_addresses)));
    }
  }
}
