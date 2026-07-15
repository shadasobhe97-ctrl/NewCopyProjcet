import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

/// أفاتار تعديل الملف الشخصي مع زر الكاميرا.
/// يعرض [avatarImage] (ملف محلي) إن وُجد،
/// أو [avatarUrl] (صورة من الـ API) إن وُجد،
/// وإلا يعرض أيقونة افتراضية.
class ProfileAvatarEditor extends StatelessWidget {
  final File? avatarImage;
  final String? avatarUrl;
  final VoidCallback onTap;

  const ProfileAvatarEditor({
    super.key,
    this.avatarImage,
    this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ImageProvider? imageProvider;
    if (avatarImage != null) {
      imageProvider = FileImage(avatarImage!);
    } else if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(avatarUrl!);
    }

    return Center(
      child: Stack(
        children: [
          Container(
            decoration: AppTheme.boxDecoration(
              shape: BoxShape.circle,
              border: AppTheme.border(
                  color: AppColors.primaryLight, width: 3),
              boxShadow: [
                AppTheme.boxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 52,
              backgroundColor:
                  isDark ? AppColors.grey800 : AppColors.grey200,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? Icon(
                      Icons.person_rounded,
                      size: 52,
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
