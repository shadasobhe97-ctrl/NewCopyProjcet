import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:kids_transport/core/enums/user_role.dart';
import 'package:kids_transport/core/network/api_client.dart';
import 'package:kids_transport/core/services/storage_service.dart';
import '../models/chat_conversation_model.dart';

class ChatApiDataSource {
  final ApiClient _client;

  ChatApiDataSource(this._client);

  Map<String, dynamic> get _authHeader {
    final token = StorageService.getAuthorizationHeader();
    return {'Authorization': token ?? ''};
  }

  /// GET /api/parent/chats or /api/driver/chats depending on the user role.
  Future<List<ChatConversationModel>> getConversations(UserRole role) async {
    final String path = switch (role) {
      UserRole.parent => 'parent/chats',
      UserRole.driver => 'driver/chats',
      _ => throw ArgumentError('غير مصرح لهذا الدور بالوصول للمحادثات.'),
    };

    debugPrint('\n================ [API CHAT] getConversations ================');
    debugPrint('📌 Role: $role | GET Endpoint: $path');
    debugPrint('🔑 Token: ${_authHeader['Authorization']}');

    try {
      final response = await _client.get(
        path,
        headers: _authHeader,
      );

      debugPrint('✅ Chat List Status Code: ${response.statusCode}');
      debugPrint('📄 Raw Response Payload:');
      debugPrint(response.data.toString());

      final data = response.data;
      List<ChatConversationModel> conversationsList = [];

      if (data is Map) {
        final rawList = data['data'] as List<dynamic>? ?? data['conversations'] as List<dynamic>? ?? [];
        debugPrint('📊 Extracted Array Count: ${rawList.length}');
        conversationsList = rawList.map((e) => ChatConversationModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      } else if (data is List) {
        debugPrint('📊 Raw List Count: ${data.length}');
        conversationsList = data.map((e) => ChatConversationModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      } else {
        debugPrint('⚠️ Warning: Data response is neither Map nor List (${data.runtimeType})');
      }

      debugPrint('✨ Parsed Chat Conversations Count: ${conversationsList.length}');
      for (int i = 0; i < conversationsList.length; i++) {
        final conv = conversationsList[i];
        debugPrint('   [$i] room: "${conv.chatRoomId}" | name: "${conv.otherUserName}" | phone: "${conv.otherUserPhone}" | canChat: ${conv.canChat} | subStatus: "${conv.subscriptionStatus}"');
      }
      debugPrint('=============================================================\n');

      return conversationsList;
    } catch (e) {
      debugPrint('❌ [API CHAT ERROR] getConversations Failed!');
      debugPrint('🔴 Exception: $e');
      if (e is DioException) {
        debugPrint('   Status Code: ${e.response?.statusCode}');
        debugPrint('   Response Data: ${e.response?.data}');
      }
      debugPrint('=============================================================\n');
      rethrow;
    }
  }
}

