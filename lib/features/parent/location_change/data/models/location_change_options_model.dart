class SavedAddressModel {
  final int id;
  final int? userId;
  final String label;
  final double lat;
  final double lng;

  SavedAddressModel({
    required this.id,
    this.userId,
    required this.label,
    required this.lat,
    required this.lng,
  });

  factory SavedAddressModel.fromJson(Map<String, dynamic> json) {
    return SavedAddressModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: json['user_id'] != null
          ? int.tryParse(json['user_id'].toString())
          : null,
      label: json['label']?.toString() ?? json['address_name']?.toString() ?? 'عنوان',
      lat: double.tryParse(json['lat']?.toString() ?? '') ?? 0.0,
      lng: double.tryParse(json['lng']?.toString() ?? '') ?? 0.0,
    );
  }
}

class LocationPointModel {
  final double lat;
  final double lng;
  final String label;

  LocationPointModel({
    required this.lat,
    required this.lng,
    required this.label,
  });

  factory LocationPointModel.fromJson(Map<String, dynamic> json) {
    return LocationPointModel(
      lat: double.tryParse(json['lat']?.toString() ?? '') ?? 0.0,
      lng: double.tryParse(json['lng']?.toString() ?? '') ?? 0.0,
      label: json['label']?.toString() ?? '',
    );
  }
}

class ChildOptionModel {
  final int id;
  final String name;
  final String? photoUrl;
  final String? schoolName;
  final SavedAddressModel? defaultHomeAddress;

  ChildOptionModel({
    required this.id,
    required this.name,
    this.photoUrl,
    this.schoolName,
    this.defaultHomeAddress,
  });

  factory ChildOptionModel.fromJson(Map<String, dynamic> json) {
    final schoolObj = json['school'] is Map ? json['school'] as Map<String, dynamic> : {};
    final defaultAddressObj = json['default_home_address'] is Map
        ? json['default_home_address'] as Map<String, dynamic>
        : null;

    return ChildOptionModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? json['full_name']?.toString() ?? 'طفل',
      photoUrl: json['photo_url']?.toString() ?? json['avatar']?.toString() ?? json['photo']?.toString(),
      schoolName: schoolObj['name']?.toString() ?? json['school_name']?.toString(),
      defaultHomeAddress: defaultAddressObj != null
          ? SavedAddressModel.fromJson(defaultAddressObj)
          : null,
    );
  }
}

class ActiveSubscriptionItemModel {
  final int activeSubscriptionId;
  final int childId;
  final String childName;
  final String? childPhotoUrl;
  final int driverId;
  final String driverName;
  final String? tripTiming;
  final String? tripDirection;
  final LocationPointModel? currentPickup;
  final LocationPointModel? currentDropoff;

  ActiveSubscriptionItemModel({
    required this.activeSubscriptionId,
    required this.childId,
    required this.childName,
    this.childPhotoUrl,
    required this.driverId,
    required this.driverName,
    this.tripTiming,
    this.tripDirection,
    this.currentPickup,
    this.currentDropoff,
  });

  factory ActiveSubscriptionItemModel.fromJson(Map<String, dynamic> json) {
    final childObj = json['child'] is Map ? json['child'] as Map<String, dynamic> : {};
    final driverObj = json['driver'] is Map ? json['driver'] as Map<String, dynamic> : {};
    final tripObj = json['trip'] is Map ? json['trip'] as Map<String, dynamic> : {};

    return ActiveSubscriptionItemModel(
      activeSubscriptionId: int.tryParse(json['active_subscription_id']?.toString() ?? '') ?? 0,
      childId: int.tryParse(childObj['id']?.toString() ?? '') ?? 0,
      childName: childObj['name']?.toString() ?? 'طفل',
      childPhotoUrl: childObj['photo_url']?.toString() ?? childObj['avatar']?.toString(),
      driverId: int.tryParse(driverObj['id']?.toString() ?? '') ?? 0,
      driverName: driverObj['name']?.toString() ?? 'سائق',
      tripTiming: tripObj['timing']?.toString(),
      tripDirection: tripObj['direction']?.toString(),
      currentPickup: json['current_pickup'] is Map
          ? LocationPointModel.fromJson(Map<String, dynamic>.from(json['current_pickup']))
          : null,
      currentDropoff: json['current_dropoff'] is Map
          ? LocationPointModel.fromJson(Map<String, dynamic>.from(json['current_dropoff']))
          : null,
    );
  }
}

class LocationChangeOptionsModel {
  final List<ChildOptionModel> children;
  final List<SavedAddressModel> addresses;
  final List<ActiveSubscriptionItemModel> activeSubscriptions;

  LocationChangeOptionsModel({
    required this.children,
    required this.addresses,
    required this.activeSubscriptions,
  });

  factory LocationChangeOptionsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;

    final childrenList = (data['children'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => ChildOptionModel.fromJson(e))
        .toList();

    final addressListRaw = (data['saved_addresses'] as List? ?? data['addresses'] as List? ?? []);
    final addressList = addressListRaw
        .whereType<Map<String, dynamic>>()
        .map((e) => SavedAddressModel.fromJson(e))
        .toList();

    final subList = (data['active_subscriptions'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((e) => ActiveSubscriptionItemModel.fromJson(e))
        .toList();

    return LocationChangeOptionsModel(
      children: childrenList,
      addresses: addressList,
      activeSubscriptions: subList,
    );
  }
}
