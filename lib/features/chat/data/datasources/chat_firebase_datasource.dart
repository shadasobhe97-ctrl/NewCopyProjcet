import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/chat_message_model.dart';

class ChatFirebaseDataSource {
  final FirebaseFirestore _firestore;

  ChatFirebaseDataSource(this._firestore);

  /// Streams messages from chat_rooms/{chatRoomId}/messages ordered by timestamp ascending,
  /// filtering out messages soft-deleted by currentUserId.
  Stream<List<ChatMessageModel>> getMessagesStream(
      String chatRoomId, String currentUserId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessageModel.fromFirestore(doc))
          .where((msg) => !msg.deletedForUsers.contains(currentUserId))
          .toList();
    });
  }

  /// Streams room metadata from chat_rooms/{chatRoomId} for typing status and room state.
  Stream<Map<String, dynamic>?> getRoomStream(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .snapshots()
        .map((doc) => doc.data());
  }

  /// Streams room IDs that have been soft-deleted by currentUserId.
  Stream<List<String>> getDeletedRoomIdsStream(String currentUserId) {
    return _firestore
        .collection('chat_rooms')
        .where('deleted_for_users', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  /// Streams unread messages count for a room directed to currentUserId.
  Stream<int> getUnreadCountStream(String chatRoomId, String currentUserId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .where('is_read', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) {
        final data = doc.data();
        final senderId = (data['sender_id'] ?? data['senderId'] ?? '').toString();
        final rawDeletedUsers =
            data['deleted_for_users'] ?? data['deletedForUsers'];
        final List<String> deletedList = rawDeletedUsers is List
            ? rawDeletedUsers.map((e) => e.toString()).toList()
            : [];
        return senderId != currentUserId && !deletedList.contains(currentUserId);
      }).length;
    });
  }

  /// Marks all unread messages sent by the other party as read.
  Future<void> markMessagesAsRead({
    required String chatRoomId,
    required String currentUserId,
  }) async {
    try {
      final unreadDocs = await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('is_read', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      bool hasUpdates = false;

      for (final doc in unreadDocs.docs) {
        final data = doc.data();
        final senderId =
            (data['sender_id'] ?? data['senderId'] ?? '').toString();

        if (senderId.isNotEmpty && senderId != currentUserId) {
          batch.update(doc.reference, {'is_read': true});
          hasUpdates = true;
        }
      }

      if (hasUpdates) {
        await batch.commit();
        if (kDebugMode) {
          debugPrint('✅ Marked unread messages as read for room: $chatRoomId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error marking messages as read: $e');
      }
    }
  }

  /// Soft-deletes a message for everyone (sets is_deleted_for_everyone = true).
  Future<void> deleteMessageForEveryone({
    required String chatRoomId,
    required String messageId,
  }) async {
    try {
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({'is_deleted_for_everyone': true});
      if (kDebugMode) {
        debugPrint('✅ Soft-deleted message for everyone: $messageId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting message for everyone: $e');
      }
    }
  }

  /// Soft-deletes a message for the current user only (adds currentUserId to deleted_for_users array).
  Future<void> deleteMessageForMe({
    required String chatRoomId,
    required String messageId,
    required String currentUserId,
  }) async {
    try {
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'deleted_for_users': FieldValue.arrayUnion([currentUserId])
      });
      if (kDebugMode) {
        debugPrint('✅ Soft-deleted message for me ($currentUserId): $messageId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting message for me: $e');
      }
    }
  }

  /// Soft-deletes a conversation for the current user only (adds currentUserId to deleted_for_users array on room doc).
  Future<void> deleteConversationForMe({
    required String chatRoomId,
    required String currentUserId,
  }) async {
    try {
      await _firestore.collection('chat_rooms').doc(chatRoomId).set(
        {
          'deleted_for_users': FieldValue.arrayUnion([currentUserId])
        },
        SetOptions(merge: true),
      );
      if (kDebugMode) {
        debugPrint(
            '✅ Soft-deleted conversation for me ($currentUserId): $chatRoomId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error deleting conversation for me: $e');
      }
    }
  }

  /// Updates typing status (parent_is_typing or driver_is_typing) in chat_rooms/{chatRoomId}.
  Future<void> updateTypingStatus({
    required String chatRoomId,
    required String userRole,
    required bool isTyping,
  }) async {
    try {
      final roleLower = userRole.toLowerCase();
      final String typingField = (roleLower == 'parent' ||
              roleLower == 'ولي أمر' ||
              roleLower == 'ولي امر')
          ? 'parent_is_typing'
          : 'driver_is_typing';

      await _firestore.collection('chat_rooms').doc(chatRoomId).set(
        {typingField: isTyping},
        SetOptions(merge: true),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error updating typing status: $e');
      }
    }
  }

  /// Uploads a media file (Image/Video/Audio) to Firebase Storage in chat_media/{chatRoomId}/{folderName}/...
  Future<String> uploadMediaFile({
    required String chatRoomId,
    required File file,
    required String folderName,
  }) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last.split('\\').last}';
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('chat_media/$chatRoomId/$folderName/$fileName');

      final UploadTask uploadTask = storageRef.putFile(file);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      if (kDebugMode) {
        debugPrint('✅ Uploaded media file to Firebase Storage: $downloadUrl');
      }
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error uploading media file to Firebase Storage: $e');
      }
      rethrow;
    }
  }

  /// Sends a message and updates room summary, automatically clearing deleted_for_users array so conversation reappears for both parties.
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

    // Format room lastMessage preview text based on message type
    String lastMsgPreview = message.message;
    if (message.type == 'image') {
      lastMsgPreview = message.message.isNotEmpty
          ? '📷 ${message.message}'
          : '📷 صورة مرفقة';
    } else if (message.type == 'video') {
      lastMsgPreview = message.message.isNotEmpty
          ? '🎥 ${message.message}'
          : '🎥 فيديو مرفق';
    } else if (message.type == 'audio') {
      lastMsgPreview = '🎤 رسالة صوتية';
    }

    // Update room metadata and RESET deleted_for_users so room is restored automatically
    batch.set(
      roomRef,
      {
        'chat_room_id': chatRoomId,
        'type': 'chat_message',
        'lastMessage': lastMsgPreview,
        'lastMessageTime': Timestamp.fromDate(message.timestamp),
        'lastSenderId': message.senderId,
        'lastSenderRole': message.senderRole,
        'deleted_for_users': [], // Reset so conversation reappears for everyone
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}
