class ComplaintModel {
  final int id;
  final int driverId;
  final String? driverName;
  final String? driverAvatar;
  final int tripId;
  final String? tripTitle;
  final String description;
  final String createdAt;
  final String status;
  final String? adminDecision;
  final String? actionDetails;
  final String? updatedAt;

  ComplaintModel({
    required this.id,
    required this.driverId,
    this.driverName,
    this.driverAvatar,
    required this.tripId,
    this.tripTitle,
    required this.description,
    required this.createdAt,
    required this.status,
    this.adminDecision,
    this.actionDetails,
    this.updatedAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isResolved => status.toLowerCase() == 'action_taken' || status.toLowerCase() == 'resolved' || status.toLowerCase() == 'closed';

  String get statusAr {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'action_taken':
      case 'resolved':
        return 'تم المعالجة';
      case 'rejected':
        return 'مرفوضة';
      case 'closed':
        return 'مغلقة';
      default:
        return status;
    }
  }

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? 0;
    final idVal = rawId is num ? rawId.toInt() : int.tryParse(rawId.toString()) ?? 0;

    final rawDriverId = json['driver_id'] ?? (json['driver'] is Map ? json['driver']['id'] : 0);
    final driverIdVal = rawDriverId is num ? rawDriverId.toInt() : int.tryParse(rawDriverId.toString()) ?? 0;

    final rawTripId = json['trip_id'] ?? (json['trip'] is Map ? json['trip']['id'] : 0);
    final tripIdVal = rawTripId is num ? rawTripId.toInt() : int.tryParse(rawTripId.toString()) ?? 0;

    String? dName;
    String? dAvatar;
    if (json['driver'] is Map) {
      final driverMap = Map<String, dynamic>.from(json['driver'] as Map);
      dName = driverMap['full_name'] ?? driverMap['name'];
      dAvatar = driverMap['avatar_url'] ?? driverMap['photo_url'];
    } else {
      dName = json['driver_name']?.toString();
      dAvatar = json['driver_avatar']?.toString();
    }

    String? tTitle;
    if (json['trip'] is Map) {
      final tripMap = Map<String, dynamic>.from(json['trip'] as Map);
      tTitle = tripMap['title'] ?? tripMap['name'] ?? 'رحلة #${tripMap['id']}';
    } else {
      tTitle = json['trip_title']?.toString() ?? (tripIdVal > 0 ? 'رحلة #$tripIdVal' : null);
    }

    return ComplaintModel(
      id: idVal,
      driverId: driverIdVal,
      driverName: dName,
      driverAvatar: dAvatar,
      tripId: tripIdVal,
      tripTitle: tTitle,
      description: (json['description'] ?? json['comment'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      adminDecision: json['admin_decision']?.toString() ?? json['decision']?.toString() ?? json['admin_response']?.toString(),
      actionDetails: json['action_details']?.toString() ?? json['action_taken']?.toString() ?? json['resolution']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'trip_id': tripId,
      'description': description,
    };
  }
}
