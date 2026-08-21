import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'vehicle_state.dart';
import '../data/repositories/vehicle_repository.dart';

class VehicleCubit extends Cubit<VehicleState> {
  final VehicleRepository repository;

  VehicleCubit(this.repository) : super(VehicleInitial());

  // 📥 1. دالة جلب بيانات المركبة تلقائياً من السيرفر GET /api/v1/driver/profile/vehicle
  Future<void> getVehicleProfile() async {
    emit(VehicleLoading());
    try {
      final vehicle = await repository.getVehicleDetails();
      emit(VehicleDetailsSuccess(vehicle));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  // 📤 2. دالة تحديث بيانات المركبة الأساسية POST /api/v1/driver/profile/vehicle/{vehicleId}
  Future<void> updateDetails({
    required int vehicleId,
    String? brand,
    String? model,
    int? year,
    String? plateNumber,
    String? color,
    String? type,
    int? capacityManual,
    bool? hasAc,
    File? vehicleImage,
  }) async {
    emit(VehicleLoading());
    try {
      final updatedVehicle = await repository.updateVehicle(
        vehicleId: vehicleId,
        brand: brand,
        model: model,
        year: year,
        plateNumber: plateNumber,
        color: color,
        type: type,
        capacityManual: capacityManual,
        hasAc: hasAc,
        vehicleImage: vehicleImage,
      );

      // بث نجاح التحديث
      emit(VehicleDetailsSuccess(updatedVehicle));

      // 🌟 إعادة جلب بيانات المركبة فوراً من السيرفر (GET) لضمان تماثل البيانات
      await getVehicleProfile();
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  // 📄 دالة تحديث المستندات والوثائق الرسمية
  Future<void> updateDocuments({
    required String nationalId,
    required String licenseNumber,
    required String licenseExpiry,
  }) async {
    emit(VehicleLoading());
    try {
      final message = await repository.updateLegalData(
        nationalId: nationalId,
        licenseNumber: licenseNumber,
        licenseExpiry: licenseExpiry,
      );
      emit(VehicleDocumentsSuccess(message));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }
}
