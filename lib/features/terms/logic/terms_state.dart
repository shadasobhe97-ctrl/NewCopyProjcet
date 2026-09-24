import '../data/models/terms_model.dart';

abstract class TermsState {
  const TermsState();
}

class TermsInitial extends TermsState {}

class TermsLoading extends TermsState {}

class TermsLoaded extends TermsState {
  final TermsModel terms;
  final bool isAccepting;
  final bool acceptSuccess;
  final String? acceptErrorMessage;

  const TermsLoaded({
    required this.terms,
    this.isAccepting = false,
    this.acceptSuccess = false,
    this.acceptErrorMessage,
  });

  TermsLoaded copyWith({
    TermsModel? terms,
    bool? isAccepting,
    bool? acceptSuccess,
    String? acceptErrorMessage,
  }) {
    return TermsLoaded(
      terms: terms ?? this.terms,
      isAccepting: isAccepting ?? this.isAccepting,
      acceptSuccess: acceptSuccess ?? this.acceptSuccess,
      acceptErrorMessage: acceptErrorMessage,
    );
  }
}

class TermsError extends TermsState {
  final String message;

  const TermsError(this.message);
}
