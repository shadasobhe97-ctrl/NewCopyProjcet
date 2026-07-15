import 'package:hive_flutter/hive_flutter.dart';

class HiveHelper {
  HiveHelper._();

  // أسماء الصناديق (Box Names)
  static const String childrenBoxName = 'parent_children_box';
  static const String addressesBoxName = 'parent_addresses_box';
  static const String subscriptionsBoxName = 'parent_subscriptions_box';

  /// تهيئة Hive وفتح الصناديق المطلوبة
  static Future<void> init() async {
    await Hive.initFlutter();

    // فتح الصناديق لحفظ البيانات كـ Map<dynamic, dynamic> لتكون متوافقة مع الـ JSON
    await Hive.openBox<Map>(childrenBoxName);
    await Hive.openBox<Map>(addressesBoxName);
    await Hive.openBox<Map>(subscriptionsBoxName);
  }

  /// الحصول على صندوق الأطفال
  static Box<Map> get childrenBox => Hive.box<Map>(childrenBoxName);

  /// الحصول على صندوق العناوين
  static Box<Map> get addressesBox => Hive.box<Map>(addressesBoxName);

  /// الحصول على صندوق الاشتراكات
  static Box<Map> get subscriptionsBox => Hive.box<Map>(subscriptionsBoxName);

  /// مسح جميع الكاش المحلي (عند تسجيل الخروج مثلاً)
  static Future<void> clearAllCache() async {
    await childrenBox.clear();
    await addressesBox.clear();
    await subscriptionsBox.clear();
  }
}
