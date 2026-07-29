import 'package:equatable/equatable.dart';
import '../../data/models/chat_message_model.dart';

abstract class ChatRoomState extends Equatable {
  const ChatRoomState();

  @override
  List<Object?> get props => [];
}

class ChatRoomInitial extends ChatRoomState {}

class ChatRoomLoading extends ChatRoomState {}

class ChatRoomLoaded extends ChatRoomState {
  final List<ChatMessageModel> messages;
  final bool isOtherUserTyping;

  const ChatRoomLoaded(
    this.messages, {
    this.isOtherUserTyping = false,
  });

  ChatRoomLoaded copyWith({
    List<ChatMessageModel>? messages,
    bool? isOtherUserTyping,
  }) {
    return ChatRoomLoaded(
      messages ?? this.messages,
      isOtherUserTyping: isOtherUserTyping ?? this.isOtherUserTyping,
    );
  }

  @override
  List<Object?> get props => [messages, isOtherUserTyping];
}

class ChatRoomError extends ChatRoomState {
  final String message;

  const ChatRoomError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatMessageSending extends ChatRoomState {
  final List<ChatMessageModel> messages;
  final bool isOtherUserTyping;

  const ChatMessageSending(
    this.messages, {
    this.isOtherUserTyping = false,
  });

  @override
  List<Object?> get props => [messages, isOtherUserTyping];
}

class ChatMessageSent extends ChatRoomState {
  final List<ChatMessageModel> messages;
  final bool isOtherUserTyping;

  const ChatMessageSent(
    this.messages, {
    this.isOtherUserTyping = false,
  });

  @override
  List<Object?> get props => [messages, isOtherUserTyping];
}
