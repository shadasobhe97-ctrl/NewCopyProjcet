import '../datasources/children_mock_data_source.dart';
import '../models/child_model.dart';
import '../models/school_model.dart';

class ChildrenRepository {
  final ChildrenMockDataSource _dataSource;

  ChildrenRepository(this._dataSource);

  Future<List<ChildModel>> getMyChildren() {
    return _dataSource.getMyChildren();
  }

  Future<List<SchoolModel>> searchSchools(String query) {
    return _dataSource.searchSchools(query);
  }

  Future<ChildModel> addChild(ChildModel child) {
    final childData = child.toJson()
      ..['school_name'] = child.schoolName
      ..['address_name'] = child.addressName;

    return _dataSource.addChild(childData);
  }
}
