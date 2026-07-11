import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/children_repository.dart';
import '../../data/models/child_model.dart';
import 'children_state.dart';

export 'children_state.dart';

class ChildrenCubit extends Cubit<ChildrenState> {
  final ChildrenRepository _repository;

  ChildrenCubit(this._repository) : super(ChildrenInitial());

  Future<void> fetchChildren() async {
    emit(ChildrenLoading());
    final (children, error) = await _repository.getMyChildren();
    if (error != null) {
      emit(ChildrenError(error));
    } else {
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

    final (success, message) = await _repository.deleteChild(childId.toString());
    if (success) {
      final updatedList = List<ChildModel>.from(currentList)
        ..removeWhere((c) => c.id == childId);
      emit(ChildrenActionSuccess(updatedList, message));
    } else {
      emit(ChildrenActionError(List.from(currentList), message));
    }
  }
}
