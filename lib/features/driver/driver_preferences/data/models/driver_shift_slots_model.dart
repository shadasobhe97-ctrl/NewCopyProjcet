class DriverShiftSlotsModel {
  final bool morningGo;
  final bool morningReturn;
  final bool afternoonGo;
  final bool afternoonReturn;

  DriverShiftSlotsModel({
    required this.morningGo,
    required this.morningReturn,
    required this.afternoonGo,
    required this.afternoonReturn,
  });

  factory DriverShiftSlotsModel.fromJson(Map<String, dynamic> json) {
    return DriverShiftSlotsModel(
      morningGo: json['morning_go'] as bool? ?? false,
      morningReturn: json['morning_return'] as bool? ?? false,
      afternoonGo: json['afternoon_go'] as bool? ?? false,
      afternoonReturn: json['afternoon_return'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'morning_go': morningGo,
      'morning_return': morningReturn,
      'afternoon_go': afternoonGo,
      'afternoon_return': afternoonReturn,
    };
  }
}
