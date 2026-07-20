import 'package:flutter/foundation.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/features/parent/addresses/data/datasources/address_remote_data_source.dart';
import 'package:kids_transport/features/parent/addresses/data/models/address_model.dart';
import 'package:kids_transport/data/local/address_local_data_source.dart';

class AddressRepository {
  final AddressRemoteDataSource _dataSource;
  final AddressLocalDataSource _localDataSource;

  AddressRepository(this._dataSource, this._localDataSource);

  /// جلب العناوين المخزنة محلياً من كاش Hive
  Future<(List<AddressModel>?, String?)> getCachedAddresses() async {
    try {
      final cached = await _localDataSource.getCachedAddresses();
      return (cached, null);
    } catch (e) {
      debugPrint('❌ [AddressRepository] getCachedAddresses: $e');
      return (null, 'تعذر تحميل العناوين المخزنة محلياً');
    }
  }

  /// جلب العناوين من السيرفر وتحديث الكاش المحلي
  Future<(List<AddressModel>?, String?)> getAddresses() async {
    try {
      final addresses = await _dataSource.getAddresses();
      // تحديث كاش Hive بالكامل بعد النجاح
      await _localDataSource.cacheAddresses(addresses);
      return (addresses, null);
    } on ApiException catch (e) {
      debugPrint(
        '❌ [AddressRepository] getAddresses ApiException: ${e.message}',
      );
      return (null, e.message);
    } catch (e) {
      // نطبع الخطأ الحقيقي هنا حتى تقدر تشوفه بالـ console وقت التشخيص
      debugPrint('❌ [AddressRepository] getAddresses unexpected error: $e');
      return (null, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }

  /// إضافة عنوان جديد (API أولاً ثم التحديث في الكاش)
  Future<(bool, String)> addAddress(AddressModel address) async {
    try {
      final message = await _dataSource.addAddress(address);

      // جلب العناوين المحدثة من السيرفر للحصول على العنوان الجديد مع معرفه (ID) المُولد وتحديث الكاش
      try {
        final latestAddresses = await _dataSource.getAddresses();
        await _localDataSource.cacheAddresses(latestAddresses);
      } catch (e) {
        debugPrint(
          '⚠️ [AddressRepository] addAddress: فشل تحديث الكاش بعد الإضافة: $e',
        );
      }

      return (true, message);
    } on ApiException catch (e) {
      debugPrint('❌ [AddressRepository] addAddress ApiException: ${e.message}');
      return (false, e.message);
    } catch (e) {
      debugPrint('❌ [AddressRepository] addAddress unexpected error: $e');
      return (false, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }

  /// تعديل عنوان (API أولاً ثم الكاش)
  Future<(bool, String)> updateAddress(AddressModel address) async {
    try {
      final message = await _dataSource.updateAddress(address);

      // تحديث العنصر في الكاش المحلي بالـ ID
      await _localDataSource.updateCachedAddress(address);

      return (true, message);
    } on ApiException catch (e) {
      debugPrint(
        '❌ [AddressRepository] updateAddress ApiException: ${e.message}',
      );
      return (false, e.message);
    } catch (e) {
      debugPrint('❌ [AddressRepository] updateAddress unexpected error: $e');
      return (false, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }

  /// حذف عنوان (API أولاً ثم الكاش)
  Future<(bool, String)> deleteAddress(String id) async {
    try {
      final message = await _dataSource.deleteAddress(id);

      // حذف العنصر من الكاش المحلي بالـ ID
      await _localDataSource.removeCachedAddress(id);

      return (true, message);
    } on ApiException catch (e) {
      debugPrint(
        '❌ [AddressRepository] deleteAddress ApiException: ${e.message}',
      );
      return (false, e.message);
    } catch (e) {
      debugPrint('❌ [AddressRepository] deleteAddress unexpected error: $e');
      return (false, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }
}
