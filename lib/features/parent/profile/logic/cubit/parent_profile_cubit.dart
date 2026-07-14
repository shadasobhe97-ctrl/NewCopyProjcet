import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/parent_profile_repository.dart';
import 'parent_profile_state.dart';

class ParentProfileCubit extends Cubit<ParentProfileState> {
  final ParentProfileRepository repository;

  ParentProfileCubit(this.repository) : super(ParentProfileInitial());

  Future<void> fetchProfile() async {
    emit(ParentProfileLoading());
    try {
      final parent = await repository.getParentProfile();
      emit(ParentProfileLoaded(parent));
    } catch (e) {
      emit(ParentProfileError(e.toString().replaceAll('Exception:', '')));
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
    String? email,
    String? alternativePhone,
  }) async {
    if (state is ParentProfileLoaded) {
      emit(ParentProfileUpdateLoading((state as ParentProfileLoaded).parent));
    }
    try {
      final updatedParent = await repository.updateParentProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        alternativePhone: alternativePhone,
      );
      emit(ParentProfileSuccess(updatedParent, 'تم تحديث الملف الشخصي بنجاح'));
      emit(ParentProfileLoaded(updatedParent));
    } catch (e) {
      emit(ParentProfileError(e.toString().replaceAll('Exception:', '')));
    }
  }
}
