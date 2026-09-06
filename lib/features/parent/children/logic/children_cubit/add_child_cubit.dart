import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/child_model.dart';
import '../../data/models/school_model.dart';
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
  String? addressId;
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
    String? notes,
  }) {
    imagePath = img;
    fullName = name;
    gender = gen;
    birthDate = dob;
    gradeLevel = grade;
    medicalNotes = notes;

    emit(AddChildStep1Valid());
  }

  void setStep2LocationAndSchool({
    required int sId,
    required String sName,
    required String aId,
    required String aName,
  }) {
    schoolId = sId;
    schoolName = sName;
    addressId = aId;
    addressName = aName;
  }

  Future<void> submitStep2({
    required TransportPrefModel transportPref,
    int? sId,
    String? sName,
    String? aId,
    String? aName,
    ChildModel? existingChild,
  }) async {
    final activeChild = existingChild ?? editingChild;

    if (sId != null) schoolId = sId;
    if (sName != null) schoolName = sName;
    if (aId != null) addressId = aId;
    if (aName != null) addressName = aName;

    if (fullName == null ||
        gender == null ||
        birthDate == null ||
        gradeLevel == null) {
      emit(AddChildError('الرجاء استكمال بيانات الطفل الأساسية أولاً.'));
      return;
    }

    if (schoolId == null || addressId == null) {
      emit(AddChildError('الرجاء اختيار المدرسة وعنوان المنزل.'));
      return;
    }

    emit(AddChildSubmitting());

    final gradeStr = (gradeLevel ?? 0).toString();

    debugPrint('📸 [AddChildCubit] imagePath: $imagePath');
    debugPrint('📸 [AddChildCubit] activeChild?.id: ${activeChild?.id}');

    final childToSubmit = ChildModel(
      id: activeChild?.id,
      userId: activeChild?.userId,
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

    final isEditMode = activeChild != null || childToSubmit.id != null;
    debugPrint('📸 [AddChildCubit] isEditMode: $isEditMode (id: ${childToSubmit.id})');

    final (resultChild, message) = isEditMode
        ? await _repository.updateChild(childToSubmit, imagePath)
        : await _repository.addChild(childToSubmit, imagePath);

    debugPrint('📸 [AddChildCubit] resultChild?.photoUrl: ${resultChild?.photoUrl}');

    if (resultChild != null) {
      emit(AddChildSuccess(resultChild, message));
    } else {
      emit(AddChildError(message));
    }
  }

  Future<void> submitChildPersonalDataOnly({
    required ChildModel existingChild,
  }) async {
    if (fullName == null ||
        gender == null ||
        birthDate == null ||
        gradeLevel == null) {
      emit(AddChildError('الرجاء استكمال بيانات الطفل الأساسية أولاً.'));
      return;
    }

    emit(AddChildSubmitting());

    final gradeStr = (gradeLevel ?? 0).toString();

    final childToSubmit = ChildModel(
      id: existingChild.id,
      userId: existingChild.userId,
      schoolId: existingChild.schoolId,
      addressId: existingChild.addressId,
      fullName: fullName!,
      gender: gender!,
      birthDate: birthDate!,
      grade: gradeStr,
      photoUrl: imagePath,
      medicalNotes: medicalNotes,
      logistics: existingChild.logistics,
    );

    final (resultChild, message) = await _repository.updateChildPersonalData(
      childToSubmit,
      imagePath,
    );

    if (resultChild != null) {
      emit(AddChildSuccess(resultChild, message));
    } else {
      emit(AddChildError(message));
    }
  }

  Future<void> submitChildTransportDataOnly({
    required ChildModel existingChild,
    required TransportPrefModel transportPref,
    required int sId,
    required dynamic aId,
  }) async {
    emit(AddChildSubmitting());

    final (resultChild, message) = await _repository.updateChildTransportData(
      childId: existingChild.id.toString(),
      schoolId: sId,
      addressId: aId,
      preferredTimeSlot: transportPref.period,
      tripDirection: transportPref.serviceType,
      startDate: transportPref.startDate,
      endDate: transportPref.endDate,
      subscriptionType: transportPref.subscriptionType,
      pickupTime: transportPref.schoolStartTime,
      dropoffTime: transportPref.schoolEndTime,
    );

    if (resultChild != null) {
      emit(AddChildSuccess(resultChild, message));
    } else {
      emit(AddChildError(message));
    }
  }

  Future<(List<SchoolModel>?, String?)> searchSchools(String query) async {
    return await _repository.searchSchools(query);
  }
}
