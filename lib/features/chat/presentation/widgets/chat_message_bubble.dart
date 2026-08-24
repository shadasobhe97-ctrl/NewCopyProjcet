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
    final primaryColor = theme.colorScheme.primary;

    // تحديد ألوان الخلفية والحدود بدقة متناهية لتوافق التيم الفاتح والداكن
    final Color bubbleBg;
    final Border? bubbleBorder;
    final Color textColor;
    final Color timeColor;
    final Color readCheckmarkColor;

    if (isMe) {
      if (isDark) {
        bubbleBg = const Color(0xFF1E293B);
        bubbleBorder = Border.all(
          color: primaryColor.withValues(alpha: 0.4),
          width: 1,
        );
        textColor = const Color(0xFFF8FAFC);
        timeColor = const Color(0xFF94A3B8);
        readCheckmarkColor = message.isRead
            ? const Color(0xFF38BDF8) // أزرق سماوي مضيء وواضح في التيم الداكن
            : const Color(0xFF64748B);
      } else {
        bubbleBg = const Color(0xFFEBF3FE); // درجة ناعمة وخفيفة من لون الهوية
        bubbleBorder = Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1,
        );
        textColor = const Color(0xFF0F172A);
        timeColor = const Color(0xFF64748B);
        readCheckmarkColor = message.isRead
            ? const Color(0xFF0284C7) // أزرق غامق بارز وواضح جداً في التيم الفاتح
            : const Color(0xFF94A3B8);
      }
    } else {
      if (isDark) {
        bubbleBg = const Color(0xFF0F172A);
        bubbleBorder = Border.all(
          color: const Color(0xFF334155),
          width: 1,
        );
        textColor = const Color(0xFFF1F5F9);
        timeColor = const Color(0xFF94A3B8);
      } else {
        bubbleBg = Colors.white;
        bubbleBorder = Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        );
        textColor = const Color(0xFF0F172A);
        timeColor = const Color(0xFF64748B);
      }
      readCheckmarkColor = Colors.transparent;
    }

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
            color: bubbleBg,
            border: bubbleBorder,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomLeft: isMe ? Radius.circular(16.r) : Radius.zero,
              bottomRight: isMe ? Radius.zero : Radius.circular(16.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildContent(context, textColor: textColor, timeColor: timeColor),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.style(
                      fontSize: 10.sp,
                      color: timeColor,
                    ),
                  ),
                  if (isMe) ...[
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.done_all_rounded,
                      size: 16.r,
                      color: readCheckmarkColor,
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

  Widget _buildContent(
    BuildContext context, {
    required Color textColor,
    required Color timeColor,
  }) {
    if (message.isDeletedForEveryone) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.block_rounded,
            size: 16.r,
            color: timeColor,
          ),
          SizedBox(width: 6.w),
          Text(
            'تم حذف هذه الرسالة',
            style: AppTextStyles.style(
              fontSize: 13.sp,
              fontStyle: FontStyle.italic,
              color: timeColor,
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
                  color: textColor,
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
                  color: textColor,
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
                  color: textColor,
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
        isDark: isDark,
      );
    }

    // Default Text Message
    return Text(
      message.message,
      style: AppTextStyles.style(
        fontSize: 13.5.sp,
        color: textColor,
      ),
    );
  }
}
