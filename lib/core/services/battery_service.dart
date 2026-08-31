import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';

/// خدمة قراءة مستوى بطارية الهاتف للتحقق قبل بدء الرحلات
class BatteryService {
  final Battery _battery;

  BatteryService({Battery? battery}) : _battery = battery ?? Battery();

  /// إرجاع مستوى البطارية الحالي كنسبة مئوية (0 - 100)
  /// وفي حال فشل القراءة لأي سبب من المنصة يتم إرجاع `null` بأمان دون رفع استثناء
  Future<int?> getBatteryLevel() async {
    try {
      final level = await _battery.batteryLevel;
      return level;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ [BatteryService Error]: فشل قراءة مستوى البطارية: $e');
      }
      return null;
    }
  }
}
