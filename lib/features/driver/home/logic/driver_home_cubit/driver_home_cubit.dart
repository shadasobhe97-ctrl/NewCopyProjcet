import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/driver/profile/data/models/driver_model.dart';

part 'driver_home_state.dart';

// ==========================================
// كوبيت إدارة شاشة الهوم متع السائق
// TODO: عند الربط بالـ API، استبدل جميع البيانات التجريبية بطلبات حقيقية
// ==========================================

class DriverHomeCubit extends Cubit<DriverHomeState> {
  DriverHomeCubit() : super(DriverHomeLoading());

  /// تحميل بيانات السائق - TODO: ربط بـ API endpoint الحقيقي
  Future<void> loadDriverHomeData() async {
    emit(DriverHomeLoading());

    try {
      // TODO: استبدل هذا بطلب API حقيقي
      // مثال: final response = await _driverRepository.getDriverHomeData(driverId);

      // ────────────────────────────────────────────
      // بيانات تجريبية - تُحذف عند الربط بالـ API
      // ────────────────────────────────────────────
      await Future.delayed(const Duration(milliseconds: 500));

      // تم تعديل البيانات لتطابق DriverModel المربوط بالباك إند
      final mockDriver = DriverModel(
        driverId: 1,
        userId: 1,
        fullName: 'محمد العربي',
        email: 'driver@test.com',
        phoneNumber: '+218 91 234 5678',
        alternativePhone: null,
        avatarUrl: null,
        gender: 'male',
        accountStatus: 'Approved',
      );

      // طلبات اشتراك تجريبية - تم تركها كقائمة فارغة عادية لتجنب أخطاء SubscriptionRequest
      const mockRequests = [];

      emit(
        DriverHomeLoaded(
          driver: mockDriver,
          isOnline: false,
          todayTripsCount: 0,
          todayStudentsCount: 0,
          newRequests: mockRequests,
          hasActiveTrip: false,
        ),
      );
    } catch (e) {
      emit(DriverHomeError('حدث خطأ في تحميل البيانات: ${e.toString()}'));
    }
  }

  Future<void> toggleOnlineStatus() async {
    final currentState = state;
    if (currentState is DriverHomeLoaded) {
      final newStatus = !currentState.isOnline;

      emit(currentState.copyWith(isOnline: newStatus));
    }
  }

  // تم إيقاف محتوى هذه الدوال مؤقتاً لتجنب الأخطاء حتى تقومي بإنشاء موديل الطلبات
  Future<void> acceptRequest(int requestId) async {
    // TODO: سيتم برمجتها لاحقاً
  }

  Future<void> rejectRequest(int requestId) async {
    // TODO: سيتم برمجتها لاحقاً
  }
}
