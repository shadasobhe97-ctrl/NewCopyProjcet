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

    final response = await _client.get(
      path,
      headers: _authHeader,
    );

    final data = response.data;
    if (data is Map) {
      final rawList = data['data'] as List<dynamic>? ?? data['conversations'] as List<dynamic>? ?? [];
      return rawList.map((e) => ChatConversationModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } else if (data is List) {
      return data.map((e) => ChatConversationModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    return [];
  }
}
