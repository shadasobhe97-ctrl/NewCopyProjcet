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
    this.nameEn = '',
    this.description = '',
    required this.requiresReference,
    required this.instructions,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      requiresReference: json['requires_reference'] as bool? ?? false,
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
