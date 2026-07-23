import 'parsers.dart';

class ContractModel {
  final int id;
  final String contractNumber;
  final String status;
  final int totalTrips;
  final int completedTrips;
  final int driverAbsences;
  final int studentAbsences;

  ContractModel({
    required this.id,
    required this.contractNumber,
    required this.status,
    required this.totalTrips,
    required this.completedTrips,
    required this.driverAbsences,
    required this.studentAbsences,
  });

  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: parseInt(json['id']),
      contractNumber: json['number'] as String? ?? json['contract_number'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalTrips: parseInt(json['total_trips']),
      completedTrips: parseInt(json['completed_trips']),
      driverAbsences: parseInt(json['driver_absences']),
      studentAbsences: parseInt(json['student_absences']),
    );
  }
}
