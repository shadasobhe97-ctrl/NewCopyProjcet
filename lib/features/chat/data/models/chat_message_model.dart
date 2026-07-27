import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderRole; // 'parent' or 'driver'
  final String message;
  final DateTime timestamp;
  final bool isRead;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.message,
    required this.timestamp,
    required this.isRead,
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

    return ChatMessageModel(
      id: doc.id,
      senderId: (data['sender_id'] ?? data['senderId'] ?? '').toString(),
      senderRole: data['sender_role']?.toString() ?? data['senderRole']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      timestamp: timeVal,
      isRead: data['is_read'] as bool? ?? data['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'sender_role': senderRole,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'is_read': isRead,
    };
  }
}
