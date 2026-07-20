import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/features/driver/profile/data/models/driver_model.dart';
import 'package:kids_transport/features/driver/profile/data/repositories/driver_profile_repository.dart';
import 'package:kids_transport/features/driver/requests/data/models/driver_request_model.dart';
import 'package:kids_transport/features/driver/requests/data/repositories/driver_requests_repository.dart';
import 'package:kids_transport/features/driver/shared/di/driver_injection.dart';

part 'driver_home_state.dart';

// ==========================================
// كوبيت إدارة شاشة الهوم متع السائق
// ==========================================

class DriverHomeCubit extends Cubit<DriverHomeState> {
  DriverHomeCubit() : super(DriverHomeLoading());

  /// تحميل بيانات السائق والطلبات الجديدة
  Future<void> loadDriverHomeData() async {
    emit(DriverHomeLoading());

    try {
      // 1. جلب بيانات السائق
      final profileRepo = driverSl<DriverProfileRepository>();
      final driver = await profileRepo.getDriverProfile();

      // 2. جلب طلبات الاشتراك الجديدة المعلقة
      final requestsRepo = driverSl<DriverRequestsRepository>();
      final newRequests = await requestsRepo.getRequests(filter: 'pending');

      emit(
        DriverHomeLoaded(
          driver: driver,
          isOnline: false, // يمكن ربطه لاحقاً بحالة السيرفر
          todayTripsCount: 0,
          todayStudentsCount: 0,
          newRequests: newRequests,
          hasActiveTrip: false,
        ),
      );
    } catch (e) {
      // في حالة وجود خطأ، نحاول استخدام البيانات المحلية المخزنة كـ fallback
      try {
        final profileRepo = driverSl<DriverProfileRepository>();
        final name = profileRepo.getCachedFullName();
        final phone = profileRepo.getCachedPhoneNumber();

        final cachedDriver = DriverModel(
          driverId: 0,
          userId: 0,
          fullName: name.isNotEmpty ? name : 'السائق',
          email: '',
          phoneNumber: phone.isNotEmpty ? phone : '',
          alternativePhone: null,
          avatarUrl: null,
          gender: 'male',
          accountStatus: 'Approved',
        );

        emit(
          DriverHomeLoaded(
            driver: cachedDriver,
            isOnline: false,
            todayTripsCount: 0,
            todayStudentsCount: 0,
            newRequests: const [],
            hasActiveTrip: false,
          ),
        );
      } catch (_) {
        emit(DriverHomeError('حدث خطأ في تحميل البيانات: ${e.toString()}'));
      }
    }
  }

  Future<void> toggleOnlineStatus() async {
    final currentState = state;
    if (currentState is DriverHomeLoaded) {
      final newStatus = !currentState.isOnline;
      emit(currentState.copyWith(isOnline: newStatus));
    }
  }

  Future<void> acceptRequest(int requestId) async {
    try {
      final requestsRepo = driverSl<DriverRequestsRepository>();
      await requestsRepo.acceptRequest(requestId);
      await loadDriverHomeData(); // تحديث الصفحة الرئيسية
    } catch (e) {
      emit(DriverHomeError('فشل قبول الطلب: ${e.toString()}'));
    }
  }

  Future<void> rejectRequest(int requestId) async {
    try {
      final requestsRepo = driverSl<DriverRequestsRepository>();
      await requestsRepo.rejectRequest(requestId);
      await loadDriverHomeData(); // تحديث الصفحة الرئيسية
    } catch (e) {
      emit(DriverHomeError('فشل رفض الطلب: ${e.toString()}'));
    }
  }
}
