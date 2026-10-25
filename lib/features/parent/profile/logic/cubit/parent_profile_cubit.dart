import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/services/storage_service.dart';
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
    dynamic avatarFile,
    bool removeAvatar = false,
  }) async {
    if (_currentParent != null) {
      emit(ParentProfileUpdateLoading(_currentParent!));
    }
    try {
      final result = await repository.updateParentProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        alternativePhone: alternativePhone,
        avatarFile: avatarFile,
        removeAvatar: removeAvatar,
      );

      // إعادة جلب أحدث البيانات من الباك إند فوراً بعد عملية التعديل (Refresh)
      final freshParent = await repository.getParentProfile();
      final effectiveAvatar = freshParent.avatarUrl ?? StorageService.getAvatarUrl();
      final updatedParent = freshParent.copyWith(avatarUrl: effectiveAvatar);
      _currentParent = updatedParent;

      debugPrint(
        '✅ [ParentProfileCubit] تحديث ورفرش ناجح من الباك إند — avatarUrl: ${updatedParent.avatarUrl}, '
        'emailChangePending: ${updatedParent.emailChangePending}',
      );
      emit(
        ParentProfileSuccess(
          updatedParent,
          result.message,
          emailVerification: result.emailVerification,
        ),
      );
      emit(ParentProfileLoaded(updatedParent));
    } catch (e) {
      debugPrint('❌ [ParentProfileCubit] updateProfile: $e');
      emit(ParentProfileError(e.toString().replaceAll('Exception:', '')));
    }
  }

  Future<void> cancelEmailChange() async {
    try {
      await repository.cancelEmailChange();
      await fetchProfile();
    } catch (e) {
      debugPrint('❌ [ParentProfileCubit] cancelEmailChange: $e');
      emit(ParentProfileError(e.toString().replaceAll('Exception:', '')));
      rethrow;
    }
  }

  Future<String> checkEmailChangeStatus() async {
    try {
      final status = await repository.getEmailChangeStatus();
      debugPrint(
        '📥 [ParentProfileCubit] checkEmailChangeStatus status => $status',
      );
      if (status == 'verified' || status == 'rejected' || status == 'expired') {
        await fetchProfile();
      }
      return status;
    } catch (e) {
      debugPrint('❌ [ParentProfileCubit] checkEmailChangeStatus: $e');
      emit(ParentProfileError(e.toString().replaceAll('Exception:', '')));
      rethrow;
    }
  }

  String getCachedFullName() => repository.getCachedFullName();
  String getCachedPhoneNumber() => repository.getCachedPhoneNumber();
}
