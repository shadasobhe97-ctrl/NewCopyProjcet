import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart' as intl;
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../cubit/chat_room_cubit.dart';
import '../cubit/chat_room_state.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherUserName;
  final String? otherUserPhoto;
  final bool canChat;
  final String currentUserId;
  final String currentUserRole;

  const ChatRoomScreen({
    super.key,
    required this.chatRoomId,
    required this.otherUserName,
    this.otherUserPhoto,
    required this.canChat,
    required this.currentUserId,
    required this.currentUserRole,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dateTime) {
    try {
      return intl.DateFormat('hh:mm a', 'ar').format(dateTime);
    } catch (_) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider<ChatRoomCubit>(
      create: (context) => getIt<ChatRoomCubit>()..listenToMessages(widget.chatRoomId),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF1F5F9),
          appBar: AppBar(
            elevation: 0.5,
            shadowColor: isDark ? Colors.transparent : Colors.grey.shade300,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
            foregroundColor: isDark ? AppColors.white : AppColors.textDark,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18.r),
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    color: isDark ? AppColors.grey800 : AppColors.grey100,
                    child: widget.otherUserPhoto != null && widget.otherUserPhoto!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.otherUserPhoto!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Icon(
                              Icons.person_rounded,
                              color: isDark ? AppColors.grey400 : AppColors.grey600,
                              size: 20.r,
                            ),
                          )
                        : Icon(
                            Icons.person_rounded,
                            color: isDark ? AppColors.grey400 : AppColors.grey600,
                            size: 20.r,
                          ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    widget.otherUserName,
                    style: AppTextStyles.style(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.white : AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Message List Area
              Expanded(
                child: BlocBuilder<ChatRoomCubit, ChatRoomState>(
                  builder: (context, state) {
                    if (state is ChatRoomLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      );
                    }

                    if (state is ChatRoomError) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.style(
                              fontSize: 13.5.sp,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      );
                    }

                    final List<dynamic> messages;
                    if (state is ChatRoomLoaded) {
                      messages = state.messages.reversed.toList();
                    } else if (state is ChatMessageSending) {
                      messages = state.messages.reversed.toList();
                    } else if (state is ChatMessageSent) {
                      messages = state.messages.reversed.toList();
                    } else {
                      messages = [];
                    }

                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.forum_outlined,
                              color: isDark ? AppColors.grey700 : AppColors.grey300,
                              size: 56.r,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'لا توجد رسائل سابقة. ابدأ المحادثة الآن!',
                              style: AppTextStyles.style(
                                fontSize: 13.sp,
                                color: isDark ? AppColors.grey400 : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == widget.currentUserId;

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: 12.h,
                              left: isMe ? 50.w : 0,
                              right: isMe ? 0 : 50.w,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? theme.colorScheme.primary
                                  : (isDark ? AppColors.surfaceDark : AppColors.white),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.r),
                                topRight: Radius.circular(16.r),
                                bottomLeft: isMe ? Radius.circular(16.r) : Radius.zero,
                                bottomRight: isMe ? Radius.zero : Radius.circular(16.r),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  msg.message,
                                  style: AppTextStyles.style(
                                    fontSize: 13.5.sp,
                                    color: isMe
                                        ? Colors.white
                                        : (isDark ? AppColors.white : AppColors.textDark),
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _formatTime(msg.timestamp),
                                  style: AppTextStyles.style(
                                    fontSize: 10.sp,
                                    color: isMe
                                        ? Colors.white70
                                        : (isDark ? AppColors.grey400 : AppColors.textMuted),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Input bar / Muted banner
              if (widget.canChat)
                Builder(
                  builder: (blocCtx) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.white,
                        border: Border(
                          top: BorderSide(
                            color: isDark ? AppColors.grey800 : AppColors.grey200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.grey800 : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                                child: TextField(
                                  controller: _messageController,
                                  maxLines: 4,
                                  minLines: 1,
                                  style: AppTextStyles.style(
                                    fontSize: 13.5.sp,
                                    color: isDark ? AppColors.white : AppColors.textDark,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'اكتب رسالة...',
                                    hintStyle: AppTextStyles.style(
                                      fontSize: 13.sp,
                                      color: isDark ? AppColors.grey400 : AppColors.textMuted,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            BlocBuilder<ChatRoomCubit, ChatRoomState>(
                              builder: (context, state) {
                                final isSending = state is ChatMessageSending;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: isSending
                                        ? SizedBox(
                                            width: 18.w,
                                            height: 18.w,
                                            child: const CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Icon(
                                            Icons.send_rounded,
                                            color: Colors.white,
                                            size: 20.r,
                                          ),
                                    onPressed: isSending
                                        ? null
                                        : () {
                                            final text = _messageController.text.trim();
                                            if (text.isNotEmpty) {
                                              blocCtx.read<ChatRoomCubit>().sendMessage(
                                                    chatRoomId: widget.chatRoomId,
                                                    message: text,
                                                    senderId: widget.currentUserId,
                                                    senderRole: widget.currentUserRole,
                                                  );
                                              _messageController.clear();
                                            }
                                          },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              else
                Container(
                  width: double.infinity,
                  color: isDark ? AppColors.grey900 : const Color(0xFFE2E8F0),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: isDark ? AppColors.grey400 : AppColors.grey600,
                          size: 16.r,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'هذه المحادثة مؤرشفة لعدم وجود اشتراك نشط. يمكنك قراءة الرسائل القديمة فقط.',
                            style: AppTextStyles.style(
                              fontSize: 12.sp,
                              color: isDark ? AppColors.grey400 : AppColors.grey700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
