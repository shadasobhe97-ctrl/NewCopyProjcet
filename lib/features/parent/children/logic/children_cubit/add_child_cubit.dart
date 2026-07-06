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

  AddChildCubit(this._repository) : super(AddChildInitial());

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

    try {
      final childToSubmit = ChildModel(
        id: 0,
        qrToken: '',
        name: fullName!,
        image: imagePath,
        gender: gender!,
        birthDate: birthDate!,
        gradeLevel: gradeLevel!,
        schoolId: schoolId!,
        schoolName: schoolName!,
        addressId: addressId!,
        addressName: addressName!,
        medicalNotes: medicalNotes,
        transportPref: transportPref,
      );

      final newChild = await _repository.addChild(childToSubmit);
      emit(AddChildSuccess(newChild));
    } catch (_) {
      emit(AddChildError('حدث خطأ أثناء حفظ بيانات الطفل.'));
    }
  }
}
