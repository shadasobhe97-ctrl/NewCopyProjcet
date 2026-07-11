import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';
import 'package:kids_transport/features/parent/addresses/data/repositories/address_repository.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRepository _repository;

  List<AddressModel> _addresses = [];

  AddressCubit(this._repository) : super(AddressInitial());

  /// تحميل جميع العناوين
  Future<void> loadAddresses() async {
    emit(AddressLoading());
    final (addresses, error) = await _repository.getAddresses();
    if (error != null) {
      emit(AddressError(error));
      return;
    }
    _addresses = addresses ?? [];
    if (_addresses.isEmpty) {
      emit(AddressEmpty());
    } else {
      emit(AddressLoaded(_addresses));
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
    // إعادة تحميل القائمة من السيرفر بعد الإضافة
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

  /// إعادة تحميل القائمة بصمت وإرسال Success state
  Future<void> _refreshSilently(String successMessage) async {
    final (addresses, error) = await _repository.getAddresses();
    if (error != null) {
      emit(AddressActionSuccess(List.from(_addresses), successMessage));
      return;
    }
    _addresses = addresses ?? [];
    emit(AddressActionSuccess(List.from(_addresses), successMessage));
    if (_addresses.isEmpty) {
      emit(AddressEmpty());
    }
  }
}
