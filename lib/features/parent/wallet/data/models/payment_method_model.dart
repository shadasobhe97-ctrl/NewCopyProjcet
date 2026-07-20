class PaymentMethodModel {
  final String id;
  final String name;
  final String nameEn;
  final String description;
  final bool requiresReference;
  final List<String> instructions;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.requiresReference,
    required this.instructions,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      description: json['description'] ?? '',
      requiresReference: json['requires_reference'] ?? false,
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
