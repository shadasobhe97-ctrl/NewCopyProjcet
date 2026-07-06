import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/children_repository.dart';
import '../../data/models/child_model.dart';
import 'children_state.dart';

export 'children_state.dart';

// --- Cubit ---
class ChildrenCubit extends Cubit<ChildrenState> {
  final ChildrenRepository _repository;

  ChildrenCubit(this._repository) : super(ChildrenInitial());

  Future<void> fetchChildren() async {
    emit(ChildrenLoading());
    try {
      final children = await _repository.getMyChildren();
      emit(ChildrenLoaded(children));
    } catch (e) {
      emit(ChildrenError("حدث خطأ أثناء جلب بيانات الأطفال."));
    }
  }

  // دالة لتحديث القائمة بعد إضافة طفل جديد بنجاح
  void childAdded(ChildModel newChild) {
    if (state is ChildrenLoaded) {
      final currentList = (state as ChildrenLoaded).children;
      emit(ChildrenLoaded([...currentList, newChild]));
    } else {
      emit(ChildrenLoaded([newChild]));
    }
  }
  // دالة لحذف طفل من القائمة
  void deleteChild(int childId) {
    if (state is ChildrenLoaded) {
      final currentList = List<ChildModel>.from((state as ChildrenLoaded).children);
      currentList.removeWhere((child) => child.id == childId);
      emit(ChildrenLoaded(currentList));
    }
  }
}
