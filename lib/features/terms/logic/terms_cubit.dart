import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import '../data/repositories/terms_repository.dart';
import 'terms_state.dart';

class TermsCubit extends Cubit<TermsState> {
  final TermsRepository _repository;

  TermsCubit(this._repository) : super(TermsInitial());

  Future<void> fetchTerms({required String audience}) async {
    emit(TermsLoading());
    try {
      final terms = await _repository.getTerms(audience: audience);
      emit(TermsLoaded(terms: terms));
    } on ApiException catch (e) {
      emit(TermsError(e.message));
    } catch (e) {
      emit(TermsError('حدث خطأ غير متوقع أثناء جلب الشروط والسياسات: $e'));
    }
  }

  Future<void> acceptTerms({required int termsId}) async {
    final currentState = state;
    if (currentState is! TermsLoaded) return;

    emit(currentState.copyWith(isAccepting: true, acceptErrorMessage: null));

    try {
      final success = await _repository.acceptTerms(termsId: termsId);
      if (success) {
        emit(currentState.copyWith(isAccepting: false, acceptSuccess: true));
      } else {
        emit(
          currentState.copyWith(
            isAccepting: false,
            acceptErrorMessage: 'فشل تأكيد الموافقة على الشروط.',
          ),
        );
      }
    } on ApiException catch (e) {
      emit(
        currentState.copyWith(
          isAccepting: false,
          acceptErrorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isAccepting: false,
          acceptErrorMessage: 'حدث خطأ غير متوقع: $e',
        ),
      );
    }
  }
}
