import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_room_state.dart';

class ChatRoomCubit extends Cubit<ChatRoomState> {
  final ChatRepository _repository;
  StreamSubscription<List<ChatMessageModel>>? _messagesSubscription;
  List<ChatMessageModel> _currentMessages = [];

  ChatRoomCubit(this._repository) : super(ChatRoomInitial());

  /// Establishes the real-time messages listener.
  void listenToMessages(String chatRoomId) {
    emit(ChatRoomLoading());
    _messagesSubscription?.cancel();

    _messagesSubscription = _repository.getMessages(chatRoomId).listen(
      (messages) {
        _currentMessages = messages;
        emit(ChatRoomLoaded(messages));
      },
      onError: (error) {
        emit(ChatRoomError(error.toString()));
      },
    );
  }

  /// Sends a message and triggers local UI status changes.
  Future<void> sendMessage({
    required String chatRoomId,
    required String message,
    required String senderId,
    required String senderRole,
  }) async {
    final messageModel = ChatMessageModel(
      id: '',
      senderId: senderId,
      senderRole: senderRole,
      message: message,
      timestamp: DateTime.now(),
      isRead: false,
    );

    emit(ChatMessageSending(_currentMessages));

    final result = await _repository.sendMessage(
      chatRoomId: chatRoomId,
      message: messageModel,
    );

    result.fold(
      (failure) {
        emit(ChatRoomLoaded(_currentMessages));
      },
      (_) {
        emit(ChatMessageSent(_currentMessages));
        emit(ChatRoomLoaded(_currentMessages));
      },
    );
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
