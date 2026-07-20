import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/children_repository.dart';
import '../../data/models/child_model.dart';
import '../../data/models/logistics_model.dart';
import 'children_state.dart';

export 'children_state.dart';

class ChildrenCubit extends Cubit<ChildrenState> {
  final ChildrenRepository _repository;

  ChildrenCubit(this._repository) : super(ChildrenInitial());

  Future<(ChildModel?, String?)> getChildDetails(String id) {
    return _repository.getChildDetails(id);
  }

  Future<(LogisticsModel?, String?)> getChildSubscription(String id) {
    return _repository.getChildSubscription(id);
  }

  Future<void> fetchChildren() async {
    debugPrint('========== CHILDREN SCREEN OPENED ==========');
    debugPrint('fetchChildren() called');

    // 1. القراءة من كاش Hive المحلي أولاً وعرضها فوراً
    final cached = await _repository.getCachedChildren();
    debugPrint('Cached children count: ${cached.length}');
    if (cached.isNotEmpty) {
      emit(ChildrenLoaded(cached));
    } else {
      // فقط إذا كان الكاش فارغاً نطلق حالة التحميل الكامل
      emit(ChildrenLoading());
    }

    // 2. جلب أحدث البيانات من Laravel API في الخلفية
    final (children, error) = await _repository.getMyChildren();
    if (error != null) {
      debugPrint('fetchChildren() ERROR: $error');
      // إذا فشل الطلب وكان هناك كاش معروض، نستمر بعرض الكاش ولا نعرض شاشة خطأ
      if (state is ChildrenLoaded &&
          (state as ChildrenLoaded).children.isNotEmpty) {
        emit(ChildrenLoaded((state as ChildrenLoaded).children));
      } else {
        emit(ChildrenError(error));
      }
    } else {
      debugPrint('fetchChildren() SUCCESS: ${children?.length ?? 0} children');
      emit(ChildrenLoaded(children ?? []));
    }
  }

  // دالة لتحديث القائمة بعد إضافة طفل جديد بنجاح
  void childAdded(ChildModel newChild) {
    if (state is ChildrenLoaded) {
      final currentList = (state as ChildrenLoaded).children;
      // استبدال الطفل إذا كان موجوداً بالفعل (وضع التعديل) أو إضافته
      final index = currentList.indexWhere((c) => c.id == newChild.id);
      final updatedList = List<ChildModel>.from(currentList);
      if (index != -1) {
        updatedList[index] = newChild;
      } else {
        updatedList.add(newChild);
      }
      emit(ChildrenLoaded(updatedList));
    } else {
      emit(ChildrenLoaded([newChild]));
    }
  }

  // دالة لحذف طفل من القائمة عبر الـ API والـ UI
  Future<void> deleteChild(int childId) async {
    final currentList = state is ChildrenLoaded
        ? (state as ChildrenLoaded).children
        : <ChildModel>[];

    emit(ChildrenActionLoading(List.from(currentList)));

    final (success, message) = await _repository.deleteChild(
      childId.toString(),
    );
    if (success) {
      final updatedList = List<ChildModel>.from(currentList)
        ..removeWhere((c) => c.id == childId);
      emit(ChildrenActionSuccess(updatedList, message));
    } else {
      emit(ChildrenActionError(List.from(currentList), message));
    }
  }
}
