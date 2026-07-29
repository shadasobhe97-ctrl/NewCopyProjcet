import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:kids_transport/core/di/dependency_injection.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../cubit/chat_room_cubit.dart';
import '../cubit/chat_room_state.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/media_attachment_bottom_sheet.dart';
import '../widgets/recording_input_bar.dart';
import '../../data/models/chat_message_model.dart';

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
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  void _onTextChanged(ChatRoomCubit cubit) {
    if (!widget.canChat) return;

    cubit.updateTypingStatus(
      chatRoomId: widget.chatRoomId,
      userRole: widget.currentUserRole,
      isTyping: true,
    );

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        cubit.updateTypingStatus(
          chatRoomId: widget.chatRoomId,
          userRole: widget.currentUserRole,
          isTyping: false,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _recordingTimer?.cancel();
    _typingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  // ==================== [تسجيل الرسائل الصوتية] ====================

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = Directory.systemTemp;
        final path =
            '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });

        _recordingTimer?.cancel();
        _recordingTimer =
            Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted && _isRecording) {
            setState(() {
              _recordingSeconds++;
            });
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error starting audio recording: $e');
      }
    }
  }

  Future<void> _stopAndSendRecording(ChatRoomCubit cubit) async {
    try {
      _recordingTimer?.cancel();
      final path = await _audioRecorder.stop();
      final duration = _recordingSeconds;

      setState(() {
        _isRecording = false;
        _recordingSeconds = 0;
      });

      if (path != null && File(path).existsSync() && duration >= 1) {
        cubit.sendMediaMessage(
          chatRoomId: widget.chatRoomId,
          file: File(path),
          type: 'audio',
          senderId: widget.currentUserId,
          senderRole: widget.currentUserRole,
          audioDuration: duration,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error stopping audio recording: $e');
      }
    }
  }

  Future<void> _cancelRecording() async {
    try {
      _recordingTimer?.cancel();
      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordingSeconds = 0;
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error cancelling audio recording: $e');
      }
    }
  }

  // ==================== [اختيار الوسائط] ====================

  void _showAttachmentPicker(BuildContext blocCtx) {
    final cubit = blocCtx.read<ChatRoomCubit>();

    MediaAttachmentBottomSheet.show(
      context,
      onPickImage: (source) => _pickAndSendImage(cubit, source),
      onPickVideo: () => _pickAndSendVideo(cubit),
    );
  }

  Future<void> _pickAndSendImage(
      ChatRoomCubit cubit, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        cubit.sendMediaMessage(
          chatRoomId: widget.chatRoomId,
          file: File(pickedFile.path),
          type: 'image',
          senderId: widget.currentUserId,
          senderRole: widget.currentUserRole,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking image: $e');
      }
    }
  }

  Future<void> _pickAndSendVideo(ChatRoomCubit cubit) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 3),
      );

      if (pickedFile != null) {
        cubit.sendMediaMessage(
          chatRoomId: widget.chatRoomId,
          file: File(pickedFile.path),
          type: 'video',
          senderId: widget.currentUserId,
          senderRole: widget.currentUserRole,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking video: $e');
      }
    }
  }

  // ==================== [بناء الواجهة الرئيسية] ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider<ChatRoomCubit>(
      create: (context) => getIt<ChatRoomCubit>()
        ..listenToRoom(
          chatRoomId: widget.chatRoomId,
          currentUserId: widget.currentUserId,
          currentUserRole: widget.currentUserRole,
        ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor:
              isDark ? AppColors.backgroundDark : const Color(0xFFF1F5F9),
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
                    child: widget.otherUserPhoto != null &&
                            widget.otherUserPhoto!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.otherUserPhoto!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Icon(
                              Icons.person_rounded,
                              color: isDark
                                  ? AppColors.grey400
                                  : AppColors.grey600,
                              size: 20.r,
                            ),
                          )
                        : Icon(
                            Icons.person_rounded,
                            color:
                                isDark ? AppColors.grey400 : AppColors.grey600,
                            size: 20.r,
                          ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.otherUserName,
                        style: AppTextStyles.style(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.white : AppColors.textDark,
                        ),
                      ),
                      BlocBuilder<ChatRoomCubit, ChatRoomState>(
                        builder: (context, state) {
                          final isTyping = (state is ChatRoomLoaded &&
                                  state.isOtherUserTyping) ||
                              (state is ChatMessageSending &&
                                  state.isOtherUserTyping) ||
                              (state is ChatMessageSent &&
                                  state.isOtherUserTyping);

                          if (isTyping) {
                            return Text(
                              'جاري الكتابة...',
                              style: AppTextStyles.style(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ],
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

                    final List<ChatMessageModel> messages;
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
                              color: isDark
                                  ? AppColors.grey700
                                  : AppColors.grey300,
                              size: 56.r,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'لا توجد رسائل سابقة. ابدأ المحادثة الآن!',
                              style: AppTextStyles.style(
                                fontSize: 13.sp,
                                color: isDark
                                    ? AppColors.grey400
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 20.h),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == widget.currentUserId;

                        return ChatMessageBubble(
                          message: msg,
                          isMe: isMe,
                          isDark: isDark,
                          onDeleteForEveryone: () {
                            context
                                .read<ChatRoomCubit>()
                                .deleteMessageForEveryone(
                                  chatRoomId: widget.chatRoomId,
                                  messageId: msg.id,
                                );
                          },
                          onDeleteForMe: () {
                            context.read<ChatRoomCubit>().deleteMessageForMe(
                                  chatRoomId: widget.chatRoomId,
                                  messageId: msg.id,
                                  currentUserId: widget.currentUserId,
                                );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // Input bar / Recording bar / Muted banner
              if (widget.canChat)
                Builder(
                  builder: (blocCtx) {
                    if (_isRecording) {
                      return RecordingInputBar(
                        recordingSeconds: _recordingSeconds,
                        onCancel: _cancelRecording,
                        onSend: () => _stopAndSendRecording(
                            blocCtx.read<ChatRoomCubit>()),
                        isDark: isDark,
                      );
                    }

                    return Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.white,
                        border: Border(
                          top: BorderSide(
                            color:
                                isDark ? AppColors.grey800 : AppColors.grey200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: SafeArea(
                        child: Row(
                          children: [
                            // Attachment button
                            IconButton(
                              icon: Icon(
                                Icons.attach_file_rounded,
                                color: isDark
                                    ? AppColors.grey400
                                    : AppColors.grey600,
                                size: 22.r,
                              ),
                              onPressed: () => _showAttachmentPicker(blocCtx),
                            ),

                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.grey800
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(24.r),
                                ),
                                child: TextField(
                                  controller: _messageController,
                                  onChanged: (val) => _onTextChanged(
                                      blocCtx.read<ChatRoomCubit>()),
                                  maxLines: 4,
                                  minLines: 1,
                                  style: AppTextStyles.style(
                                    fontSize: 13.5.sp,
                                    color: isDark
                                        ? AppColors.white
                                        : AppColors.textDark,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'اكتب رسالة...',
                                    hintStyle: AppTextStyles.style(
                                      fontSize: 13.sp,
                                      color: isDark
                                          ? AppColors.grey400
                                          : AppColors.textMuted,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w, vertical: 10.h),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),

                            BlocBuilder<ChatRoomCubit, ChatRoomState>(
                              builder: (context, state) {
                                final isSending = state is ChatMessageSending;
                                final hasText =
                                    _messageController.text.trim().isNotEmpty;

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
                                            child:
                                                const CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Icon(
                                            hasText
                                                ? Icons.send_rounded
                                                : Icons.mic_rounded,
                                            color: Colors.white,
                                            size: 20.r,
                                          ),
                                    onPressed: isSending
                                        ? null
                                        : () {
                                            if (hasText) {
                                              final text =
                                                  _messageController.text
                                                      .trim();
                                              blocCtx
                                                  .read<ChatRoomCubit>()
                                                  .sendMessage(
                                                    chatRoomId:
                                                        widget.chatRoomId,
                                                    message: text,
                                                    senderId:
                                                        widget.currentUserId,
                                                    senderRole:
                                                        widget.currentUserRole,
                                                  );
                                              _messageController.clear();
                                            } else {
                                              _startRecording();
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
                  padding: EdgeInsets.symmetric(
                      horizontal: 20.w, vertical: 16.h),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color:
                              isDark ? AppColors.grey400 : AppColors.grey600,
                          size: 16.r,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'هذه المحادثة مؤرشفة لعدم وجود اشتراك نشط. يمكنك قراءة الرسائل القديمة فقط.',
                            style: AppTextStyles.style(
                              fontSize: 12.sp,
                              color: isDark
                                  ? AppColors.grey400
                                  : AppColors.grey700,
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
