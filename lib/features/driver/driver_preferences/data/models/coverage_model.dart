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
    final mName = json['municipality_name']?.toString() ??
        json['municipality']?['name']?.toString() ??
        json['name']?.toString() ??
        '';
    final subName = json['sub_municipality_name']?.toString() ??
        json['sub_municipality']?['name']?.toString() ??
        json['name']?.toString() ??
        '';

    final List<ZoneModel> parsedZones = [];
    final rawZones = json['zones'];
    if (rawZones is List) {
      for (final item in rawZones) {
        if (item is Map) {
          parsedZones.add(ZoneModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return CoverageModel(
      municipalityName: mName,
      subMunicipalityName: subName,
      zones: parsedZones,
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
