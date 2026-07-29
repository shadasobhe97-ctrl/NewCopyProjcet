import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart' as intl;
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import '../../data/models/chat_message_model.dart';
import 'voice_note_bubble.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;
  final bool isDark;
  final VoidCallback? onDeleteForEveryone;
  final VoidCallback? onDeleteForMe;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.isDark,
    this.onDeleteForEveryone,
    this.onDeleteForMe,
  });

  String _formatTime(DateTime dateTime) {
    try {
      return intl.DateFormat('hh:mm a', 'ar').format(dateTime);
    } catch (_) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40.h,
              right: 16.w,
              child: IconButton(
                icon: Icon(Icons.close_rounded,
                    color: Colors.white, size: 28.r),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.grey700 : AppColors.grey300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.h),
                if (isMe && !message.isDeletedForEveryone) ...[
                  ListTile(
                    leading: const Icon(Icons.delete_forever_rounded,
                        color: AppColors.error),
                    title: Text(
                      'حذف لدى الجميع',
                      style: AppTextStyles.style(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      onDeleteForEveryone?.call();
                    },
                  ),
                  const Divider(),
                ],
                ListTile(
                  leading: Icon(Icons.delete_outline_rounded,
                      color: isDark ? AppColors.white : AppColors.textDark),
                  title: Text(
                    'حذف لدي فقط',
                    style: AppTextStyles.style(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.textDark,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    onDeleteForMe?.call();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showOptionsBottomSheet(context),
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
              _buildContent(context),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.style(
                      fontSize: 10.sp,
                      color: isMe
                          ? Colors.white70
                          : (isDark ? AppColors.grey400 : AppColors.textMuted),
                    ),
                  ),
                  if (isMe) ...[
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.done_all_rounded,
                      size: 15.r,
                      color: message.isRead
                          ? const Color(0xFF60A5FA)
                          : Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (message.isDeletedForEveryone) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.block_rounded,
            size: 16.r,
            color: isMe
                ? Colors.white70
                : (isDark ? AppColors.grey400 : AppColors.textMuted),
          ),
          SizedBox(width: 6.w),
          Text(
            'تم حذف هذه الرسالة',
            style: AppTextStyles.style(
              fontSize: 13.sp,
              fontStyle: FontStyle.italic,
              color: isMe
                  ? Colors.white70
                  : (isDark ? AppColors.grey400 : AppColors.textMuted),
            ),
          ),
        ],
      );
    }

    if (message.type == 'image' &&
        message.mediaUrl != null &&
        message.mediaUrl!.isNotEmpty) {
      return GestureDetector(
        onTap: () => _showFullScreenImage(context, message.mediaUrl!),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                imageUrl: message.mediaUrl!,
                width: 200.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 200.w,
                  height: 150.h,
                  color: isDark ? AppColors.grey800 : AppColors.grey100,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.broken_image_rounded,
                  color: isMe ? Colors.white : AppColors.grey600,
                  size: 40.r,
                ),
              ),
            ),
            if (message.message.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                message.message,
                style: AppTextStyles.style(
                  fontSize: 13.5.sp,
                  color: isMe
                      ? Colors.white
                      : (isDark ? AppColors.white : AppColors.textDark),
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (message.type == 'video' &&
        message.mediaUrl != null &&
        message.mediaUrl!.isNotEmpty) {
      return GestureDetector(
        onTap: () async {
          final uri = Uri.parse(message.mediaUrl!);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.play_circle_fill_rounded,
                    color: Colors.white,
                    size: 48.r,
                  ),
                  Positioned(
                    bottom: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'فيديو',
                        style: AppTextStyles.style(
                          fontSize: 10.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (message.message.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                message.message,
                style: AppTextStyles.style(
                  fontSize: 13.5.sp,
                  color: isMe
                      ? Colors.white
                      : (isDark ? AppColors.white : AppColors.textDark),
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (message.type == 'audio' &&
        message.mediaUrl != null &&
        message.mediaUrl!.isNotEmpty) {
      return VoiceNoteBubble(
        audioUrl: message.mediaUrl!,
        durationSeconds: message.audioDuration,
        isMe: isMe,
      );
    }

    // Default Text Message
    return Text(
      message.message,
      style: AppTextStyles.style(
        fontSize: 13.5.sp,
        color: isMe
            ? Colors.white
            : (isDark ? AppColors.white : AppColors.textDark),
      ),
    );
  }
}
