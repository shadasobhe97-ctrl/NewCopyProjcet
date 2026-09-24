import '../datasources/terms_remote_data_source.dart';
import '../models/terms_model.dart';

class TermsRepository {
  final TermsRemoteDataSource _remoteDataSource;

  TermsRepository(this._remoteDataSource);

  Future<TermsModel> getTerms({required String audience}) {
    return _remoteDataSource.getTerms(audience: audience);
  }

  Future<bool> acceptTerms({required int termsId}) {
    return _remoteDataSource.acceptTerms(termsId: termsId);
  }
}
