import 'package:kids_transport/features/parent/children/data/models/child_model.dart';

abstract class ChildState {}

class ChildInitial extends ChildState {}

class ChildLoading extends ChildState {}

class ChildLoaded extends ChildState {
  final List<ChildModel> children;
  ChildLoaded({required this.children});
}

class ChildError extends ChildState {
  final String message;
  ChildError({required this.message});
}

class ChildDeleted extends ChildState {}

class ChildAdded extends ChildState {}
