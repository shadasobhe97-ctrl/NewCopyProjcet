import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/services/hive_helper.dart';
import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';

abstract class AddressLocalDataSource {
  Future<List<AddressModel>> getCachedAddresses();
  Future<void> cacheAddresses(List<AddressModel> addresses);
  Future<void> cacheAddress(AddressModel address);
  Future<void> updateCachedAddress(AddressModel address);
  Future<void> removeCachedAddress(String addressId);
  Future<void> clearCache();
}

class AddressLocalDataSourceImpl implements AddressLocalDataSource {
  @override
  Future<List<AddressModel>> getCachedAddresses() async {
    final box = HiveHelper.addressesBox;
    final list = <AddressModel>[];
    for (var key in box.keys) {
      try {
        final value = box.get(key);
        if (value is Map) {
          final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(value);
          // toJson() لا يحفظ id، فنعتمد دائماً على مفتاح التخزين لضمان وجوده
          jsonMap['id'] = jsonMap['id']?.toString() ?? key.toString();
          list.add(AddressModel.fromJson(jsonMap));
        }
      } catch (e) {
        // نتجاهل العنصر التالف فقط بدل تفشيل القراءة كاملة
        debugPrint('⚠️ [AddressLocalCache] تخطي عنصر تالف بالمفتاح $key: $e');
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
  Future<void> updateCachedAddress(AddressModel address) async {
    await cacheAddress(address);
  }

  @override
  Future<void> removeCachedAddress(String addressId) async {
    final box = HiveHelper.addressesBox;
    await box.delete(addressId);
  }

  @override
  Future<void> clearCache() async {
    final box = HiveHelper.addressesBox;
    await box.clear();
  }
}
