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
  final List<DriverRequestModel> newRequests;
  final List<DriverTripModel> todayTrips;
  final bool hasActiveTrip;
  final int? activeTripId;
  final bool showFirstWelcome;

  DriverHomeLoaded({
    required this.driver,
    required this.isOnline,
    this.todayTripsCount = 0,
    this.todayStudentsCount = 0,
    this.newRequests = const [],
    this.todayTrips = const [],
    this.hasActiveTrip = false,
    this.activeTripId,
    this.showFirstWelcome = false,
  });

  DriverHomeLoaded copyWith({
    DriverModel? driver,
    bool? isOnline,
    int? todayTripsCount,
    int? todayStudentsCount,
    List<DriverRequestModel>? newRequests,
    List<DriverTripModel>? todayTrips,
    bool? hasActiveTrip,
    int? activeTripId,
    bool? showFirstWelcome,
  }) {
    return DriverHomeLoaded(
      driver: driver ?? this.driver,
      isOnline: isOnline ?? this.isOnline,
      todayTripsCount: todayTripsCount ?? this.todayTripsCount,
      todayStudentsCount: todayStudentsCount ?? this.todayStudentsCount,
      newRequests: newRequests ?? this.newRequests,
      todayTrips: todayTrips ?? this.todayTrips,
      hasActiveTrip: hasActiveTrip ?? this.hasActiveTrip,
      activeTripId: activeTripId ?? this.activeTripId,
      showFirstWelcome: showFirstWelcome ?? this.showFirstWelcome,
    );
  }
}

/// حالة الخطأ
class DriverHomeError extends DriverHomeState {
  final String message;
  DriverHomeError(this.message);
}
