import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_transport/core/utils/app_image_helper.dart';
import 'package:kids_transport/core/widgets/app_image_widget.dart';

/// 🌟 ويدجت موحد وشامل لعرض صور المستخدمين (السائقين، أولياء الأمور، الأطفال)
/// يدعم جميع المنصات (Web و Mobile)، وجميع أنواع المدخلات (String URL, XFile, File, Uint8List)
class AppUserAvatar extends StatelessWidget {
  final dynamic image;
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? iconSize;
  final IconData defaultIcon;

  const AppUserAvatar({
    super.key,
    this.image,
    this.imageUrl,
    this.radius = 22.0,
    this.backgroundColor,
    this.iconColor,
    this.iconSize,
    this.defaultIcon = Icons.person_rounded,
  });

  /// هيدر مطلوب لتجاوز صفحة تحذير localtunnel عند تحميل الصور على الأجهزة الحقيقية
  static Map<String, String>? get imageHeaders => AppImageHelper.safeHttpHeaders;

  /// يحوّل الروابط النسبية وروابط localhost إلى رابط كامل على السيرفر
  static String? resolveUrl(String? raw) => AppImageHelper.resolveUrl(raw);

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ??
        Theme.of(context).primaryColor.withValues(alpha: 0.12);
    final effectiveIconColor = iconColor ?? Theme.of(context).primaryColor;
    final effectiveIconSize = iconSize ?? (radius * 1.0);

    final Widget fallbackWidget = CircleAvatar(
      radius: radius,
      backgroundColor: effectiveBg,
      child: Icon(
        defaultIcon,
        size: effectiveIconSize,
        color: effectiveIconColor,
      ),
    );

    final input = image ?? imageUrl;
    if (input == null) return fallbackWidget;

    // 1. بايتس جاهزة
    if (input is Uint8List) {
      if (input.isEmpty) return fallbackWidget;
      return CircleAvatar(
        radius: radius,
        backgroundColor: effectiveBg,
        backgroundImage: MemoryImage(input),
      );
    }

    // 2. كائن XFile (من الكاميرا أو المعرض)
    if (input is XFile) {
      if (kIsWeb) {
        return FutureBuilder<Uint8List>(
          future: input.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CircleAvatar(
                radius: radius,
                backgroundColor: effectiveBg,
                backgroundImage: MemoryImage(snapshot.data!),
              );
            }
            return fallbackWidget;
          },
        );
      } else {
        final file = File(input.path);
        if (!file.existsSync()) return fallbackWidget;
        return CircleAvatar(
          radius: radius,
          backgroundColor: effectiveBg,
          backgroundImage: FileImage(file),
        );
      }
    }

    // 3. كائن File
    if (input is File) {
      if (kIsWeb) {
        return FutureBuilder<Uint8List>(
          future: input.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CircleAvatar(
                radius: radius,
                backgroundColor: effectiveBg,
                backgroundImage: MemoryImage(snapshot.data!),
              );
            }
            return fallbackWidget;
          },
        );
      } else {
        if (!input.existsSync()) return fallbackWidget;
        return CircleAvatar(
          radius: radius,
          backgroundColor: effectiveBg,
          backgroundImage: FileImage(input),
        );
      }
    }

    // 4. رابط نصي String
    if (input is String) {
      final rawStr = input.trim();
      if (rawStr.isEmpty) return fallbackWidget;

      // إذا كان ملف محلي على الموبايل
      if (!kIsWeb &&
          (rawStr.startsWith('/data/') ||
              rawStr.startsWith('/storage/emulated/') ||
              rawStr.contains(':\\'))) {
        final localFile = File(rawStr);
        if (localFile.existsSync()) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: effectiveBg,
            backgroundImage: FileImage(localFile),
          );
        }
      }

      final resolvedUrl = resolveUrl(rawStr);
      if (resolvedUrl == null || !AppImageHelper.isValidImageUrl(resolvedUrl)) {
        return fallbackWidget;
      }

      // روابط blob أو assets
      if (resolvedUrl.startsWith('blob:')) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: effectiveBg,
          backgroundImage: NetworkImage(resolvedUrl),
        );
      }

      if (resolvedUrl.startsWith('assets/')) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: effectiveBg,
          backgroundImage: AssetImage(resolvedUrl),
        );
      }

      // على الويب: نستخدم AppImageWidget لضمان تحميل الصورة عبر Dio وتجاوز قيود CORS و localtunnel
      if (kIsWeb) {
        return ClipOval(
          child: SizedBox(
            width: radius * 2,
            height: radius * 2,
            child: AppImageWidget(
              image: resolvedUrl,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              placeholder: CircleAvatar(
                radius: radius,
                backgroundColor: effectiveBg,
                child: SizedBox(
                  width: radius * 0.7,
                  height: radius * 0.7,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: effectiveIconColor,
                  ),
                ),
              ),
              errorWidget: fallbackWidget,
            ),
          ),
        );
      }

      return CachedNetworkImage(
        imageUrl: resolvedUrl,
        httpHeaders: imageHeaders,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundColor: effectiveBg,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: radius,
          backgroundColor: effectiveBg,
          child: SizedBox(
            width: radius * 0.8,
            height: radius * 0.8,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: effectiveIconColor,
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          debugPrint('⚠️ [AppUserAvatar] Error loading avatar: "$resolvedUrl": $error');
          return fallbackWidget;
        },
      );
    }

    return fallbackWidget;
  }
}
