import 'dart:io';
import 'dart:typed_data'; // 👈 استيراد بايتس الصورة لدعم الـ Web
import 'package:flutter/foundation.dart'; // 👈 استيراد kIsWeb للتحقق من بيئة العمل
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';

/// أفاتار تعديل الملف الشخصي مع زر الكاميرا.
/// يدعم العرض الآمن على بيئتي الموبايل والويب بدون انهيار الحواف.
class ProfileAvatarEditor extends StatelessWidget {
  final File? avatarImage;
  final Uint8List? webImageBytes; // 👈 المتغير الجديد لاستقبال بايتس الويب
  final String? avatarUrl;
  final VoidCallback onTap;

  const ProfileAvatarEditor({
    super.key,
    this.avatarImage,
    this.webImageBytes, // 👈 إضافته في الـ Constructor
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
              child: kIsWeb && webImageBytes != null
                  ? Image.memory(
                      webImageBytes!, // 👈 العرض الآمن للبايتس على الويب لمنع الشاشة الحمراء
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    )
                  : (!kIsWeb && avatarImage != null
                        ? Image.file(
                            avatarImage!,
                            width: 110,
                            height: 110,
                            fit: BoxFit
                                .cover, // يملأ الدائرة بشكل ناعم بدون تشويه
                          )
                        : (avatarUrl != null && avatarUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: avatarUrl!,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.person_rounded,
                                    size: 52,
                                    color: isDark
                                        ? AppColors.grey400
                                        : AppColors.grey600,
                                  ),
                                )
                              : Container(
                                  color: isDark
                                      ? AppColors.grey800
                                      : AppColors.grey200,
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 52,
                                    color: isDark
                                        ? AppColors.grey400
                                        : AppColors.grey600,
                                  ),
                                ))),
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
