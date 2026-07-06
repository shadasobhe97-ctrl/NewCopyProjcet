import '../models/child_model.dart';
import '../models/school_model.dart';
import '../models/transport_pref_model.dart';

class ChildrenMockDataSource {
  // بيانات تجريبية تحاكي استجابة API
  List<ChildModel> _mockChildren = [
    ChildModel(
      id: 1,
      name: "أحمد محمود",
      gender: "male",
      birthDate: DateTime(2014, 5, 12),
      gradeLevel: 2, // ابتدائي
      schoolId: 101,
      schoolName: "مدرسة طرابلس المركزية",
      addressId: 1,
      addressName: "المنزل - حي الأندلس",
      qrToken: "darbi_qr_token_88f9a2b",
      transportPref: TransportPrefModel(
        subscriptionType: "monthly",
        period: "morning",
        serviceType: "both",
        startDate: DateTime.now(),
        schoolStartTime: "08:00 AM",
        schoolEndTime: "01:30 PM",
      ),
      hasActiveSubscription: true,
    ),
  ];

  Future<List<ChildModel>> getMyChildren() async {
    await Future.delayed(const Duration(seconds: 1)); // محاكاة الشبكة
    return _mockChildren;
  }

  Future<List<SchoolModel>> searchSchools(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final schools = [
      SchoolModel(id: 101, name: "مدرسة طرابلس المركزية", region: "وسط المدينة", address: "شارع الاستقلال"),
      SchoolModel(id: 102, name: "مدرسة المعرفة النموذجية", region: "تاجوراء", address: "الشارع الرئيسي"),
      SchoolModel(id: 103, name: "مدرسة النور الدولية", region: "حي الأندلس", address: "بالقرب من الكوبري"),
    ];
    if (query.isEmpty) return schools;
    return schools.where((s) => s.name.contains(query)).toList();
  }

  Future<ChildModel> addChild(Map<String, dynamic> childData) async {
    await Future.delayed(const Duration(seconds: 2)); // محاكاة عملية الحفظ
    
    // محاكاة استجابة الـ Backend بإضافة ID و QR Token للبيانات المُرسلة
    final newChild = ChildModel.fromJson({
      'id': DateTime.now().millisecondsSinceEpoch,
      'qr_token': 'darbi_qr_token_${DateTime.now().millisecondsSinceEpoch}',
      'school_name': 'مدرسة محددة من الـ API', // في الواقع الباك إند يرجع الاسم
      'address_name': 'عنوان محفوظ',
      ...childData,
    });
    
    _mockChildren.add(newChild);
    return newChild;
  }
}