import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/enums/user_role.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_list_state.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final ChatRepository _repository;

  ChatListCubit(this._repository) : super(ChatListInitial());

  /// Fetches conversations for the specified user role.
  Future<void> getConversations(UserRole role) async {
    debugPrint('\n🔄 [ChatListCubit] getConversations triggered for role: $role');
    emit(ChatListLoading());
    final result = await _repository.getConversations(role);
    result.fold(
      (failure) {
        debugPrint('❌ [ChatListCubit] Error fetching conversations: ${failure.message}');
        emit(ChatListError(failure.message));
      },
      (conversations) {
        debugPrint('✅ [ChatListCubit] Successfully loaded ${conversations.length} conversations.');
        emit(ChatListLoaded(conversations));
      },
    );
  }
}

