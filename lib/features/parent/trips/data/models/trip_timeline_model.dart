class TripTimelineItemModel {
  final String status;
  final String title;
  final String time;
  final String? description;
  final int? childId;
  final String? childName;
  final bool isDone;
  final bool isCurrent;

  const TripTimelineItemModel({
    required this.status,
    required this.title,
    required this.time,
    this.description,
    this.childId,
    this.childName,
    this.isDone = true,
    this.isCurrent = false,
  });

  bool get isCompleted => isDone;
  String get statusKey => status;

  factory TripTimelineItemModel.fromJson(Map<String, dynamic> json) {
    return TripTimelineItemModel(
      status: json['event']?.toString() ?? json['status']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      time: json['timestamp']?.toString() ?? json['time']?.toString() ?? '',
      description: json['details']?.toString() ?? json['description']?.toString(),
      childId: _parseInt(json['child_id']),
      childName: json['child_name']?.toString(),
      isDone: json['is_done'] as bool? ?? true,
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }

  static int? _parseInt(dynamic val) {
    if (val is int) return val;
    if (val is num) return val.toInt();
    if (val != null) return int.tryParse(val.toString());
    return null;
  }
}
