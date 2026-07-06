import '../../data/models/child_model.dart';

abstract class ChildrenState {}

class ChildrenInitial extends ChildrenState {}

class ChildrenLoading extends ChildrenState {}

class ChildrenLoaded extends ChildrenState {
  final List<ChildModel> children;
  
  ChildrenLoaded(this.children);
}

class ChildrenError extends ChildrenState {
  final String message;
  
  ChildrenError(this.message);
}