import '../models/subscription_model.dart';

abstract class SubscriptionsDataSource {
  Future<List<SubscriptionModel>> getSubscriptions();
  Future<void> cancelSubscription(int id);
}

class SubscriptionsMockDataSourceImpl implements SubscriptionsDataSource {
  // بيانات تجريبية مطابقة تماماً للمواصفات والمتطلبات
  final List<SubscriptionModel> _mockSubscriptions = [
    SubscriptionModel(
      id: 1,
      driver: const SubscriptionDriver(
        id: 101,
        phone: '0912345678',
        rating: 4.8,
        user: SubscriptionUser(
          fullName: 'خالد مصطفى الورفلي',
          avatarUrl: null, // سيقوم الـ UI بعرض Avatar بأول حرفين من الاسم
        ),
      ),
      children: const [
        SubscriptionChild(
          id: 10,
          fullName: 'يوسف خالد الورفلي',
          photoUrl: null,
          grade: 'الصف الخامس',
          school: SubscriptionSchool(name: 'مدرسة طرابلس المركزية'),
        ),
        SubscriptionChild(
          id: 11,
          fullName: 'ريم خالد الورفلي',
          photoUrl: null,
          grade: 'الصف الثالث',
          school: SubscriptionSchool(name: 'مدرسة طرابلس المركزية'),
        ),
        SubscriptionChild(
          id: 12,
          fullName: 'عمر خالد الورفلي',
          photoUrl: null,
          grade: 'الصف الأول',
          school: SubscriptionSchool(name: 'مدرسة المعرفة النموذجية'),
        ),
      ],
      childrenCount: 3,
      subscriptionType: 'monthly',
      status: 'pending',
      createdAt: '2026/07/12',
      startDate: '2026/09/01',
      endDate: '2027/06/30',
      totalPrice: 500.0,
      timing: '07:30 ص - 01:30 م',
      direction: 'both', // ذهاب وعودة
      notes: 'الرجاء الاتصال بالوالدة عند الوصول بـ 5 دقائق.',
    ),
    SubscriptionModel(
      id: 2,
      driver: const SubscriptionDriver(
        id: 102,
        phone: '0921112233',
        rating: 4.5,
        user: SubscriptionUser(fullName: 'إبراهيم البدري', avatarUrl: null),
      ),
      children: const [
        SubscriptionChild(
          id: 13,
          fullName: 'سارة إبراهيم البدري',
          photoUrl: null,
          grade: 'تمهيدي',
          school: SubscriptionSchool(name: 'روضة أزهار الغد'),
        ),
        SubscriptionChild(
          id: 14,
          fullName: 'أحمد إبراهيم البدري',
          photoUrl: null,
          grade: 'الصف الثاني',
          school: SubscriptionSchool(name: 'مدرسة المعرفة النموذجية'),
        ),
      ],
      childrenCount: 2,
      subscriptionType: 'monthly',
      status: 'pending',
      createdAt: '2026/07/10',
      startDate: '2026/09/01',
      endDate: '2027/06/30',
      totalPrice: 350.0,
      timing: '08:00 ص - 02:00 م',
      direction: 'both',
      notes: null, // لا يوجد ملاحظات للتأكد من عدم عرض القسم
    ),

  ];

  @override
  Future<List<SubscriptionModel>> getSubscriptions() async {
    // محاكاة تأخير الشبكة لتظهر شاشات الهيكل العظمي (Skeleton)
    await Future.delayed(const Duration(milliseconds: 1200));
    return List<SubscriptionModel>.from(_mockSubscriptions);
  }

  @override
  Future<void> cancelSubscription(int id) async {
    // محاكاة تأخير الشبكة لعملية الإلغاء
    await Future.delayed(const Duration(milliseconds: 1000));
    _mockSubscriptions.removeWhere((sub) => sub.id == id);
  }
}
