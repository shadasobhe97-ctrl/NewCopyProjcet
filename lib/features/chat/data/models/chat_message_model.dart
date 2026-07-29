import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderRole; // 'parent' or 'driver'
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'text', 'image', 'video', 'audio'
  final String? mediaUrl;
  final int? audioDuration;
  final bool isDeletedForEveryone;
  final List<String> deletedForUsers;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.type = 'text',
    this.mediaUrl,
    this.audioDuration,
    this.isDeletedForEveryone = false,
    this.deletedForUsers = const [],
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Safely parse Firestore Timestamp, String ISO, or epoch Milliseconds
    final rawTimestamp = data['timestamp'];
    DateTime timeVal;
    if (rawTimestamp is Timestamp) {
      timeVal = rawTimestamp.toDate();
    } else if (rawTimestamp is String) {
      timeVal = DateTime.tryParse(rawTimestamp) ?? DateTime.now();
    } else if (rawTimestamp is int) {
      timeVal = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
    } else {
      timeVal = DateTime.now();
    }

    final rawAudioDuration = data['audio_duration'] ?? data['audioDuration'];
    final rawDeletedUsers =
        data['deleted_for_users'] ?? data['deletedForUsers'];
    final List<String> deletedUsersList = rawDeletedUsers is List
        ? rawDeletedUsers.map((e) => e.toString()).toList()
        : [];

    return ChatMessageModel(
      id: doc.id,
      senderId: (data['sender_id'] ?? data['senderId'] ?? '').toString(),
      senderRole:
          data['sender_role']?.toString() ?? data['senderRole']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      timestamp: timeVal,
      isRead: data['is_read'] as bool? ?? data['isRead'] as bool? ?? false,
      type: data['type']?.toString() ?? 'text',
      mediaUrl: data['media_url']?.toString() ?? data['mediaUrl']?.toString(),
      audioDuration: rawAudioDuration is num ? rawAudioDuration.toInt() : null,
      isDeletedForEveryone: data['is_deleted_for_everyone'] as bool? ??
          data['isDeletedForEveryone'] as bool? ??
          false,
      deletedForUsers: deletedUsersList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'sender_role': senderRole,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'is_read': isRead,
      'type': type,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (audioDuration != null) 'audio_duration': audioDuration,
      'is_deleted_for_everyone': isDeletedForEveryone,
      'deleted_for_users': deletedForUsers,
    };
  }
}
