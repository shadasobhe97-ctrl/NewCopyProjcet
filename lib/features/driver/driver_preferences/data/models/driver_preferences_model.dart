import 'coverage_model.dart';
import 'driver_shift_slots_model.dart';
import 'seat_slot_model.dart';

class DriverPreferencesModel {
  final int driverId;
  final DriverShiftSlotsModel shiftSlots;
  final String subscriptionType;
  final List<String> schoolStages;
  final SeatSlotModel seatSlots;
  final List<CoverageModel> coverage;

  DriverPreferencesModel({
    required this.driverId,
    required this.shiftSlots,
    required this.subscriptionType,
    required this.schoolStages,
    required this.seatSlots,
    required this.coverage,
  });

  factory DriverPreferencesModel.fromJson(Map<String, dynamic> json) {
    // 🛡️ دالة حماية: إذا جاءت البيانات من لارافل كمصفوفة فارغة [] تحولها لكائن فارغ {}
    Map<String, dynamic> safeMap(dynamic value) {
      if (value is Map) return Map<String, dynamic>.from(value);
      return {};
    }

    // 🛡️ معالجة التغطية: لارافل يرسلها [] عندما تكون فارغة، و {} عندما تكون ممتلئة
    List<CoverageModel> parsedCoverage = [];
    if (json['coverage'] is List) {
      parsedCoverage = (json['coverage'] as List)
          .map((e) => CoverageModel.fromJson(safeMap(e)))
          .toList();
    } else if (json['coverage'] is Map) {
      parsedCoverage = (json['coverage'] as Map).values
          .map((e) => CoverageModel.fromJson(safeMap(e)))
          .toList();
    }

    List<String> parsedSchoolStages = [];
    if (json['school_stages'] is List) {
      parsedSchoolStages = (json['school_stages'] as List)
          .map((e) => e.toString())
          .toList();
    }

    return DriverPreferencesModel(
      driverId: json['driver_id'] as int? ?? 0,
      shiftSlots: DriverShiftSlotsModel.fromJson(safeMap(json['shift_slots'])),
      subscriptionType: json['subscription_type'] as String? ?? '',
      schoolStages: parsedSchoolStages,
      seatSlots: SeatSlotModel.fromJson(safeMap(json['seat_slots'])),
      coverage: parsedCoverage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'shift_slots': shiftSlots.toJson(),
      'subscription_type': subscriptionType,
      'school_stages': schoolStages,
      'seat_slots': seatSlots.toJson(),
      'coverage': coverage.map((e) => e.toJson()).toList(),
    };
  }
}
