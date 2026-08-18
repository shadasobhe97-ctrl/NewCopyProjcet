import 'dart:convert';

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? actionUrl;
  final String? entityType;
  final String? entityId;
  final String? screen;
  final String? action;
  final Map<String, dynamic>? payload;
  final DateTime? readAt;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.actionUrl,
    this.entityType,
    this.entityId,
    this.screen,
    this.action,
    this.payload,
    this.readAt,
    required this.isRead,
    required this.createdAt,
  });

  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    String? actionUrl,
    String? entityType,
    String? entityId,
    String? screen,
    String? action,
    Map<String, dynamic>? payload,
    DateTime? readAt,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      actionUrl: actionUrl ?? this.actionUrl,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      screen: screen ?? this.screen,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedPayload;
    if (json['payload'] != null) {
      if (json['payload'] is Map) {
        parsedPayload = Map<String, dynamic>.from(json['payload'] as Map);
      } else if (json['payload'] is String) {
        try {
          parsedPayload = jsonDecode(json['payload'] as String) as Map<String, dynamic>?;
        } catch (_) {
          // Ignore parse errors
        }
      }
    }

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? json['body']?.toString() ?? '',
      actionUrl: json['action_url']?.toString(),
      entityType: json['entity_type']?.toString(),
      entityId: json['entity_id']?.toString(),
      screen: json['screen']?.toString(),
      action: json['action']?.toString(),
      payload: parsedPayload,
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'].toString()) : null,
      isRead: json['is_read'] == true || json['read_at'] != null,
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'action_url': actionUrl,
      'entity_type': entityType,
      'entity_id': entityId,
      'screen': screen,
      'action': action,
      'payload': payload,
      'read_at': readAt?.toIso8601String(),
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
