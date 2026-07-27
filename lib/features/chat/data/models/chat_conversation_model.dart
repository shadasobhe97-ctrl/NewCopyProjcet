class ChatConversationModel {
  final String chatRoomId;
  final int otherUserId; // maps to driver_id or parent_id
  final int otherUserAuthId; // maps to driver_user_id or parent_user_id
  final String otherUserName; // maps to driver_name or parent_name
  final String? otherUserPhone;
  final String? otherUserPhoto;
  final bool canChat;
  final String subscriptionStatus;

  ChatConversationModel({
    required this.chatRoomId,
    required this.otherUserId,
    required this.otherUserAuthId,
    required this.otherUserName,
    this.otherUserPhone,
    this.otherUserPhoto,
    required this.canChat,
    required this.subscriptionStatus,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    // 1. chatRoomId
    final roomId = json['chat_room_id']?.toString() ?? json['chatRoomId']?.toString() ?? '';

    // 2. otherUserId (Intelligently maps driver_id or parent_id)
    final int otherId = json['driver_id'] as int? ??
        json['parent_id'] as int? ??
        json['other_user_id'] as int? ??
        json['otherUserId'] as int? ??
        0;

    // 3. otherUserAuthId (Intelligently maps driver_user_id or parent_user_id)
    final int otherAuthId = json['driver_user_id'] as int? ??
        json['parent_user_id'] as int? ??
        json['driver_auth_id'] as int? ??
        json['parent_auth_id'] as int? ??
        json['other_user_auth_id'] as int? ??
        json['otherUserAuthId'] as int? ??
        0;

    // 4. otherUserName (Intelligently maps driver_name or parent_name)
    final String name = json['driver_name']?.toString() ??
        json['parent_name']?.toString() ??
        json['other_user_name']?.toString() ??
        json['otherUserName']?.toString() ??
        '';

    // 5. otherUserPhone
    final String? phone = json['driver_phone']?.toString() ??
        json['parent_phone']?.toString() ??
        json['other_user_phone']?.toString() ??
        json['otherUserPhone']?.toString();

    // 6. otherUserPhoto
    final String? photo = json['driver_photo']?.toString() ??
        json['driver_photo_url']?.toString() ??
        json['driver_avatar']?.toString() ??
        json['parent_photo']?.toString() ??
        json['parent_photo_url']?.toString() ??
        json['parent_avatar']?.toString() ??
        json['other_user_photo']?.toString() ??
        json['otherUserPhoto']?.toString() ??
        json['other_user_photo_url']?.toString();

    // 7. canChat
    final bool canChatVal = json['can_chat'] as bool? ?? json['canChat'] as bool? ?? false;

    // 8. subscriptionStatus
    final String subStatus = json['subscription_status']?.toString() ??
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
