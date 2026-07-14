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
      emit(AddressLoaded(List.from(_addresses)));
    } else {
      // إذا لم يكن هناك كاش محلي، نظهر مؤشر التحميل الكامل للشاشة
      emit(AddressLoading());
    }

    // 2. طلب أحدث البيانات من Laravel API
    final (remoteAddresses, error) = await _repository.getAddresses();
    if (error != null) {
      // إذا فشل الطلب وكان هناك كاش معروض، نبقى على حالة الاستقرار ولا نعرض شاشة خطأ كاملة
      if (_addresses.isEmpty) {
        emit(AddressError(error));
      }
      return;
    }

    // 3. تحديث البيانات والحالة عند نجاح الطلب
    _addresses = remoteAddresses ?? [];
    if (_addresses.isEmpty) {
      emit(AddressEmpty());
    } else {
      emit(AddressLoaded(List.from(_addresses)));
    }
  }

  /// إضافة عنوان جديد
  Future<void> addAddress(AddressModel address) async {
    emit(AddressActionLoading(List.from(_addresses)));
    final (success, message) = await _repository.addAddress(address);
    if (!success) {
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
      emit(AddressActionError(List.from(_addresses), message));
      return;
    }
    await _refreshSilently(message);
  }

  /// إعادة تحميل القائمة بصمت وإرسال Success state ثم الاستقرار
  Future<void> _refreshSilently(String successMessage) async {
    final (addresses, error) = await _repository.getAddresses();
    if (error != null) {
      emit(AddressActionSuccess(List.from(_addresses), successMessage));
      return;
    }
    _addresses = addresses ?? [];
    // 1. إرسال حالة النجاح المؤقتة لعرض الـ SnackBar
    emit(AddressActionSuccess(List.from(_addresses), successMessage));
    
    // 2. التحقق من القائمة والانتقال فوراً لحالة الاستقرار المناسبة
    if (_addresses.isEmpty) {
      emit(AddressEmpty());
    } else {
      emit(AddressLoaded(List.from(_addresses)));
    }
  }
}
