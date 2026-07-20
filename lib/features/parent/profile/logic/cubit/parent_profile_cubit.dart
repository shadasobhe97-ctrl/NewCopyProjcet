import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/parent_model.dart';
import '../../data/repositories/parent_profile_repository.dart';
import 'parent_profile_state.dart';

class ParentProfileCubit extends Cubit<ParentProfileState> {
  final ParentProfileRepository repository;

  // نحتفظ بآخر بيانات ناجحة بشكل منفصل عن الـ state، لأن الاعتماد على
  // "state is ParentProfileLoaded" فقط كان يفشل في حالة كانت آخر حالة
  // ParentProfileError (مثلاً بعد فشل تحديث سابق)، فما كانت تظهر حالة
  // التحميل (isSaving) بالمحاولة التالية.
  ParentModel? _currentParent;

  ParentProfileCubit(this.repository) : super(ParentProfileInitial());

  Future<void> fetchProfile() async {
    emit(ParentProfileLoading());
    try {
      final parent = await repository.getParentProfile();
      _currentParent = parent;
      emit(ParentProfileLoaded(parent));
    } catch (e) {
      debugPrint('❌ [ParentProfileCubit] fetchProfile: $e');
      emit(ParentProfileError(e.toString().replaceAll('Exception:', '')));
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
    String? email,
    String? alternativePhone,
    File? avatarFile,
  }) async {
    if (_currentParent != null) {
      emit(ParentProfileUpdateLoading(_currentParent!));
    }
    try {
      final updatedParent = await repository.updateParentProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        alternativePhone: alternativePhone,
        avatarFile: avatarFile,
      );
      _currentParent = updatedParent;
      debugPrint(
        '✅ [ParentProfileCubit] تحديث ناجح — avatarUrl: ${updatedParent.avatarUrl}, '
        'emailChangePending: ${updatedParent.emailChangePending}',
      );
      emit(ParentProfileSuccess(updatedParent, 'تم تحديث الملف الشخصي بنجاح'));
      emit(ParentProfileLoaded(updatedParent));
    } catch (e) {
      debugPrint('❌ [ParentProfileCubit] updateProfile: $e');
      emit(ParentProfileError(e.toString().replaceAll('Exception:', '')));
    }
  }

  String getCachedFullName() => repository.getCachedFullName();
  String getCachedPhoneNumber() => repository.getCachedPhoneNumber();
}
