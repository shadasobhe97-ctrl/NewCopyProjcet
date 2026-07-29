import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_room_state.dart';

class ChatRoomCubit extends Cubit<ChatRoomState> {
  final ChatRepository _repository;
  StreamSubscription<List<ChatMessageModel>>? _messagesSubscription;
  StreamSubscription<Map<String, dynamic>?>? _roomSubscription;
  List<ChatMessageModel> _currentMessages = [];
  bool _isOtherUserTyping = false;

  ChatRoomCubit(this._repository) : super(ChatRoomInitial());

  /// Establishes the real-time messages listener and room typing status listener.
  void listenToRoom({
    required String chatRoomId,
    required String currentUserId,
    required String currentUserRole,
  }) {
    emit(ChatRoomLoading());
    _messagesSubscription?.cancel();
    _roomSubscription?.cancel();

    // 1. Mark existing messages as read upon entering
    _repository.markMessagesAsRead(
      chatRoomId: chatRoomId,
      currentUserId: currentUserId,
    );

    // 2. Listen to messages stream (passing currentUserId to filter soft deleted messages)
    _messagesSubscription =
        _repository.getMessages(chatRoomId, currentUserId).listen(
      (messages) {
        _currentMessages = messages;
        // Automatically mark incoming messages as read
        _repository.markMessagesAsRead(
          chatRoomId: chatRoomId,
          currentUserId: currentUserId,
        );

        emit(ChatRoomLoaded(
          _currentMessages,
          isOtherUserTyping: _isOtherUserTyping,
        ));
      },
      onError: (error) {
        emit(ChatRoomError(error.toString()));
      },
    );

    // 3. Listen to room doc stream for typing status of the other user
    _roomSubscription = _repository.getRoomStream(chatRoomId).listen(
      (roomData) {
        if (roomData != null) {
          final roleLower = currentUserRole.toLowerCase();
          final bool isCurrentParent = (roleLower == 'parent' ||
              roleLower == 'ولي أمر' ||
              roleLower == 'ولي امر');

          // If current user is parent, listen to driver_is_typing; vice versa
          final bool otherTyping = isCurrentParent
              ? (roomData['driver_is_typing'] as bool? ?? false)
              : (roomData['parent_is_typing'] as bool? ?? false);

          if (_isOtherUserTyping != otherTyping) {
            _isOtherUserTyping = otherTyping;
            if (state is ChatRoomLoaded) {
              emit((state as ChatRoomLoaded).copyWith(
                isOtherUserTyping: _isOtherUserTyping,
              ));
            }
          }
        }
      },
    );
  }

  /// Soft-deletes a message for everyone.
  Future<void> deleteMessageForEveryone({
    required String chatRoomId,
    required String messageId,
  }) async {
    await _repository.deleteMessageForEveryone(
      chatRoomId: chatRoomId,
      messageId: messageId,
    );
  }

  /// Soft-deletes a message for current user only.
  Future<void> deleteMessageForMe({
    required String chatRoomId,
    required String messageId,
    required String currentUserId,
  }) async {
    await _repository.deleteMessageForMe(
      chatRoomId: chatRoomId,
      messageId: messageId,
      currentUserId: currentUserId,
    );
  }

  /// Updates typing status for current user in Firestore.
  Future<void> updateTypingStatus({
    required String chatRoomId,
    required String userRole,
    required bool isTyping,
  }) async {
    await _repository.updateTypingStatus(
      chatRoomId: chatRoomId,
      userRole: userRole,
      isTyping: isTyping,
    );
  }

  /// Sends a text message.
  Future<void> sendMessage({
    required String chatRoomId,
    required String message,
    required String senderId,
    required String senderRole,
  }) async {
    // Clear typing status when sending
    updateTypingStatus(
      chatRoomId: chatRoomId,
      userRole: senderRole,
      isTyping: false,
    );

    final messageModel = ChatMessageModel(
      id: '',
      senderId: senderId,
      senderRole: senderRole,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
      type: 'text',
    );

    emit(ChatMessageSending(_currentMessages,
        isOtherUserTyping: _isOtherUserTyping));

    final result = await _repository.sendMessage(
      chatRoomId: chatRoomId,
      message: messageModel,
    );

    result.fold(
      (failure) {
        emit(ChatRoomLoaded(_currentMessages,
            isOtherUserTyping: _isOtherUserTyping));
      },
      (_) {
        emit(ChatMessageSent(_currentMessages,
            isOtherUserTyping: _isOtherUserTyping));
        emit(ChatRoomLoaded(_currentMessages,
            isOtherUserTyping: _isOtherUserTyping));
      },
    );
  }

  /// Uploads media file to Firebase Storage and sends a media message.
  Future<void> sendMediaMessage({
    required String chatRoomId,
    required File file,
    required String type,
    required String senderId,
    required String senderRole,
    int? audioDuration,
    String? caption,
  }) async {
    emit(ChatMessageSending(_currentMessages,
        isOtherUserTyping: _isOtherUserTyping));

    try {
      final String folderName = type == 'image'
          ? 'images'
          : (type == 'video' ? 'videos' : 'audios');

      final uploadResult = await _repository.uploadMediaFile(
        chatRoomId: chatRoomId,
        file: file,
        folderName: folderName,
      );

      await uploadResult.fold(
        (failure) async {
          if (kDebugMode) {
            debugPrint('Failed to upload media file: ${failure.message}');
          }
          emit(ChatRoomLoaded(_currentMessages,
              isOtherUserTyping: _isOtherUserTyping));
        },
        (mediaUrl) async {
          final messageModel = ChatMessageModel(
            id: '',
            senderId: senderId,
            senderRole: senderRole,
            message: caption ?? '',
            timestamp: DateTime.now(),
            isRead: false,
            type: type,
            mediaUrl: mediaUrl,
            audioDuration: audioDuration,
          );

          final result = await _repository.sendMessage(
            chatRoomId: chatRoomId,
            message: messageModel,
          );

          result.fold(
            (failure) => emit(ChatRoomLoaded(_currentMessages,
                isOtherUserTyping: _isOtherUserTyping)),
            (_) {
              emit(ChatMessageSent(_currentMessages,
                  isOtherUserTyping: _isOtherUserTyping));
              emit(ChatRoomLoaded(_currentMessages,
                  isOtherUserTyping: _isOtherUserTyping));
            },
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in sendMediaMessage: $e');
      }
      emit(ChatRoomLoaded(_currentMessages,
          isOtherUserTyping: _isOtherUserTyping));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _roomSubscription?.cancel();
    return super.close();
  }
}
