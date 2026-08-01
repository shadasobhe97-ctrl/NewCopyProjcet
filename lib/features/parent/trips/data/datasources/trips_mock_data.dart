import '../models/active_trip_model.dart';
import '../models/trip_track_model.dart';
import '../models/upcoming_trip_model.dart';
import '../models/trip_history_model.dart';
import '../models/trip_details_model.dart';
import '../models/trip_timeline_model.dart';
import '../models/child_trips_model.dart';

class TripsMockData {
  /// 1. Active Trips Mock
  static List<ActiveTripModel> get activeTrips => const [
        ActiveTripModel(
          tripId: 101,
          tripType: 'morning',
          direction: 'to_school',
          status: 'active',
          startedAt: '07:00 ص',
          driver: DriverInfo(
            id: 1,
            name: 'محمود علي القمودي',
            phone: '0912345678',
            photo: 'https://i.pravatar.cc/150?img=11',
          ),
          vehicle: VehicleInfoModel(
            info: 'حافلة تويوتا هايس 2022 - أصفر',
            plateNumber: 'أ ب ج - 1234',
          ),
          destination: DestinationInfo(
            name: 'مدرسة الفتح النموذجية',
            type: 'school',
            lat: 32.8890,
            lng: 13.1930,
          ),
          children: [
            TripChildInfo(
              childId: 1,
              childName: 'سارة محمود',
              childPhoto: 'https://i.pravatar.cc/150?img=5',
              childStatus: 'in_bus',
              pickupTime: '07:15 ص',
            ),
            TripChildInfo(
              childId: 2,
              childName: 'أحمد محمود',
              childPhoto: 'https://i.pravatar.cc/150?img=12',
              childStatus: 'waiting',
              pickupTime: '07:25 ص',
            ),
          ],
        ),
        ActiveTripModel(
          tripId: 102,
          tripType: 'morning',
          direction: 'to_school',
          status: 'active',
          startedAt: '07:10 ص',
          driver: DriverInfo(
            id: 2,
            name: 'عبد الله الفيتوري',
            phone: '0923456789',
            photo: 'https://i.pravatar.cc/150?img=33',
          ),
          vehicle: VehicleInfoModel(
            info: 'حافلة هيونداي H1 - أبيض',
            plateNumber: 'ط ر ق - 5678',
          ),
          destination: DestinationInfo(
            name: 'مدرسة المعرفة الدولية',
            type: 'school',
            lat: 32.8750,
            lng: 13.1800,
          ),
          children: [
            TripChildInfo(
              childId: 3,
              childName: 'ريم محمد',
              childPhoto: 'https://i.pravatar.cc/150?img=9',
              childStatus: 'arrived',
              pickupTime: '07:05 ص',
              dropoffTime: '07:35 ص',
            ),
          ],
        ),
      ];

  /// 2. Single Trip Tracking Mock
  static LiveTrackingModel getSingleTrack(dynamic tripId) {
    double lat = 32.8872;
    double lng = 13.1913;

    if (tripId == 102) {
      lat = 32.8760;
      lng = 13.1810;
    }

    return LiveTrackingModel(
      tripId: tripId is int ? tripId : int.tryParse(tripId.toString()) ?? 101,
      status: 'active',
      driverLat: lat,
      driverLng: lng,
      lastUpdated: 'الآن',
      isOnline: true,
      destination: const DestinationInfo(
        name: 'مدرسة الفتح النموذجية',
        type: 'school',
        lat: 32.8890,
        lng: 13.1930,
      ),
    );
  }

