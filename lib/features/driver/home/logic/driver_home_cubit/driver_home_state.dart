part of 'driver_home_cubit.dart';

// ==========================================
// حالات شاشة الهوم متع السائق
// ==========================================

abstract class DriverHomeState {}

/// الحالة الأولية أو حالة التحميل
class DriverHomeLoading extends DriverHomeState {}

/// الحالة الرئيسية مع بيانات السائق
class DriverHomeLoaded extends DriverHomeState {
  final DriverModel driver;
  final bool isOnline;
  final int todayTripsCount;
  final int todayStudentsCount;
  final List<SubscriptionRequest> newRequests;
  final bool hasActiveTrip; 
  
  DriverHomeLoaded({
    required this.driver,
    required this.isOnline,
    this.todayTripsCount = 0,
    this.todayStudentsCount = 0,
    this.newRequests = const [],
    this.hasActiveTrip = false,
  });

  /// إنشاء نسخة جديدة مع تعديل حالة الاتصال
  DriverHomeLoaded copyWith({
    DriverModel? driver,
    bool? isOnline,
    int? todayTripsCount,
    int? todayStudentsCount,
    List<SubscriptionRequest>? newRequests,
    bool? hasActiveTrip,
  }) {
    return DriverHomeLoaded(
      driver: driver ?? this.driver,
      isOnline: isOnline ?? this.isOnline,
      todayTripsCount: todayTripsCount ?? this.todayTripsCount,
      todayStudentsCount: todayStudentsCount ?? this.todayStudentsCount,
      newRequests: newRequests ?? this.newRequests,
      hasActiveTrip: hasActiveTrip ?? this.hasActiveTrip,
    );
  }
}

/// حالة الخطأ
class DriverHomeError extends DriverHomeState {
  final String message;
  DriverHomeError(this.message);
}
