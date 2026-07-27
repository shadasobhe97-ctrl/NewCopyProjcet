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

  const ChatRoomLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatRoomError extends ChatRoomState {
  final String message;

  const ChatRoomError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatMessageSending extends ChatRoomState {
  final List<ChatMessageModel> messages;

  const ChatMessageSending(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatMessageSent extends ChatRoomState {
  final List<ChatMessageModel> messages;

  const ChatMessageSent(this.messages);

  @override
  List<Object?> get props => [messages];
}
