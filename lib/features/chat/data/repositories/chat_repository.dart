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

  /// Get real-time stream of messages in Firestore for a chat room.
  Stream<List<ChatMessageModel>> getMessages(String chatRoomId) {
    return _firebaseDataSource.getMessagesStream(chatRoomId);
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
