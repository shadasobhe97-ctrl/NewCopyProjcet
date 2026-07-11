import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/child_model.dart';
import '../../data/models/transport_pref_model.dart';
import '../../data/repositories/children_repository.dart';
import 'add_child_state.dart';

export 'add_child_state.dart';

class AddChildCubit extends Cubit<AddChildState> {
  final ChildrenRepository _repository;

  String? imagePath;
  String? fullName;
  String? gender;
  DateTime? birthDate;
  int? gradeLevel;
  int? schoolId;
  String? schoolName;
  int? addressId;
  String? addressName;
  String? medicalNotes;

  ChildModel? editingChild;

  AddChildCubit(this._repository) : super(AddChildInitial());

  void setEditingChild(ChildModel child) {
    editingChild = child;
    imagePath = child.photoUrl;
    fullName = child.fullName;
    gender = child.gender;
    birthDate = child.birthDate;
    gradeLevel = child.gradeLevel;
    schoolId = child.schoolId;
    schoolName = child.schoolName;
    addressId = child.addressId;
    addressName = child.addressName;
    medicalNotes = child.medicalNotes;
    emit(AddChildInitial());
  }

  void clear() {
    editingChild = null;
    imagePath = null;
    fullName = null;
    gender = null;
    birthDate = null;
    gradeLevel = null;
    schoolId = null;
    schoolName = null;
    addressId = null;
    addressName = null;
    medicalNotes = null;
    emit(AddChildInitial());
  }

  void submitStep1({
    String? img,
    required String name,
    required String gen,
    required DateTime dob,
    required int grade,
    required int sId,
    required String sName,
    required int aId,
    required String aName,
    String? notes,
  }) {
    imagePath = img;
    fullName = name;
    gender = gen;
    birthDate = dob;
    gradeLevel = grade;
    schoolId = sId;
    schoolName = sName;
    addressId = aId;
    addressName = aName;
    medicalNotes = notes;

    emit(AddChildStep1Valid());
  }

  Future<void> submitStep2({required TransportPrefModel transportPref}) async {
    if (fullName == null ||
        gender == null ||
        birthDate == null ||
        gradeLevel == null ||
        schoolId == null ||
        schoolName == null ||
        addressId == null ||
        addressName == null) {
      emit(AddChildError('بيانات الخطوة الأولى غير مكتملة.'));
      return;
    }

    emit(AddChildSubmitting());

    // 1: روضة، 2: ابتدائي، 3: إعدادي، 4: ثانوي
    String gradeStr = 'روضة';
    if (gradeLevel == 2) gradeStr = 'ابتدائي';
    if (gradeLevel == 3) gradeStr = 'إعدادي';
    if (gradeLevel == 4) gradeStr = 'ثانوي';

    final childToSubmit = ChildModel(
      id: editingChild?.id,
      parentId: editingChild?.parentId,
      schoolId: schoolId!,
      addressId: addressId!,
      fullName: fullName!,
      gender: gender!,
      birthDate: birthDate!,
      grade: gradeStr,
      photoUrl: imagePath,
      medicalNotes: medicalNotes,
      logistics: transportPref.toLogistics(),
    );

    final (resultChild, message) = editingChild == null
        ? await _repository.addChild(childToSubmit, imagePath)
        : await _repository.updateChild(childToSubmit, imagePath);

    if (resultChild != null) {
      emit(AddChildSuccess(resultChild, message));
    } else {
      emit(AddChildError(message));
    }
  }
}
