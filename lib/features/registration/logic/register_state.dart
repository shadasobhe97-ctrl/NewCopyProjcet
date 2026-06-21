abstract class RegisterState {}

class RegisterInitial extends RegisterState {}

// الحالات الخاصة بولي الأمر (Parent)
class ParentOtpSentLoading extends RegisterState {}
class ParentOtpSentSuccess extends RegisterState {
  final String message;
  ParentOtpSentSuccess(this.message);
}
class ParentOtpSentError extends RegisterState {
  final String errorMessage;
  ParentOtpSentError(this.errorMessage);
}

class ParentRegisterLoading extends RegisterState {}
class ParentRegisterSuccess extends RegisterState {
  final String message;
  ParentRegisterSuccess(this.message);
}
class ParentRegisterError extends RegisterState {
  final String errorMessage;
  ParentRegisterError(this.errorMessage);
}

// الحالات الخاصة بالسائق (Driver)
class DriverRegisterFirstStageLoading extends RegisterState {}
class DriverRegisterFirstStageSuccess extends RegisterState {
  final String message;
  final int userId;
  DriverRegisterFirstStageSuccess(this.message, this.userId);
}
class DriverRegisterFirstStageError extends RegisterState {
  final String errorMessage;
  DriverRegisterFirstStageError(this.errorMessage);
}

class DriverVerifyOtpLoading extends RegisterState {}
class DriverVerifyOtpSuccess extends RegisterState {
  final String message;
  DriverVerifyOtpSuccess(this.message);
}
class DriverVerifyOtpError extends RegisterState {
  final String errorMessage;
  DriverVerifyOtpError(this.errorMessage);
}

class DriverCompleteProfileLoading extends RegisterState {}
class DriverCompleteProfileSuccess extends RegisterState {
  final String message;
  DriverCompleteProfileSuccess(this.message);
}
class DriverCompleteProfileError extends RegisterState {
  final String errorMessage;
  DriverCompleteProfileError(this.errorMessage);
}

// حالة الموقع المشتركة
class LocationSaveLoading extends RegisterState {}
class LocationSaveSuccess extends RegisterState {
  final String message;
  LocationSaveSuccess(this.message);
}
class LocationSaveError extends RegisterState {
  final String errorMessage;
  LocationSaveError(this.errorMessage);
}