  /// 3. Multiple Active Tracking Mock
  static List<LiveTrackingModel> get multiTracking => const [
        LiveTrackingModel(
          tripId: 101,
          status: 'active',
          driverLat: 32.8872,
          driverLng: 13.1913,
          lastUpdated: 'منذ 10 ثوانٍ',
          isOnline: true,
          destination: DestinationInfo(
            name: 'مدرسة الفتح النموذجية',
            type: 'school',
            lat: 32.8890,
            lng: 13.1930,
          ),
        ),
        LiveTrackingModel(
          tripId: 102,
          status: 'active',
          driverLat: 32.8760,
          driverLng: 13.1810,
          lastUpdated: 'منذ 5 ثوانٍ',
          isOnline: true,
          destination: DestinationInfo(
            name: 'مدرسة المعرفة الدولية',
            type: 'school',
            lat: 32.8750,
            lng: 13.1800,
          ),
        ),
      ];

  /// 4. Upcoming Trips Mock
  static List<UpcomingTripModel> get upcomingTrips => const [
        UpcomingTripModel(
          tripId: 201,
          tripType: 'evening',
          direction: 'to_home',
          scheduledDate: 'اليوم',
          scheduledTime: '01:30 م',
          driver: DriverInfo(
            id: 1,
            name: 'محمود علي القمودي',
            phone: '0912345678',
            photo: 'https://i.pravatar.cc/150?img=11',
          ),
          vehicle: VehicleInfoModel(
            info: 'حافلة تويوتا هايس 2022',
            plateNumber: 'أ ب ج - 1234',
          ),
          children: [
            TripChildInfo(
              childId: 1,
              childName: 'سارة محمود',
              childPhoto: 'https://i.pravatar.cc/150?img=5',
              childStatus: 'waiting',
            ),
          ],
          destination: DestinationInfo(
            name: 'المنزل - حي الأندلس',
            type: 'home',
            lat: 32.8800,
            lng: 13.1700,
          ),
        ),
        UpcomingTripModel(
          tripId: 202,
          tripType: 'morning',
          direction: 'to_school',
          scheduledDate: 'غداً',
          scheduledTime: '07:00 ص',
          driver: DriverInfo(
            id: 1,
            name: 'محمود علي القمودي',
            phone: '0912345678',
            photo: 'https://i.pravatar.cc/150?img=11',
          ),
          vehicle: VehicleInfoModel(
            info: 'حافلة تويوتا هايس 2022',
            plateNumber: 'أ ب ج - 1234',
          ),
          children: [
            TripChildInfo(
              childId: 1,
              childName: 'سارة محمود',
              childPhoto: 'https://i.pravatar.cc/150?img=5',
              childStatus: 'scheduled',
            ),
            TripChildInfo(
              childId: 2,
              childName: 'أحمد محمود',
              childPhoto: 'https://i.pravatar.cc/150?img=12',
              childStatus: 'scheduled',
            ),
          ],
          destination: DestinationInfo(
            name: 'مدرسة الفتح النموذجية',
            type: 'school',
            lat: 32.8890,
            lng: 13.1930,
          ),
        ),
      ];

  /// 5. History Trips Mock
  static List<TripHistoryModel> getHistory(int page) {
    if (page > 2) return [];
    return [
      const TripHistoryModel(
        tripId: 88,
        tripType: 'morning',
        direction: 'to_school',
        tripDate: '2026-07-30',
        driverName: 'محمود علي القمودي',
        pickupTime: '07:10 ص',
        dropoffTime: '07:40 ص',
        tripCost: '15.00 د.ل',
        status: 'completed',
        children: [
          TripChildInfo(
            childId: 1,
            childName: 'سارة محمود',
            childPhoto: 'https://i.pravatar.cc/150?img=5',
            childStatus: 'arrived',
          ),
        ],
      ),
      const TripHistoryModel(
        tripId: 87,
        tripType: 'evening',
        direction: 'to_home',
        tripDate: '2026-07-29',
        driverName: 'محمود علي القمودي',
        pickupTime: '01:30 م',
        dropoffTime: '02:05 م',
        tripCost: '15.00 د.ل',
        status: 'completed',
        children: [
          TripChildInfo(
            childId: 1,
            childName: 'سارة محمود',
            childPhoto: 'https://i.pravatar.cc/150?img=5',
            childStatus: 'arrived',
          ),
          TripChildInfo(
            childId: 2,
            childName: 'أحمد محمود',
            childPhoto: 'https://i.pravatar.cc/150?img=12',
            childStatus: 'arrived',
          ),
        ],
      ),
      const TripHistoryModel(
        tripId: 86,
        tripType: 'morning',
        direction: 'to_school',
        tripDate: '2026-07-28',
        driverName: 'عبد الله الفيتوري',
        pickupTime: '07:05 ص',
        dropoffTime: '07:35 ص',
        tripCost: '15.00 د.ل',
        status: 'completed',
        children: [
          TripChildInfo(
            childId: 2,
            childName: 'أحمد محمود',
            childPhoto: 'https://i.pravatar.cc/150?img=12',
            childStatus: 'arrived',
          ),
        ],
      ),
    ];
  }

