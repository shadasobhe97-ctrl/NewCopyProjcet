class TripTimelineItemModel {
  final String status;
  final String title;
  final String time;
  final String? description;
  final bool isDone;
  final bool isCurrent;

  const TripTimelineItemModel({
    required this.status,
    required this.title,
    required this.time,
    this.description,
    this.isDone = true,
    this.isCurrent = false,
  });

  bool get isCompleted => isDone;
  String get statusKey => status;

  factory TripTimelineItemModel.fromJson(Map<String, dynamic> json) {
    return TripTimelineItemModel(
      status: json['status']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      time: json['time']?.toString() ?? json['timestamp']?.toString() ?? '',
      description: json['description']?.toString(),
      isDone: json['is_done'] as bool? ?? true,
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }
}
