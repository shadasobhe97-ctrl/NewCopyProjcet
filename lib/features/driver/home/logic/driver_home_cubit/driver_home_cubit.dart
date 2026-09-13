import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import 'package:kids_transport/features/driver/profile/data/models/driver_model.dart';
import 'package:kids_transport/features/driver/profile/data/repositories/driver_profile_repository.dart';
import 'package:kids_transport/features/driver/requests/data/models/driver_request_model.dart';
import 'package:kids_transport/features/driver/requests/data/repositories/driver_requests_repository.dart';
import 'package:kids_transport/features/driver/shared/di/driver_injection.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_model.dart';
import 'package:kids_transport/features/driver/trips/data/repositories/driver_trips_repository.dart';

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

      // 3. اكتشاف الرحلة النشطة الحقيقية من رحلات اليوم.
      //    نستخدم API قائم: GET /v1/driver/trips/today
      //    الرحلة النشطة = العنصر الذي status == 'in_progress'.
      //    عند فشل الطلب، لا نُفشل تحميل الشاشة — نعتبرها بلا رحلة نشطة.
      int? activeTripId;
      try {
        final todayTrips =
            await driverSl<DriverTripsRepository>().getTripsToday();
        final DriverTripModel? activeTrip =
            todayTrips.where((t) => t.isInProgress).cast<DriverTripModel?>().firstWhere(
                  (_) => true,
                  orElse: () => null,
                );
        if (activeTrip != null && activeTrip.tripId > 0) {
          activeTripId = activeTrip.tripId;
        }
      } catch (_) {
        activeTripId = null;
      }

      // 4. قراءة الحالتين المستقلَّتين من التخزين المحلي:
      //    - showFirstWelcome: مرة واحدة فقط لكل سائق.
      //    - isOnline: آخر حالة اتصال محفوظة للسائق.
      final welcomeAlreadyShown =
          StorageService.hasDriverWelcomeBeenShown(driver.driverId);
      final savedOnlineStatus =
          StorageService.getDriverOnlineStatus(driver.driverId);

      emit(
        DriverHomeLoaded(
          driver: driver,
          isOnline: savedOnlineStatus,
          todayTripsCount: 0,
          todayStudentsCount: 0,
          newRequests: newRequests.data,
          hasActiveTrip: activeTripId != null,
          activeTripId: activeTripId,
          showFirstWelcome: !welcomeAlreadyShown,
        ),
      );
    } catch (e) {
      // في حالة وجود خطأ، نحاول استخدام البيانات المحلية المخزنة كـ fallback
      try {
        final profileRepo = driverSl<DriverProfileRepository>();
        final name = profileRepo.getCachedFullName();
        final phone = profileRepo.getCachedPhoneNumber();
        final cachedDriverId = StorageService.getDriverId() ?? 0;

        final cachedDriver = DriverModel(
          driverId: cachedDriverId,
          userId: 0,
          fullName: name.isNotEmpty ? name : 'السائق',
          email: '',
          phoneNumber: phone.isNotEmpty ? phone : '',
          alternativePhone: null,
          avatarUrl: null,
          gender: 'male',
          accountStatus: 'Approved',
        );

        final welcomeAlreadyShown =
            StorageService.hasDriverWelcomeBeenShown(cachedDriverId);
        final savedOnlineStatus =
            StorageService.getDriverOnlineStatus(cachedDriverId);

        emit(
          DriverHomeLoaded(
            driver: cachedDriver,
            isOnline: savedOnlineStatus,
            todayTripsCount: 0,
            todayStudentsCount: 0,
            newRequests: const [],
            hasActiveTrip: false,
            showFirstWelcome: !welcomeAlreadyShown,
          ),
        );
      } catch (_) {
        emit(DriverHomeError('حدث خطأ في تحميل البيانات: ${e.toString()}'));
      }
    }
  }

  /// تبديل حالة الاتصال. حالة تشغيلية دائمة — يتم حفظها محلياً.
  /// لا علاقة لها بـ `showFirstWelcome`.
  Future<void> toggleOnlineStatus() async {
    final currentState = state;
    if (currentState is DriverHomeLoaded) {
      final newStatus = !currentState.isOnline;
      emit(currentState.copyWith(isOnline: newStatus));
      await StorageService.setDriverOnlineStatus(
        currentState.driver.driverId,
        newStatus,
      );
    }
  }

  /// إغلاق رسالة الترحيب الأولى نهائياً لهذا السائق.
  /// لا يؤثر على `isOnline`.
  Future<void> dismissFirstWelcome() async {
    final currentState = state;
    if (currentState is DriverHomeLoaded && currentState.showFirstWelcome) {
      emit(currentState.copyWith(showFirstWelcome: false));
      await StorageService.markDriverWelcomeShown(currentState.driver.driverId);
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

  Future<void> rejectRequest(int requestId, {required String reason}) async {
    try {
      final requestsRepo = driverSl<DriverRequestsRepository>();
      await requestsRepo.rejectRequest(requestId, reason: reason);
      await loadDriverHomeData(); // تحديث الصفحة الرئيسية
    } catch (e) {
      emit(DriverHomeError('فشل رفض الطلب: ${e.toString()}'));
    }
  }
}
