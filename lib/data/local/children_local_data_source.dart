import 'package:kids_transport/core/services/hive_helper.dart';
import 'package:kids_transport/features/parent/children/data/models/child_model.dart';

abstract class ChildrenLocalDataSource {
  Future<List<ChildModel>> getCachedChildren();
  Future<void> cacheChildren(List<ChildModel> children);
  Future<void> cacheChild(ChildModel child);
  Future<void> removeCachedChild(int childId);
  Future<void> clearCache();
}

class ChildrenLocalDataSourceImpl implements ChildrenLocalDataSource {
  @override
  Future<List<ChildModel>> getCachedChildren() async {
    final box = HiveHelper.childrenBox;
    final list = <ChildModel>[];
    for (var key in box.keys) {
      final value = box.get(key);
      if (value is Map) {
        final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(value);
        list.add(ChildModel.fromJson(jsonMap));
      }
    }
    return list;
  }

  @override
  Future<void> cacheChildren(List<ChildModel> children) async {
    final box = HiveHelper.childrenBox;
    // مسح الكاش القديم وحفظ الجديد
    await box.clear();
    for (var child in children) {
      if (child.id != null) {
        await box.put(child.id, child.toJson());
      }
    }
  }

  @override
  Future<void> cacheChild(ChildModel child) async {
    final box = HiveHelper.childrenBox;
    if (child.id != null) {
      await box.put(child.id, child.toJson());
    }
  }

  @override
  Future<void> removeCachedChild(int childId) async {
    final box = HiveHelper.childrenBox;
    await box.delete(childId);
  }

  @override
  Future<void> clearCache() async {
    final box = HiveHelper.childrenBox;
    await box.clear();
  }
}
