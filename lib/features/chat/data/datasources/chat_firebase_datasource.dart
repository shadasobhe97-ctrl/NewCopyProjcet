import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';

class ChatFirebaseDataSource {
  final FirebaseFirestore _firestore;

  ChatFirebaseDataSource(this._firestore);

  /// Streams messages from chat_rooms/{chatRoomId}/messages ordered by timestamp ascending.
  Stream<List<ChatMessageModel>> getMessagesStream(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessageModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Sends a message and updates the room's summary metadata atomically.
  Future<void> sendMessage({
    required String chatRoomId,
    required ChatMessageModel message,
  }) async {
    final batch = _firestore.batch();

    final messageRef = _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(); // Auto-generated message ID

    final roomRef = _firestore.collection('chat_rooms').doc(chatRoomId);

    // Save the message inside messages sub-collection
    batch.set(messageRef, message.toMap());

    // Update the room metadata. Using set with merge to avoid exceptions if the room doc doesn't exist.
    batch.set(
      roomRef,
      {
        'lastMessage': message.message,
        'lastMessageTime': Timestamp.fromDate(message.timestamp),
        'lastSenderId': message.senderId,
        'lastSenderRole': message.senderRole,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}
