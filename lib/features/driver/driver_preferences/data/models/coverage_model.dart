import 'zone_model.dart';

class CoverageModel {
  final String municipalityName;
  final String subMunicipalityName;
  final List<ZoneModel> zones;

  CoverageModel({
    required this.municipalityName,
    required this.subMunicipalityName,
    required this.zones,
  });

  factory CoverageModel.fromJson(Map<String, dynamic> json) {
    return CoverageModel(
      municipalityName: json['municipality_name'] as String? ?? '',
      subMunicipalityName: json['sub_municipality_name'] as String? ?? '',
      zones: (json['zones'] as List<dynamic>?)
              ?.map((e) => ZoneModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'municipality_name': municipalityName,
      'sub_municipality_name': subMunicipalityName,
      'zones': zones.map((e) => e.toJson()).toList(),
    };
  }
}
