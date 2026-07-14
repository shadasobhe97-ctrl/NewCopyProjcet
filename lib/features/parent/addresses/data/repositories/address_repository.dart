import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/features/parent/addresses/data/datasources/address_remote_data_source.dart';
import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';

import '../../../../../data/local/address_local_data_source.dart';

class AddressRepository {
  final AddressRemoteDataSource _dataSource;
  final AddressLocalDataSource _localDataSource;

  AddressRepository(
    this._dataSource, [
    AddressLocalDataSource? localDataSource,
  ]) : _localDataSource = localDataSource ?? AddressLocalDataSourceImpl();

  Future<(List<AddressModel>?, String?)> getAddresses() async {
    try {
      final addresses = await _dataSource.getAddresses();
      return (addresses, null);
    } on ApiException catch (e) {
      return (null, e.message);
    } catch (_) {
      return (null, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }

  Future<(bool, String)> addAddress(AddressModel address) async {
    try {
      final message = await _dataSource.addAddress(address);
      return (true, message);
    } on ApiException catch (e) {
      return (false, e.message);
    } catch (_) {
      return (false, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }

  Future<(bool, String)> updateAddress(AddressModel address) async {
    try {
      final message = await _dataSource.updateAddress(address);
      return (true, message);
    } on ApiException catch (e) {
      return (false, e.message);
    } catch (_) {
      return (false, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }

  Future<(bool, String)> deleteAddress(String id) async {
    try {
      final message = await _dataSource.deleteAddress(id);
      return (true, message);
    } on ApiException catch (e) {
      return (false, e.message);
    } catch (_) {
      return (false, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }
}
