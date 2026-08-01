import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 🌟 ويدجت آمن موحد لعرض صور المستخدمين (الأطفال/السائقين)
/// يحمي التطبيق تماماً من استثناء EncodingError أو الصور المكسورة
class AppUserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? iconSize;

  const AppUserAvatar({
    super.key,
    this.imageUrl,
    this.radius = 22.0,
    this.backgroundColor,
    this.iconColor,
    this.iconSize,
  });

  bool get _isValidUrl {
    if (imageUrl == null) return false;
    final url = imageUrl!.trim();
    if (url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? Theme.of(context).primaryColor.withValues(alpha: 0.1);
    final effectiveIconColor = iconColor ?? Theme.of(context).primaryColor;
    final effectiveIconSize = iconSize ?? (radius * 1.0);

    final Widget fallbackWidget = CircleAvatar(
      radius: radius,
      backgroundColor: effectiveBg,
      child: Icon(
        Icons.person_rounded,
        size: effectiveIconSize,
        color: effectiveIconColor,
      ),
    );

    if (!_isValidUrl) {
      return fallbackWidget;
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!.trim(),
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
      errorWidget: (context, url, error) => fallbackWidget,
    );
  }
}
