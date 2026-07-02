import 'package:kids_transport/features/parent/children/data/models/child_model.dart';

abstract class ParentHomeState {}

class ParentHomeLoading extends ParentHomeState {}

// الحالة 1: مستخدم جديد تماماً ليس لديه أطفال مسجلين
class ParentNewUserMode extends ParentHomeState {}

// الحالة 2: لديه أطفال ولكن لا يوجد أي اشتراك نشط أو معلق
class ParentHasKidsNoSubscription extends ParentHomeState {
  final List<ChildModel> kids;
  ParentHasKidsNoSubscription({required this.kids});
}

// الحالة 3: لديه طلبات أو عقود معلقة بانتظار الموافقة أو التأكيد
class ParentPendingRequestsMode extends ParentHomeState {
  final List<Map<String, dynamic>> pendingRequests;
  ParentPendingRequestsMode({required this.pendingRequests});
}

// الحالة 4: لديه اشتراك فعال ورحلة جارية حالياً (التتبع المباشر)
class ParentActiveTripMode extends ParentHomeState {
  final List<Map<String, dynamic>> todayTrips;
  final Map<String, dynamic>? activeTrip; // بيانات الرحلة الجارية إن وجدت
  
  ParentActiveTripMode({required this.todayTrips, this.activeTrip});
}

class ParentHomeError extends ParentHomeState {
  final String errorMessage;
  ParentHomeError({required this.errorMessage});
}