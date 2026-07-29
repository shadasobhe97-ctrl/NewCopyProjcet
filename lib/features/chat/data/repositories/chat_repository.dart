import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:kids_transport/core/enums/user_role.dart';
import 'package:kids_transport/core/errors/failures.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import '../datasources/chat_api_datasource.dart';
import '../datasources/chat_firebase_datasource.dart';
import '../models/chat_conversation_model.dart';
import '../models/chat_message_model.dart';

class ChatRepository {
  final ChatApiDataSource _apiDataSource;
  final ChatFirebaseDataSource _firebaseDataSource;

  ChatRepository(this._apiDataSource, this._firebaseDataSource);

  /// Fetch conversations from API based on user's UserRole.
  Future<Either<Failure, List<ChatConversationModel>>> getConversations(
    UserRole role,
  ) async {
    try {
      final conversations = await _apiDataSource.getConversations(role);
      return Right(conversations);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Get real-time stream of messages in Firestore for a chat room, filtered by currentUserId.
  Stream<List<ChatMessageModel>> getMessages(
      String chatRoomId, String currentUserId) {
    return _firebaseDataSource.getMessagesStream(chatRoomId, currentUserId);
  }

  /// Get real-time stream of room metadata (typing status, etc.).
  Stream<Map<String, dynamic>?> getRoomStream(String chatRoomId) {
    return _firebaseDataSource.getRoomStream(chatRoomId);
  }

  /// Get real-time stream of deleted room IDs for currentUserId.
  Stream<List<String>> getDeletedRoomIdsStream(String currentUserId) {
    return _firebaseDataSource.getDeletedRoomIdsStream(currentUserId);
  }

  /// Get real-time stream of unread messages count.
  Stream<int> getUnreadCountStream(String chatRoomId, String currentUserId) {
    return _firebaseDataSource.getUnreadCountStream(chatRoomId, currentUserId);
  }

  /// Marks all unread messages sent by the other party as read.
  Future<void> markMessagesAsRead({
    required String chatRoomId,
    required String currentUserId,
  }) async {
    await _firebaseDataSource.markMessagesAsRead(
      chatRoomId: chatRoomId,
      currentUserId: currentUserId,
    );
  }

  /// Soft-deletes a message for everyone (is_deleted_for_everyone: true).
  Future<void> deleteMessageForEveryone({
    required String chatRoomId,
    required String messageId,
  }) async {
    await _firebaseDataSource.deleteMessageForEveryone(
      chatRoomId: chatRoomId,
      messageId: messageId,
    );
  }

  /// Soft-deletes a message for the current user only.
  Future<void> deleteMessageForMe({
    required String chatRoomId,
    required String messageId,
    required String currentUserId,
  }) async {
    await _firebaseDataSource.deleteMessageForMe(
      chatRoomId: chatRoomId,
      messageId: messageId,
      currentUserId: currentUserId,
    );
  }

  /// Soft-deletes a conversation for the current user only.
  Future<void> deleteConversationForMe({
    required String chatRoomId,
    required String currentUserId,
  }) async {
    await _firebaseDataSource.deleteConversationForMe(
      chatRoomId: chatRoomId,
      currentUserId: currentUserId,
    );
  }

  /// Updates typing status (parent_is_typing or driver_is_typing).
  Future<void> updateTypingStatus({
    required String chatRoomId,
    required String userRole,
    required bool isTyping,
  }) async {
    await _firebaseDataSource.updateTypingStatus(
      chatRoomId: chatRoomId,
      userRole: userRole,
      isTyping: isTyping,
    );
  }

  /// Uploads a media file to Firebase Storage.
  Future<Either<Failure, String>> uploadMediaFile({
    required String chatRoomId,
    required File file,
    required String folderName,
  }) async {
    try {
      final url = await _firebaseDataSource.uploadMediaFile(
        chatRoomId: chatRoomId,
        file: file,
        folderName: folderName,
      );
      return Right(url);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }

  /// Sends a message and updates the room status in Firestore.
  Future<Either<Failure, void>> sendMessage({
    required String chatRoomId,
    required ChatMessageModel message,
  }) async {
    try {
      await _firebaseDataSource.sendMessage(
        chatRoomId: chatRoomId,
        message: message,
      );
      return const Right(null);
    } catch (e) {
      return Left(FirebaseFailure(e.toString()));
    }
  }
}
