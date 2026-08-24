import 'coverage_model.dart';
import 'zone_model.dart';

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

    final List<CoverageModel> geographyTreeList = [];
    final rawGeo = json['geography_tree'] ?? json['zones_tree'] ?? json;
    if (rawGeo is List) {
      for (final item in rawGeo) {
        if (item is Map) {
          final mName = item['name']?.toString() ?? item['municipality_name']?.toString() ?? 'البلدية';
          final subTree = item['sub_municipalities'];
          if (subTree is List) {
            for (final subItem in subTree) {
              if (subItem is Map) {
                final subName = subItem['name']?.toString() ?? subItem['sub_municipality_name']?.toString() ?? '';
                final List<ZoneModel> zList = [];
                final rawZ = subItem['zones'];
                if (rawZ is List) {
                  for (final z in rawZ) {
                    if (z is Map) {
                      zList.add(ZoneModel.fromJson(Map<String, dynamic>.from(z)));
                    }
                  }
                }
                geographyTreeList.add(
                  CoverageModel(
                    municipalityName: mName,
                    subMunicipalityName: subName,
                    zones: zList,
                  ),
                );
              }
            }
          } else {
            geographyTreeList.add(
              CoverageModel.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
      }
    }

    return PreferenceDefaultsModel(
      availableShiftSlots: parseListMap(json['available_shift_slots']),
      availableSubscriptionTypes: parseListMap(
        json['available_subscription_types'],
      ),
      geographyTree: geographyTreeList,
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
