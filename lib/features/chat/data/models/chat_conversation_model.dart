class ChatConversationModel {
  final String chatRoomId;
  final int otherUserId; // maps to driver_id or parent_id
  final int otherUserAuthId; // maps to driver_user_id or parent_user_id
  final String otherUserName; // maps to driver_name or parent_name
  final String? otherUserPhone;
  final String? otherUserPhoto;
  final bool canChat;
  final String subscriptionStatus;
  final DateTime? lastMessageTime;
  final String? lastMessagePreview;

  ChatConversationModel({
    required this.chatRoomId,
    required this.otherUserId,
    required this.otherUserAuthId,
    required this.otherUserName,
    this.otherUserPhone,
    this.otherUserPhoto,
    required this.canChat,
    required this.subscriptionStatus,
    this.lastMessageTime,
    this.lastMessagePreview,
  });

  ChatConversationModel copyWith({
    DateTime? lastMessageTime,
    String? lastMessagePreview,
  }) {
    return ChatConversationModel(
      chatRoomId: chatRoomId,
      otherUserId: otherUserId,
      otherUserAuthId: otherUserAuthId,
      otherUserName: otherUserName,
      otherUserPhone: otherUserPhone,
      otherUserPhoto: otherUserPhoto,
      canChat: canChat,
      subscriptionStatus: subscriptionStatus,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
    );
  }

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    // 1. chatRoomId
    final roomId =
        json['chat_room_id']?.toString() ??
        json['chatRoomId']?.toString() ??
        '';

    final Map<String, dynamic>? driverMap = json['driver'] is Map
        ? Map<String, dynamic>.from(json['driver'] as Map)
        : null;
    final Map<String, dynamic>? parentMap = json['parent'] is Map
        ? Map<String, dynamic>.from(json['parent'] as Map)
        : null;
    final Map<String, dynamic>? otherUserMap = json['other_user'] is Map
        ? Map<String, dynamic>.from(json['other_user'] as Map)
        : (json['otherUser'] is Map
            ? Map<String, dynamic>.from(json['otherUser'] as Map)
            : null);
    final Map<String, dynamic>? userMap = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : null;

    int? tryParseInt(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      return int.tryParse(val.toString());
    }

    // 2. otherUserId (Intelligently maps driver_id or parent_id or nested)
    final int otherId =
        tryParseInt(json['driver_id']) ??
        tryParseInt(json['parent_id']) ??
        tryParseInt(json['other_user_id']) ??
        tryParseInt(json['otherUserId']) ??
        tryParseInt(driverMap?['id']) ??
        tryParseInt(parentMap?['id']) ??
        tryParseInt(otherUserMap?['id']) ??
        tryParseInt(userMap?['id']) ??
        0;

    // 3. otherUserAuthId (Intelligently maps driver_user_id or parent_user_id)
    final int otherAuthId =
        tryParseInt(json['driver_user_id']) ??
        tryParseInt(json['parent_user_id']) ??
        tryParseInt(json['driver_auth_id']) ??
        tryParseInt(json['parent_auth_id']) ??
        tryParseInt(json['other_user_auth_id']) ??
        tryParseInt(json['otherUserAuthId']) ??
        tryParseInt(driverMap?['user_id']) ??
        tryParseInt(parentMap?['user_id']) ??
        tryParseInt(otherUserMap?['user_id']) ??
        tryParseInt(userMap?['id']) ??
        0;

    // 4. otherUserName (Intelligently maps driver_name or parent_name)
    final String name =
        json['driver_name']?.toString() ??
        json['parent_name']?.toString() ??
        json['other_user_name']?.toString() ??
        json['otherUserName']?.toString() ??
        json['name']?.toString() ??
        driverMap?['name']?.toString() ??
        driverMap?['full_name']?.toString() ??
        parentMap?['name']?.toString() ??
        parentMap?['full_name']?.toString() ??
        otherUserMap?['name']?.toString() ??
        userMap?['name']?.toString() ??
        '';

    // 5. otherUserPhone
    final String? phone =
        json['driver_phone']?.toString() ??
        json['parent_phone']?.toString() ??
        json['other_user_phone']?.toString() ??
        json['otherUserPhone']?.toString() ??
        json['phone']?.toString() ??
        driverMap?['phone']?.toString() ??
        parentMap?['phone']?.toString() ??
        otherUserMap?['phone']?.toString() ??
        userMap?['phone']?.toString();

    // 6. otherUserPhoto (Supports all avatar keys and nested user/driver/parent objects)
    final String? photo =
        json['avatar_url']?.toString() ??
        json['avatar']?.toString() ??
        json['driver_avatar_url']?.toString() ??
        json['parent_avatar_url']?.toString() ??
        json['driver_photo']?.toString() ??
        json['driver_photo_url']?.toString() ??
        json['driver_avatar']?.toString() ??
        json['parent_photo']?.toString() ??
        json['parent_photo_url']?.toString() ??
        json['parent_avatar']?.toString() ??
        json['other_user_photo']?.toString() ??
        json['otherUserPhoto']?.toString() ??
        json['other_user_photo_url']?.toString() ??
        json['other_user_avatar']?.toString() ??
        json['photo_url']?.toString() ??
        json['photo']?.toString() ??
        json['image_url']?.toString() ??
        json['image']?.toString() ??
        json['profile_image']?.toString() ??
        driverMap?['avatar_url']?.toString() ??
        driverMap?['avatar']?.toString() ??
        driverMap?['photo_url']?.toString() ??
        driverMap?['photo']?.toString() ??
        driverMap?['image_url']?.toString() ??
        parentMap?['avatar_url']?.toString() ??
        parentMap?['avatar']?.toString() ??
        parentMap?['photo_url']?.toString() ??
        parentMap?['photo']?.toString() ??
        parentMap?['image_url']?.toString() ??
        otherUserMap?['avatar_url']?.toString() ??
        otherUserMap?['avatar']?.toString() ??
        otherUserMap?['photo_url']?.toString() ??
        otherUserMap?['photo']?.toString() ??
        otherUserMap?['image_url']?.toString() ??
        userMap?['avatar_url']?.toString() ??
        userMap?['avatar']?.toString() ??
        userMap?['photo_url']?.toString() ??
        userMap?['photo']?.toString() ??
        userMap?['image_url']?.toString();

    // 7. canChat
    final bool canChatVal =
        json['can_chat'] as bool? ?? json['canChat'] as bool? ?? false;

    // 8. subscriptionStatus
    final String subStatus =
        json['subscription_status']?.toString() ??
        json['subscriptionStatus']?.toString() ??
        '';

    return ChatConversationModel(
      chatRoomId: roomId,
      otherUserId: otherId,
      otherUserAuthId: otherAuthId,
      otherUserName: name,
      otherUserPhone: phone,
      otherUserPhoto: photo,
      canChat: canChatVal,
      subscriptionStatus: subStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_room_id': chatRoomId,
      'other_user_id': otherUserId,
      'other_user_auth_id': otherUserAuthId,
      'other_user_name': otherUserName,
      'other_user_phone': otherUserPhone,
      'other_user_photo': otherUserPhoto,
      'can_chat': canChat,
      'subscription_status': subscriptionStatus,
    };
  }
}
