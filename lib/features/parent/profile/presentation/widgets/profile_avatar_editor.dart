import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/widgets/app_image_widget.dart';

/// أفاتار تعديل الملف الشخصي مع زر الكاميرا.
/// يدعم العرض الآمن على بيئتي الموبايل والويب بدون انهيار الحواف.
class ProfileAvatarEditor extends StatelessWidget {
  final dynamic avatarImage;
  final dynamic webImageBytes; // 👈 المتغير المستلم لاستقبال بايتس أو XFile أو File
  final String? avatarUrl;
  final VoidCallback onTap;

  const ProfileAvatarEditor({
    super.key,
    this.avatarImage,
    this.webImageBytes,
    this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLight, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: AppImageWidget(
                image: avatarImage ?? webImageBytes ?? avatarUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: isDark ? AppColors.grey800 : AppColors.grey200,
                  child: Icon(
                    Icons.person_rounded,
                    size: 52,
                    color: isDark ? AppColors.grey400 : AppColors.grey600,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 4,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryLight,
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: AppColors.white,
                ),
                onPressed: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
