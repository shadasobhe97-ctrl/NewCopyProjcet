import 'package:kids_transport/features/driver/driver_preferences/data/models/zone_model.dart';
import '../datasources/driver_address_remote_data_source.dart';
import '../models/driver_address_model.dart';

abstract class DriverAddressRepository {
  Future<List<DriverAddressModel>> getAddresses({String? token});
  Future<DriverAddressModel?> getPrimaryAddress({String? token});
  Future<DriverAddressModel> createAddress({
    required String label,
    required double lat,
    required double lng,
    int? zoneId,
    String? token,
  });
  Future<DriverAddressModel> updateAddress({
    required int addressId,
    String? label,
    double? lat,
    double? lng,
    int? zoneId,
    String? token,
  });
  Future<bool> deleteAddress(int addressId, {String? token});
  Future<List<ZoneModel>> getZones({String? token});
}

class DriverAddressRepositoryImpl implements DriverAddressRepository {
  final DriverAddressRemoteDataSource _remoteDataSource;

  DriverAddressRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<DriverAddressModel>> getAddresses({String? token}) {
    return _remoteDataSource.getAddresses(token: token);
  }

  @override
  Future<DriverAddressModel?> getPrimaryAddress({String? token}) async {
    final list = await _remoteDataSource.getAddresses(token: token);
    return list.isNotEmpty ? list.first : null;
  }

  @override
  Future<DriverAddressModel> createAddress({
    required String label,
    required double lat,
    required double lng,
    int? zoneId,
    String? token,
  }) {
    return _remoteDataSource.createAddress(
      label: label,
      lat: lat,
      lng: lng,
      zoneId: zoneId,
      token: token,
    );
  }

  @override
  Future<DriverAddressModel> updateAddress({
    required int addressId,
    String? label,
    double? lat,
    double? lng,
    int? zoneId,
    String? token,
  }) {
    return _remoteDataSource.updateAddress(
      addressId: addressId,
      label: label,
      lat: lat,
      lng: lng,
      zoneId: zoneId,
      token: token,
    );
  }

  @override
  Future<bool> deleteAddress(int addressId, {String? token}) {
    return _remoteDataSource.deleteAddress(addressId, token: token);
  }

  @override
  Future<List<ZoneModel>> getZones({String? token}) {
    return _remoteDataSource.getZones(token: token);
  }
}
