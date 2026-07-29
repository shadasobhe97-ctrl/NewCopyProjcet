import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class MediaAttachmentBottomSheet extends StatelessWidget {
  final Function(ImageSource source) onPickImage;
  final VoidCallback onPickVideo;

  const MediaAttachmentBottomSheet({
    super.key,
    required this.onPickImage,
    required this.onPickVideo,
  });

  static void show(
    BuildContext context, {
    required Function(ImageSource source) onPickImage,
    required VoidCallback onPickVideo,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => MediaAttachmentBottomSheet(
        onPickImage: (source) {
          Navigator.pop(ctx);
          onPickImage(source);
        },
        onPickVideo: () {
          Navigator.pop(ctx);
          onPickVideo();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إرفاق وسائط',
              style: AppTextStyles.style(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttachmentOption(
                  icon: Icons.photo_library_rounded,
                  color: Colors.purple,
                  label: 'المعرض',
                  onTap: () => onPickImage(ImageSource.gallery),
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt_rounded,
                  color: Colors.blue,
                  label: 'الكاميرا',
                  onTap: () => onPickImage(ImageSource.camera),
                ),
                _buildAttachmentOption(
                  icon: Icons.videocam_rounded,
                  color: Colors.pink,
                  label: 'فيديو',
                  onTap: onPickVideo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 26.r),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: AppTextStyles.style(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
