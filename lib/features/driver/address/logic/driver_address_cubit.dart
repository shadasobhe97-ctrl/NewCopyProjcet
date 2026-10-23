import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/features/driver/driver_preferences/data/models/zone_model.dart';
import '../data/models/driver_address_model.dart';
import '../data/repositories/driver_address_repository.dart';
import 'driver_address_state.dart';

class DriverAddressCubit extends Cubit<DriverAddressState> {
  final DriverAddressRepository _repository;

  DriverAddressCubit(this._repository) : super(DriverAddressInitial());

  DriverAddressModel? _currentAddress;
  List<ZoneModel> _zones = [];

  DriverAddressModel? get currentAddress => _currentAddress;
  List<ZoneModel> get zones => _zones;

  /// جلب عنوان السائق والمناطق
  Future<void> fetchAddress() async {
    emit(DriverAddressLoading());
    try {
      final results = await Future.wait([
        _repository.getPrimaryAddress(),
        _repository.getZones(),
      ]);

      _currentAddress = results[0] as DriverAddressModel?;
      _zones = results[1] as List<ZoneModel>;

      emit(DriverAddressLoaded(
        address: _currentAddress,
        zones: _zones,
      ));
    } on ApiException catch (e) {
      emit(DriverAddressError(e.message));
    } catch (e) {
      emit(DriverAddressError('فشل جلب بيانات نقطة الانطلاق، يرجى المحاولة لاحقاً.'));
    }
  }

  /// تحديث عنوان نقطة الانطلاق الموجود للسائق
  Future<void> updateAddress({
    required int addressId,
    required String label,
    required double lat,
    required double lng,
    int? zoneId,
  }) async {
    emit(DriverAddressSaving(currentAddress: _currentAddress, zones: _zones));
    try {
      final updated = await _repository.updateAddress(
        addressId: addressId,
        label: label,
        lat: lat,
        lng: lng,
        zoneId: zoneId,
      );

      _currentAddress = updated;
      emit(DriverAddressSaveSuccess(
        message: 'تم تحديث نقطة الانطلاق بنجاح.',
        address: updated,
        zones: _zones,
      ));
    } on ApiException catch (e) {
      emit(DriverAddressSaveError(
        errorMessage: e.message,
        currentAddress: _currentAddress,
        zones: _zones,
      ));
    } catch (e) {
      emit(DriverAddressSaveError(
        errorMessage: 'فشل حفظ التعديلات على نقطة الانطلاق.',
        currentAddress: _currentAddress,
        zones: _zones,
      ));
    }
  }

  /// إضافة نقطة انطلاق جديدة (في حال لم يكن للسائق عنوان سابق)
  Future<void> createAddress({
    required String label,
    required double lat,
    required double lng,
    int? zoneId,
  }) async {
    emit(DriverAddressSaving(currentAddress: _currentAddress, zones: _zones));
    try {
      final created = await _repository.createAddress(
        label: label,
        lat: lat,
        lng: lng,
        zoneId: zoneId,
      );

      _currentAddress = created;
      emit(DriverAddressSaveSuccess(
        message: 'تم إضافة نقطة الانطلاق بنجاح.',
        address: created,
        zones: _zones,
      ));
    } on ApiException catch (e) {
      emit(DriverAddressSaveError(
        errorMessage: e.message,
        currentAddress: _currentAddress,
        zones: _zones,
      ));
    } catch (e) {
      emit(DriverAddressSaveError(
        errorMessage: 'فشل حفظ نقطة الانطلاق.',
        currentAddress: _currentAddress,
        zones: _zones,
      ));
    }
  }
}
