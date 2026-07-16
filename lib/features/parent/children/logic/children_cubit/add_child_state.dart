import '../../data/models/child_model.dart';

abstract class AddChildState {}

class AddChildInitial extends AddChildState {}

class AddChildStep1Valid extends AddChildState {}

class AddChildSubmitting extends AddChildState {}

class AddChildSuccess extends AddChildState {
  final ChildModel child;
  final String message;

  AddChildSuccess(this.child, this.message);
}

class AddChildError extends AddChildState {
  final String message;

  AddChildError(this.message);
}
