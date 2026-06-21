// Request
class LocationRequest {
  final String label;
  final double lat;
  final double lng;
  final bool isDefault;

  LocationRequest({
    required this.label,
    required this.lat,
    required this.lng,
    required this.isDefault,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'lat': lat,
      'lng': lng,
      'is_default': isDefault ? 1 : 0, // تحويل bool إلى 1 أو 0 حسب ما يفضل الباكيند غالباً
    };
  }
}

// Response
class LocationResponse {
  final bool status;
  final String message;

  LocationResponse({required this.status, required this.message});

  factory LocationResponse.fromJson(Map<String, dynamic> json) {
    return LocationResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}