import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/driver_model.dart';

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

      final mockDriver = DriverModel(
        id: 1,
        fullName: 'محمد العربي', // TODO: اسم السائق الحقيقي من الـ API
        phone: '+218 91 234 5678', // TODO: رقم الهاتف الحقيقي
        avatarUrl: null, // TODO: رابط الصورة الحقيقية
        status: 'offline',
        vehicle: const VehicleInfo(
          brand: 'Toyota',
          model: 'Hiace',
          plateNumber: '12345-ط',
          color: 'أبيض',
          type: 'Van',
          year: 2022,
          capacity: 14,
          hasAc: true,
          approvalStatus: 'approved',
        ),
      );

      // طلبات اشتراك تجريبية - فارغة للمستخدم الجديد
      // TODO: جلب الطلبات الحقيقية من الـ API
      const mockRequests = <SubscriptionRequest>[];

      emit(DriverHomeLoaded(
        driver: mockDriver,
        isOnline: false,
        todayTripsCount: 0, // TODO: جلب عدد الرحلات الحقيقي
        todayStudentsCount: 0, // TODO: جلب عدد الطلاب الحقيقي
        newRequests: mockRequests,
        hasActiveTrip: false, // TODO: التحقق من وجود رحلة نشطة
      ));
    } catch (e) {
      emit(DriverHomeError('حدث خطأ في تحميل البيانات: ${e.toString()}'));
    }
  }

  /// تبديل حالة الاتصال (متصل/غير متصل)
  /// TODO: ربط بـ API endpoint لتحديث حالة السائق في السيرفر
  Future<void> toggleOnlineStatus() async {
    final currentState = state;
    if (currentState is DriverHomeLoaded) {
      final newStatus = !currentState.isOnline;

      // TODO: إرسال طلب تحديث الحالة للـ API
      // مثال: await _driverRepository.updateDriverStatus(newStatus ? 'online' : 'offline');

      emit(currentState.copyWith(isOnline: newStatus));
    }
  }

  /// قبول طلب اشتراك طالب
  /// TODO: ربط بـ API endpoint لقبول الطلب
  Future<void> acceptRequest(int requestId) async {
    final currentState = state;
    if (currentState is DriverHomeLoaded) {
      // TODO: إرسال طلب قبول للـ API
      // مثال: await _driverRepository.acceptSubscriptionRequest(requestId);

      final updatedRequests = currentState.newRequests
          .where((r) => r.id != requestId)
          .toList();
      emit(currentState.copyWith(newRequests: updatedRequests));
    }
  }

  /// رفض طلب اشتراك طالب
  /// TODO: ربط بـ API endpoint لرفض الطلب
  Future<void> rejectRequest(int requestId) async {
    final currentState = state;
    if (currentState is DriverHomeLoaded) {
      // TODO: إرسال طلب رفض للـ API
      // مثال: await _driverRepository.rejectSubscriptionRequest(requestId);

      final updatedRequests = currentState.newRequests
          .where((r) => r.id != requestId)
          .toList();
      emit(currentState.copyWith(newRequests: updatedRequests));
    }
  }
}
