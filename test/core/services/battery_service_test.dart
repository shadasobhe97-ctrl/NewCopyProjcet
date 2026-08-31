import 'package:flutter_test/flutter_test.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:kids_transport/core/services/battery_service.dart';

class FakeBattery implements Battery {
  final int? Function() onBatteryLevel;

  FakeBattery({required this.onBatteryLevel});

  @override
  Future<int> get batteryLevel async {
    final val = onBatteryLevel();
    if (val == null) {
      throw Exception('فشل قراءة شحن البطارية');
    }
    return val;
  }

  @override
  Stream<BatteryState> get onBatteryStateChanged => throw UnimplementedError();

  @override
  Future<BatteryState> get batteryState => throw UnimplementedError();

  @override
  Future<bool> get isInBatterySaveMode => throw UnimplementedError();
}

void main() {
  group('BatteryService Unit Tests', () {
    test('يُرجع نسبة البطارية عندما تكون القراءة ناجحة (مثلاً 45%)', () async {
      final fakeBattery = FakeBattery(onBatteryLevel: () => 45);
      final service = BatteryService(battery: fakeBattery);

      final level = await service.getBatteryLevel();
      expect(level, equals(45));
    });

    test('يُرجع نسبة البطارية عندما تكون 50%', () async {
      final fakeBattery = FakeBattery(onBatteryLevel: () => 50);
      final service = BatteryService(battery: fakeBattery);

      final level = await service.getBatteryLevel();
      expect(level, equals(50));
    });

    test('يُرجع null بأمان عند حدوث استثناء دون رمي Exception', () async {
      final fakeBattery = FakeBattery(onBatteryLevel: () => null);
      final service = BatteryService(battery: fakeBattery);

      final level = await service.getBatteryLevel();
      expect(level, isNull);
    });
  });
}
