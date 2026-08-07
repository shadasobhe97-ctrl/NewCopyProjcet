import 'package:equatable/equatable.dart';

class AcceptRequestResponseModel extends Equatable {
  final bool success;
  final String message;
  final AcceptanceDataModel data;

  const AcceptRequestResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AcceptRequestResponseModel.fromJson(Map<String, dynamic> json) {
    return AcceptRequestResponseModel(
      success: json['success'] is bool
          ? json['success']
          : (json['success']?.toString() == 'true'),
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map
          ? AcceptanceDataModel.fromJson(
              Map<String, dynamic>.from(json['data'] as Map))
          : AcceptanceDataModel.empty(),
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}

class AcceptanceDataModel extends Equatable {
  final int id;
  final String status;
  final String startDate;
  final int workingDaysCount;
  final double totalAmount;
  final int childrenCount;
  final AcceptancePersonModel parent;
  final AcceptancePersonModel driver;
  final List<AcceptedChildModel> children;
  final String createdAt;

  const AcceptanceDataModel({
    required this.id,
    required this.status,
    required this.startDate,
    required this.workingDaysCount,
    required this.totalAmount,
    required this.childrenCount,
    required this.parent,
    required this.driver,
    required this.children,
    required this.createdAt,
  });

  factory AcceptanceDataModel.fromJson(Map<String, dynamic> json) {
    List<AcceptedChildModel> parsedChildren = [];
    if (json['children'] is List) {
      parsedChildren = (json['children'] as List)
          .whereType<Map>()
          .map((e) => AcceptedChildModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return AcceptanceDataModel(
      id: _parseInt(json['id']),
      status: json['status']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      workingDaysCount: _parseInt(json['working_days_count']),
      totalAmount: _parseDouble(json['total_amount']),
      childrenCount: _parseInt(json['children_count']),
      parent: json['parent'] is Map
          ? AcceptancePersonModel.fromJson(
              Map<String, dynamic>.from(json['parent'] as Map))
          : AcceptancePersonModel.empty(),
      driver: json['driver'] is Map
          ? AcceptancePersonModel.fromJson(
              Map<String, dynamic>.from(json['driver'] as Map))
          : AcceptancePersonModel.empty(),
      children: parsedChildren,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  factory AcceptanceDataModel.empty() => AcceptanceDataModel(
        id: 0,
        status: '',
        startDate: '',
        workingDaysCount: 0,
        totalAmount: 0.0,
        childrenCount: 0,
        parent: AcceptancePersonModel.empty(),
        driver: AcceptancePersonModel.empty(),
        children: const [],
        createdAt: '',
      );

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic val) {
    if (val is double) return val;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  @override
  List<Object?> get props => [
        id,
        status,
        startDate,
        workingDaysCount,
        totalAmount,
        childrenCount,
        parent,
        driver,
        children,
        createdAt,
      ];
}

class AcceptancePersonModel extends Equatable {
  final int id;
  final String name;
  final String phone;

  const AcceptancePersonModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory AcceptancePersonModel.fromJson(Map<String, dynamic> json) {
    return AcceptancePersonModel(
      id: AcceptanceDataModel._parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }

  factory AcceptancePersonModel.empty() =>
      const AcceptancePersonModel(id: 0, name: '', phone: '');

  @override
  List<Object?> get props => [id, name, phone];
}

class AcceptedChildModel extends Equatable {
  final int id;
  final String name;
  final double price;
  final String gender;
  final int age;
  final String photoUrl;
  final AcceptedChildSubscriptionModel subscription;
  final AcceptedChildSchoolModel school;
  final AcceptedChildHomeModel home;
  final String pickupTime;
  final String dropoffTime;

  const AcceptedChildModel({
    required this.id,
    required this.name,
    required this.price,
    required this.gender,
    required this.age,
    required this.photoUrl,
    required this.subscription,
    required this.school,
    required this.home,
    required this.pickupTime,
    required this.dropoffTime,
  });

  factory AcceptedChildModel.fromJson(Map<String, dynamic> json) {
    return AcceptedChildModel(
      id: AcceptanceDataModel._parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      price: AcceptanceDataModel._parseDouble(json['price']),
      gender: json['gender']?.toString() ?? '',
      age: AcceptanceDataModel._parseInt(json['age']),
      photoUrl: json['photo_url']?.toString() ?? '',
      subscription: json['subscription'] is Map
          ? AcceptedChildSubscriptionModel.fromJson(
              Map<String, dynamic>.from(json['subscription'] as Map))
          : AcceptedChildSubscriptionModel.empty(),
      school: json['school'] is Map
          ? AcceptedChildSchoolModel.fromJson(
              Map<String, dynamic>.from(json['school'] as Map))
          : AcceptedChildSchoolModel.empty(),
      home: json['home'] is Map
          ? AcceptedChildHomeModel.fromJson(
              Map<String, dynamic>.from(json['home'] as Map))
          : AcceptedChildHomeModel.empty(),
      pickupTime: json['pickup_time']?.toString() ?? '',
      dropoffTime: json['dropoff_time']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        gender,
        age,
        photoUrl,
        subscription,
        school,
        home,
        pickupTime,
        dropoffTime,
      ];
}

class AcceptedChildSubscriptionModel extends Equatable {
  final int id;
  final String type;
  final String tripType;
  final String startDate;
  final String endDate;
  final int workingDaysCount;

  const AcceptedChildSubscriptionModel({
    required this.id,
    required this.type,
    required this.tripType,
    required this.startDate,
    required this.endDate,
    required this.workingDaysCount,
  });

  factory AcceptedChildSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return AcceptedChildSubscriptionModel(
      id: AcceptanceDataModel._parseInt(json['id']),
      type: json['type']?.toString() ?? '',
      tripType: json['trip_type']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      workingDaysCount:
          AcceptanceDataModel._parseInt(json['working_days_count']),
    );
  }

  factory AcceptedChildSubscriptionModel.empty() =>
      const AcceptedChildSubscriptionModel(
        id: 0,
        type: '',
        tripType: '',
        startDate: '',
        endDate: '',
        workingDaysCount: 0,
      );

  @override
  List<Object?> get props =>
      [id, type, tripType, startDate, endDate, workingDaysCount];
}

class AcceptedChildSchoolModel extends Equatable {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const AcceptedChildSchoolModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory AcceptedChildSchoolModel.fromJson(Map<String, dynamic> json) {
    return AcceptedChildSchoolModel(
      id: AcceptanceDataModel._parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: AcceptanceDataModel._parseDouble(json['latitude']),
      longitude: AcceptanceDataModel._parseDouble(json['longitude']),
    );
  }

  factory AcceptedChildSchoolModel.empty() => const AcceptedChildSchoolModel(
        id: 0,
        name: '',
        address: '',
        latitude: 0.0,
        longitude: 0.0,
      );

  @override
  List<Object?> get props => [id, name, address, latitude, longitude];
}

class AcceptedChildHomeModel extends Equatable {
  final String address;
  final double latitude;
  final double longitude;
  final String notes;

  const AcceptedChildHomeModel({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.notes,
  });

  factory AcceptedChildHomeModel.fromJson(Map<String, dynamic> json) {
    return AcceptedChildHomeModel(
      address: json['address']?.toString() ?? '',
      latitude: AcceptanceDataModel._parseDouble(json['latitude']),
      longitude: AcceptanceDataModel._parseDouble(json['longitude']),
      notes: json['notes']?.toString() ?? '',
    );
  }

  factory AcceptedChildHomeModel.empty() => const AcceptedChildHomeModel(
        address: '',
        latitude: 0.0,
        longitude: 0.0,
        notes: '',
      );

  @override
  List<Object?> get props => [address, latitude, longitude, notes];
}
