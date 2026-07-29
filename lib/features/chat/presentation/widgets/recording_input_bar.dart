import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class RecordingInputBar extends StatelessWidget {
  final int recordingSeconds;
  final VoidCallback onCancel;
  final VoidCallback onSend;
  final bool isDark;

  const RecordingInputBar({
    super.key,
    required this.recordingSeconds,
    required this.onCancel,
    required this.onSend,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 24.r),
              onPressed: onCancel,
            ),
            SizedBox(width: 8.w),
            Icon(Icons.fiber_manual_record_rounded,
                color: Colors.red, size: 16.r),
            SizedBox(width: 6.w),
            Text(
              '${(recordingSeconds ~/ 60).toString().padLeft(2, '0')}:${(recordingSeconds % 60).toString().padLeft(2, '0')}',
              style: AppTextStyles.style(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.white : AppColors.textDark,
              ),
            ),
            const Spacer(),
            Text(
              'جاري التسجيل...',
              style: AppTextStyles.style(
                fontSize: 12.sp,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(width: 12.w),
            GestureDetector(
              onTap: onSend,
              child: CircleAvatar(
                radius: 20.r,
                backgroundColor: theme.colorScheme.primary,
                child: Icon(Icons.send_rounded,
                    color: Colors.white, size: 18.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
