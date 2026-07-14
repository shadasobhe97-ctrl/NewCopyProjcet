class Municipality {
  final int id;
  final String name;

  Municipality({
    required this.id,
    required this.name,
  });

  factory Municipality.fromJson(Map<String, dynamic> json) {
    return Municipality(
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

class SubMunicipality {
  final int id;
  final String name;
  final Municipality municipality;

  SubMunicipality({
    required this.id,
    required this.name,
    required this.municipality,
  });

  factory SubMunicipality.fromJson(Map<String, dynamic> json) {
    return SubMunicipality(
      id: json['id'] as int,
      name: json['name'] as String,
      municipality: Municipality.fromJson(json['municipality'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'municipality': municipality.toJson(),
    };
  }
}

class Zone {
  final int id;
  final String name;
  final SubMunicipality subMunicipality;

  Zone({
    required this.id,
    required this.name,
    required this.subMunicipality,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as int,
      name: json['name'] as String,
      subMunicipality: SubMunicipality.fromJson(json['sub_municipality'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sub_municipality': subMunicipality.toJson(),
    };
  }
}
