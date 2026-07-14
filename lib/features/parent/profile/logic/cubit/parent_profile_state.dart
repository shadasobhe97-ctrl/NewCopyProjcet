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
  ParentProfileSuccess(this.parent, this.message);
}

class ParentProfileError extends ParentProfileState {
  final String message;
  ParentProfileError(this.message);
}
