import 'package:kids_transport/core/models/email_verification_info.dart';
import '../../data/models/parent_model.dart';

abstract class ParentProfileState {}

class ParentProfileInitial extends ParentProfileState {}

class ParentProfileLoading extends ParentProfileState {}

class ParentProfileLoaded extends ParentProfileState {
  final ParentModel parent;
  ParentProfileLoaded(this.parent);
}

class ParentProfileUpdateLoading extends ParentProfileState {
  final ParentModel currentParent;
  ParentProfileUpdateLoading(this.currentParent);
}

class ParentProfileSuccess extends ParentProfileState {
  final ParentModel parent;
  final String message;
  final EmailVerificationInfo? emailVerification;

  ParentProfileSuccess(
    this.parent,
    this.message, {
    this.emailVerification,
  });
}

class ParentProfileError extends ParentProfileState {
  final String message;
  ParentProfileError(this.message);
}
