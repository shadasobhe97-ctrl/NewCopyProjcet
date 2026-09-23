import '../datasources/change_password_remote_data_source.dart';

class ChangePasswordRepository {
  final ChangePasswordRemoteDataSource _remoteDataSource;

  ChangePasswordRepository(this._remoteDataSource);

  Future<String> changePassword({
    required String oldPassword,
    required String password,
    required String passwordConfirmation,
    required bool isDriver,
  }) {
    return _remoteDataSource.changePassword(
      oldPassword: oldPassword,
      password: password,
      passwordConfirmation: passwordConfirmation,
      isDriver: isDriver,
    );
  }
}
