class DriverInfo {
  final int id;
  final String name;
  final String phone;
  final String? photo;

  const DriverInfo({
    required this.id,
    required this.name,
    required this.phone,
    this.photo,
  });

  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? json['driver_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['driver_phone']?.toString() ?? '',
      photo: json['photo']?.toString() ?? json['driver_photo']?.toString(),
    );
  }
}

class VehicleInfoModel {
  final String info;
  final String? plateNumber;

  const VehicleInfoModel({
    required this.info,
    this.plateNumber,
  });

  factory VehicleInfoModel.fromJson(dynamic json) {
    if (json is String) {
      return VehicleInfoModel(info: json);
    } else if (json is Map<String, dynamic>) {
      return VehicleInfoModel(
        info: json['info']?.toString() ?? json['model']?.toString() ?? 'حافلة مدرسية',
        plateNumber: json['plate_number']?.toString() ?? json['plate']?.toString(),
      );
    }
    return const VehicleInfoModel(info: 'حافلة مدرسية');
  }
}

class TripChildInfo {
  final int childId;
  final String childName;
  final String? childPhoto;
  final String childStatus;

  const TripChildInfo({
    required this.childId,
    required this.childName,
    this.childPhoto,
    required this.childStatus,
  });

  factory TripChildInfo.fromJson(Map<String, dynamic> json) {
    return TripChildInfo(
      childId: json['child_id'] as int? ?? json['id'] as int? ?? 0,
      childName: json['child_name']?.toString() ?? json['name']?.toString() ?? '',
      childPhoto: json['child_photo']?.toString() ?? json['photo']?.toString(),
      childStatus: json['child_status']?.toString() ?? json['status']?.toString() ?? 'waiting',
    );
  }
}

class DestinationInfo {
  final String name;
  final String type;
  final double lat;
  final double lng;

  const DestinationInfo({
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
  });

  factory DestinationInfo.fromJson(Map<String, dynamic> json) {
    return DestinationInfo(
      name: json['name']?.toString() ?? 'الوجهة',
      type: json['type']?.toString() ?? 'school',
      lat: (json['lat'] as num?)?.toDouble() ?? (json['latitude'] as num?)?.toDouble() ?? 32.8872,
      lng: (json['lng'] as num?)?.toDouble() ?? (json['longitude'] as num?)?.toDouble() ?? 13.1913,
    );
  }
}

class ActiveTripModel {
  final int tripId;
  final String tripType;
  final String direction; // to_school or to_home
  final String status;
  final String startedAt;
  final DriverInfo driver;
  final VehicleInfoModel vehicle;
  final List<TripChildInfo> children;
  final DestinationInfo destination;
  final String? waitingTimer;

  const ActiveTripModel({
    required this.tripId,
    required this.tripType,
    required this.direction,
    required this.status,
    required this.startedAt,
    required this.driver,
    required this.vehicle,
    required this.children,
    required this.destination,
    this.waitingTimer,
  });

  // Legacy compatibility getters
  String get driverName => driver.name;
  String get driverPhone => driver.phone;
  String get vehicleInfo => vehicle.info;
  int get childId => children.isNotEmpty ? children.first.childId : 0;
  String get childName => children.isNotEmpty ? children.first.childName : '';
  String get childStatus => children.isNotEmpty ? children.first.childStatus : '';

  factory ActiveTripModel.fromJson(Map<String, dynamic> json) {
    DriverInfo driverObj;
    if (json['driver'] is Map<String, dynamic>) {
      driverObj = DriverInfo.fromJson(json['driver'] as Map<String, dynamic>);
    } else {
      driverObj = DriverInfo(
        id: json['driver_id'] as int? ?? 0,
        name: json['driver_name']?.toString() ?? '',
        phone: json['driver_phone']?.toString() ?? '',
        photo: json['driver_photo']?.toString(),
      );
    }

    VehicleInfoModel vehicleObj = VehicleInfoModel.fromJson(json['vehicle'] ?? json['vehicle_info']);

    List<TripChildInfo> childrenList = [];
    if (json['children'] is List) {
      childrenList = (json['children'] as List)
          .map((e) => TripChildInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (json['child_id'] != null || json['child_name'] != null) {
      childrenList = [
        TripChildInfo(
          childId: json['child_id'] as int? ?? 0,
          childName: json['child_name']?.toString() ?? '',
          childPhoto: json['child_photo']?.toString(),
          childStatus: json['child_status']?.toString() ?? 'waiting',
        )
      ];
    }

    DestinationInfo destObj;
    if (json['destination'] is Map<String, dynamic>) {
      destObj = DestinationInfo.fromJson(json['destination'] as Map<String, dynamic>);
    } else {
      destObj = DestinationInfo(
        name: json['destination_name']?.toString() ?? 'المدرسة',
        type: json['destination_type']?.toString() ?? 'school',
        lat: (json['dest_lat'] as num?)?.toDouble() ?? 32.8872,
        lng: (json['dest_lng'] as num?)?.toDouble() ?? 13.1913,
      );
    }

    return ActiveTripModel(
      tripId: json['trip_id'] as int? ?? json['id'] as int? ?? 0,
      tripType: json['trip_type']?.toString() ?? 'morning',
      direction: json['direction']?.toString() ?? (json['trip_type'] == 'evening' ? 'to_home' : 'to_school'),
      status: json['status']?.toString() ?? 'active',
      startedAt: json['started_at']?.toString() ?? '',
      driver: driverObj,
      vehicle: vehicleObj,
      children: childrenList,
      destination: destObj,
      waitingTimer: json['waiting_timer']?.toString(),
    );
  }
}
