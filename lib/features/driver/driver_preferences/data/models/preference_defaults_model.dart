import 'coverage_model.dart';

class PreferenceDefaultsModel {
  final List<Map<String, dynamic>> availableShiftSlots;
  final List<Map<String, dynamic>> availableSubscriptionTypes;
  final List<CoverageModel> geographyTree;

  PreferenceDefaultsModel({
    required this.availableShiftSlots,
    required this.availableSubscriptionTypes,
    required this.geographyTree,
  });

  factory PreferenceDefaultsModel.fromJson(Map<String, dynamic> json) {
    // 🛡️ دالة مساعدة لتحويل المصفوفة القادمة من الباك إند بأمان
    List<Map<String, dynamic>> parseListMap(dynamic data) {
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    }

    return PreferenceDefaultsModel(
      availableShiftSlots: parseListMap(json['available_shift_slots']),
      availableSubscriptionTypes: parseListMap(
        json['available_subscription_types'],
      ),
      geographyTree:
          (json['geography_tree'] as List<dynamic>?)
              ?.map((e) => CoverageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'available_shift_slots': availableShiftSlots,
      'available_subscription_types': availableSubscriptionTypes,
      'geography_tree': geographyTree.map((e) => e.toJson()).toList(),
    };
  }
}
