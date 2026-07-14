import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import '../data/repositories/driver_preferences_repository.dart';
import 'driver_preferences_state.dart';

class DriverPreferencesCubit extends Cubit<DriverPreferencesState> {
  final DriverPreferencesRepository _repository;

  DriverPreferencesCubit(this._repository) : super(DriverPreferencesInitial());

  Future<void> loadPreferencesAndZones() async {
    emit(DriverPreferencesLoading());
    try {
      final preferences = await _repository.getPreferences();
      final zones = await _repository.getZones();
      emit(DriverPreferencesLoadSuccess(
        preferences: preferences,
        zones: zones,
      ));
    } on ApiException catch (e) {
      emit(DriverPreferencesError(e.message));
    } catch (e) {
      emit(DriverPreferencesError(e.toString().replaceAll('Exception:', '')));
    }
  }

  Future<void> savePreferences({
    required int shift,
    required String subscriptionType,
    required List<int> zoneIds,
  }) async {
    emit(DriverPreferencesSaveLoading());
    try {
      final success = await _repository.savePreferences(
        shift: shift,
        subscriptionType: subscriptionType,
        zoneIds: zoneIds,
      );
      if (success) {
        emit(DriverPreferencesSaveSuccess());
      } else {
        emit(const DriverPreferencesError('فشل حفظ التفضيلات.'));
      }
    } on ApiException catch (e) {
      emit(DriverPreferencesError(e.message));
    } catch (e) {
      emit(DriverPreferencesError(e.toString().replaceAll('Exception:', '')));
    }
  }
}
