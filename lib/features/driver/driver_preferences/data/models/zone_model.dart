class ZoneModel {
  final int id;
  final String name;

  ZoneModel({
    required this.id,
    required this.name,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : (rawId != null ? int.tryParse(rawId.toString()) ?? 0 : 0);
    final rawName = json['name'] ?? json['zone_name'];

    return ZoneModel(
      id: parsedId,
      name: rawName?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
