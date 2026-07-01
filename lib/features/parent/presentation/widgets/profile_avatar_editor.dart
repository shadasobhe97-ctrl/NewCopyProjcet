import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

/// أفاتار تعديل الملف الشخصي مع زر الكاميرا.
class ProfileAvatarEditor extends StatelessWidget {
  final File? avatarImage;
  final VoidCallback onTap;

  const ProfileAvatarEditor({
    super.key,
    this.avatarImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Stack(
        children: [
          Container(
            decoration: AppTheme.boxDecoration(
              shape: BoxShape.circle,
              border: AppTheme.border(color: AppColors.primaryLight, width: 3),
              boxShadow: [
                AppTheme.boxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 55,
              backgroundColor:
                  isDark ? AppColors.grey800 : AppColors.grey200,
              backgroundImage:
                  avatarImage != null ? FileImage(avatarImage!) : null,
              child: avatarImage == null
                  ? Icon(
                      Icons.person_rounded,
                      size: 55,
                      color: isDark ? AppColors.grey400 : AppColors.grey600,
                    )
                  : null,
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
