import 'package:kids_transport/core/services/hive_helper.dart';
import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';

abstract class AddressLocalDataSource {
  Future<List<AddressModel>> getCachedAddresses();
  Future<void> cacheAddresses(List<AddressModel> addresses);
  Future<void> cacheAddress(AddressModel address);
  Future<void> removeCachedAddress(int addressId);
  Future<void> clearCache();
}

class AddressLocalDataSourceImpl implements AddressLocalDataSource {
  @override
  Future<List<AddressModel>> getCachedAddresses() async {
    final box = HiveHelper.addressesBox;
    final list = <AddressModel>[];
    for (var key in box.keys) {
      final value = box.get(key);
      if (value is Map) {
        final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(value);
        list.add(AddressModel.fromJson(jsonMap));
      }
    }
    return list;
  }

  @override
  Future<void> cacheAddresses(List<AddressModel> addresses) async {
    final box = HiveHelper.addressesBox;
    await box.clear();
    for (var address in addresses) {
      if (address.id != null) {
        await box.put(address.id, address.toJson());
      }
    }
  }

  @override
  Future<void> cacheAddress(AddressModel address) async {
    final box = HiveHelper.addressesBox;
    if (address.id != null) {
      await box.put(address.id, address.toJson());
    }
  }

  @override
  Future<void> removeCachedAddress(int addressId) async {
    final box = HiveHelper.addressesBox;
    await box.delete(addressId);
  }

  @override
  Future<void> clearCache() async {
    final box = HiveHelper.addressesBox;
    await box.clear();
  }
}
