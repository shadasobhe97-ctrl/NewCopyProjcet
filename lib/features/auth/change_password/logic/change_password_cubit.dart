import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/change_password_repository.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final ChangePasswordRepository _repository;

  ChangePasswordCubit(this._repository) : super(ChangePasswordInitial());

  Future<void> changePassword({
    required String oldPassword,
    required String password,
    required String passwordConfirmation,
    required bool isDriver,
  }) async {
    emit(ChangePasswordLoading());
    try {
      final resultMessage = await _repository.changePassword(
        oldPassword: oldPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
        isDriver: isDriver,
      );
      emit(ChangePasswordSuccess(resultMessage));
    } catch (e) {
      emit(ChangePasswordFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
