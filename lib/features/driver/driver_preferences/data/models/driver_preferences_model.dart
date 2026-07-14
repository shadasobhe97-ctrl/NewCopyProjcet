class DriverPreferencesModel {
  final int driverId;
  final int shift;
  final String subscriptionType;
  final CoverageModel coverage;

  DriverPreferencesModel({
    required this.driverId,
    required this.shift,
    required this.subscriptionType,
    required this.coverage,
  });

  factory DriverPreferencesModel.fromJson(Map<String, dynamic> json) {
    return DriverPreferencesModel(
      driverId: json['driver_id'] as int,
      shift: json['shift'] as int,
      subscriptionType: json['subscription_type'] as String,
      coverage: CoverageModel.fromJson(json['coverage'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'shift': shift,
      'subscription_type': subscriptionType,
      'coverage': coverage.toJson(),
    };
  }
}

class CoverageModel {
  final Map<String, MunicipalityCoverageModel> coverages;

  CoverageModel({required this.coverages});

  factory CoverageModel.fromJson(Map<String, dynamic> json) {
    final map = <String, MunicipalityCoverageModel>{};
    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        map[key] = MunicipalityCoverageModel.fromJson(value);
      }
    });
    return CoverageModel(coverages: map);
  }

  Map<String, dynamic> toJson() {
    return coverages.map((key, value) => MapEntry(key, value.toJson()));
  }
}

class MunicipalityCoverageModel {
  final String municipalityName;
  final String subMunicipalityName;
  final List<ZoneModel> zones;

  MunicipalityCoverageModel({
    required this.municipalityName,
    required this.subMunicipalityName,
    required this.zones,
  });

  factory MunicipalityCoverageModel.fromJson(Map<String, dynamic> json) {
    return MunicipalityCoverageModel(
      municipalityName: json['municipality_name'] as String,
      subMunicipalityName: json['sub_municipality_name'] as String,
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

class ZoneModel {
  final int id;
  final String name;

  ZoneModel({
    required this.id,
    required this.name,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
