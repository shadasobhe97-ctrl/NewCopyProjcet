import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/driver/profile/data/models/driver_legal_data_model.dart';
import 'package:kids_transport/features/driver/profile/data/repositories/driver_profile_repository.dart';
import 'driver_legal_data_state.dart';

class DriverLegalDataCubit extends Cubit<DriverLegalDataState> {
  final DriverProfileRepository repository;

  DriverLegalDataCubit(this.repository) : super(const DriverLegalDataInitial());

  DriverLegalDataModel? _cachedLegalData;

  DriverLegalDataModel? get cachedLegalData => _cachedLegalData;

  Future<void> fetchLegalData() async {
    emit(const DriverLegalDataLoading());
    try {
      final legalData = await repository.getLegalData();
      _cachedLegalData = legalData;
      emit(DriverLegalDataLoaded(legalData));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '').replaceAll('Exception:', '');
      emit(DriverLegalDataError(errorMsg));
    }
  }

  Future<void> updateLegalData({
    String? nationalId,
    String? licenseNumber,
    String? licenseExpiry,
    String? insuranceExpiry,
    Map<String, File>? newFiles,
  }) async {
    final currentModel = _cachedLegalData;
    if (currentModel != null) {
      emit(DriverLegalDataSaving(currentModel));
    } else {
      emit(const DriverLegalDataLoading());
    }

    try {
      await repository.updateLegalData(
        nationalId: nationalId,
        licenseNumber: licenseNumber,
        licenseExpiry: licenseExpiry,
        insuranceExpiry: insuranceExpiry,
        newFiles: newFiles,
      );

      // إعادة استدعاء GET مباشرة لعرض أحدث البيانات
      final freshData = await repository.getLegalData();
      _cachedLegalData = freshData;

      emit(DriverLegalDataSuccess(
        freshData: freshData,
        message: 'تم إرسال طلب تعديل الوثائق بنجاح.\nسيتم مراجعة الوثائق من قبل الإدارة.\nسيتم إيقاف الحساب مؤقتًا حتى انتهاء المراجعة.',
      ));
      emit(DriverLegalDataLoaded(freshData));
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '').replaceAll('Exception:', '');
      if (currentModel != null) {
        emit(DriverLegalDataLoaded(currentModel));
      }
      emit(DriverLegalDataError(errorMsg));
    }
  }
}