  /// 6. Trip Details Mock
  static TripDetailsModel getTripDetails(dynamic tripId) {
    return const TripDetailsModel(
      tripId: 101,
      tripType: 'morning',
      direction: 'to_school',
      status: 'active',
      startedAt: '07:00 ص',
      totalDistance: '12.4 كم',
      estimatedDuration: '25 دقيقة',
      driver: DriverInfo(
        id: 1,
        name: 'محمود علي القمودي',
        phone: '0912345678',
        photo: 'https://i.pravatar.cc/150?img=11',
      ),
      vehicle: VehicleInfoModel(
        info: 'حافلة تويوتا هايس 2022 - أصفر',
        plateNumber: 'أ ب ج - 1234',
      ),
      destination: DestinationInfo(
        name: 'مدرسة الفتح النموذجية',
        type: 'school',
        lat: 32.8890,
        lng: 13.1930,
      ),
      children: [
        TripChildInfo(
          childId: 1,
          childName: 'سارة محمود',
          childPhoto: 'https://i.pravatar.cc/150?img=5',
          childStatus: 'in_bus',
          pickupTime: '07:15 ص',
        ),
        TripChildInfo(
          childId: 2,
          childName: 'أحمد محمود',
          childPhoto: 'https://i.pravatar.cc/150?img=12',
          childStatus: 'waiting',
          pickupTime: 'في انتظار الصعود',
        ),
      ],
      timeline: [
        TripTimelineItemModel(
          status: 'started',
          title: 'بدأت الرحلة',
          time: '07:05 ص',
          description: 'انطلق السائق محمود في المسار المحجوز',
          isDone: true,
        ),
        TripTimelineItemModel(
          status: 'picked_up',
          title: 'تم صعود الطفل سارة محمود',
          time: '07:15 ص',
          description: 'تم توثيق الصعود عبر رمز QR الخاص بالحافلة',
          isDone: true,
        ),
        TripTimelineItemModel(
          status: 'arrived_school',
          title: 'وصل الطفل سارة محمود للمدرسة',
          time: '07:35 ص',
          description: 'تسليم الطفل بسلامة الله في مدخل المدرسة',
          isDone: true,
          isCurrent: true,
        ),
        TripTimelineItemModel(
          status: 'completed',
          title: 'اكتمال الرحلة بالكامل',
          time: '07:45 ص',
          description: 'تم إنهاء الرحلة وتوثيق وصول جميع الأطفال',
          isDone: false,
        ),
      ],
    );
  }

  /// 7. Trip Timeline Items Mock
  static List<TripTimelineItemModel> getTimeline(dynamic tripId) {
    return getTripDetails(tripId).timeline;
  }

  /// 8. Child Trips Mock
  static ChildTripsModel getChildTrips(dynamic childId) {
    return ChildTripsModel(
      childId: childId is int ? childId : int.tryParse(childId.toString()) ?? 1,
      childName: 'سارة محمود',
      childPhoto: 'https://i.pravatar.cc/150?img=5',
      totalTripsThisMonth: 24,
      attendancePercentage: 98.5,
      currentTrip: activeTrips.first,
      upcomingTrips: upcomingTrips,
      history: getHistory(1),
    );
  }
}
