import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';

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

  /// هيدر مطلوب لتجاوز صفحة تحذير localtunnel (loca.lt) عند تحميل الصور
  static const Map<String, String> imageHeaders = {
    'bypass-tunnel-reminder': 'true',
    'Accept': 'image/*, */*',
  };

  /// يحوّل الروابط النسبية وروابط localhost إلى رابط كامل وصالح على السيرفر
  static String? resolveUrl(String? raw) {
    if (raw == null) return null;
    final url = raw.trim();
    if (url.isEmpty) return null;

    // روابط الـ Blob والـ Data URL تبقى كما هي
    if (url.startsWith('blob:') || url.startsWith('data:')) {
      return url;
    }

    // مسارات الملفات المحلية على جهاز الموبايل
    if (!kIsWeb && (url.startsWith('/data/') || url.startsWith('/storage/emulated/') || url.contains(':\\'))) {
      return url;
    }

    final serverHost = ApiEndpoints.baseUrl.replaceAll(RegExp(r'/?api/?$'), '');
    String resolved = url;

    if (url.startsWith('http://localhost') || url.startsWith('http://127.0.0.1')) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        resolved = '$serverHost${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}';
      } else {
        resolved = url.replaceFirst(RegExp(r'^http://(localhost|127\.0\.0\.1)(:\d+)?'), serverHost);
      }
    } else if (url.startsWith('https://api.example.com')) {
      final uri = Uri.tryParse(url);
      resolved = uri != null ? '$serverHost${uri.path}' : url;
    } else if (url.startsWith('//')) {
      resolved = 'https:$url';
    } else if (!url.startsWith('http://') && !url.startsWith('https://')) {
      final cleanPath = url.startsWith('/') ? url : '/$url';
      resolved = '$serverHost$cleanPath';
    }

    // ترقية http إلى https إذا كان السيرفر يستعمل https لتفادي حظر Mixed Content على المتصفح
    if (serverHost.startsWith('https://') && resolved.startsWith('http://')) {
      resolved = 'https://${resolved.substring(7)}';
    }

    return resolved;
  }

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
        return CircleAvatar(
          radius: radius,
          backgroundColor: effectiveBg,
          backgroundImage: NetworkImage(input.path),
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
        return CircleAvatar(
          radius: radius,
          backgroundColor: effectiveBg,
          backgroundImage: NetworkImage(input.path),
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
      if (!kIsWeb && (rawStr.startsWith('/data/') || rawStr.startsWith('/storage/emulated/') || rawStr.contains(':\\'))) {
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
      if (resolvedUrl == null) return fallbackWidget;

      // روابط blob على الويب
      if (resolvedUrl.startsWith('blob:')) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: effectiveBg,
          backgroundImage: NetworkImage(resolvedUrl),
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
            width: radius * 0.7,
            height: radius * 0.7,
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
