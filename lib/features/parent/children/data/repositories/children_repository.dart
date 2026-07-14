import 'package:kids_transport/core/network/api_exception.dart';
import '../datasources/children_remote_data_source.dart';
import '../models/child_model.dart';
import '../models/school_model.dart';
import '../models/logistics_model.dart';

import '../../../../../data/local/children_local_data_source.dart';

class ChildrenRepository {
  final ChildrenRemoteDataSource _dataSource;
  final ChildrenLocalDataSource _localDataSource;

  ChildrenRepository(
    this._dataSource,
    this._localDataSource,
  );

  Future<(List<ChildModel>?, String?)> getMyChildren() async {
    try {
      final children = await _dataSource.getChildren();
      await _localDataSource.cacheChildren(children);
      return (children, null);
    } on ApiException catch (e) {
      return (null, e.message);
    } catch (_) {
      return (null, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }

  Future<List<ChildModel>> getCachedChildren() async {
    try {
      return await _localDataSource.getCachedChildren();
    } catch (_) {
      return [];
    }
  }

  Future<(List<SchoolModel>?, String?)> searchSchools(String query) async {
    try {
      final schools = await _dataSource.getSchools();
      if (query.isEmpty) return (schools, null);
      final filtered = schools.where((s) => s.name.toLowerCase().contains(query.toLowerCase())).toList();
      return (filtered, null);
    } on ApiException catch (e) {
      return (null, e.message);
    } catch (_) {
      return (null, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }

  Future<(ChildModel?, String)> addChild(ChildModel child, String? localImagePath) async {
    try {
      final (newChild, message) = await _dataSource.addChild(child, localImagePath);
      await _localDataSource.cacheChild(newChild);
      return (newChild, message);
    } on ApiException catch (e) {
      return (null, e.message);
    } catch (_) {
      return (null, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }

  Future<(ChildModel?, String)> updateChild(ChildModel child, String? localImagePath) async {
    try {
      final (updatedChild, message) = await _dataSource.updateChild(child, localImagePath);
      await _localDataSource.cacheChild(updatedChild);
      return (updatedChild, message);
    } on ApiException catch (e) {
      return (null, e.message);
    } catch (_) {
      return (null, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }

  Future<(bool, String)> deleteChild(String id) async {
    try {
      final message = await _dataSource.deleteChild(id);
      final parsedId = int.tryParse(id);
      if (parsedId != null) {
        await _localDataSource.removeCachedChild(parsedId);
      }
      return (true, message);
    } on ApiException catch (e) {
      return (false, e.message);
    } catch (_) {
      return (false, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }

  Future<(ChildModel?, String?)> getChildDetails(String id) async {
    try {
      final child = await _dataSource.getChildDetails(id);
      return (child, null);
    } on ApiException catch (e) {
      return (null, e.message);
    } catch (_) {
      return (null, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }

  Future<(LogisticsModel?, String?)> getChildSubscription(String id) async {
    try {
      final logistics = await _dataSource.getChildSubscription(id);
      return (logistics, null);
    } on ApiException catch (e) {
      return (null, e.message);
    } catch (_) {
      return (null, 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
    }
  }
}
