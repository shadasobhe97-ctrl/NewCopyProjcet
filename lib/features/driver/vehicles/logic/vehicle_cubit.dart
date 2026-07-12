import 'package:flutter_bloc/flutter_bloc.dart';
import 'vehicle_state.dart';
import '../data/repositories/vehicle_repository.dart';

class VehicleCubit extends Cubit<VehicleState> {
  final VehicleRepository repository;

  VehicleCubit(this.repository) : super(VehicleInitial());

  // 📥 دالة جلب بيانات المركبة تلقائياً من السيرفر عند فتح الشاشة
  Future<void> getVehicleProfile() async {
    emit(VehicleLoading());
    try {
      final vehicle = await repository.getVehicleDetails();
      emit(VehicleDetailsSuccess(vehicle));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  // 📤 دالة تحديث بيانات المركبة الأساسية
  Future<void> updateDetails({
    required int vehicleId,
    required String brand,
    required String model,
    required int year,
    required String plateNumber,
    required int capacityManual,
  }) async {
    emit(VehicleLoading());
    try {
      final vehicle = await repository.updateVehicle(
        vehicleId: vehicleId,
        brand: brand,
        model: model,
        year: year,
        plateNumber: plateNumber,
        capacityManual: capacityManual,
      );
      emit(VehicleDetailsSuccess(vehicle));
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
      final message = await repository.updateLegalDocuments(
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
