import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AppImageWidget extends StatelessWidget {
  final dynamic image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppImageWidget({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return errorWidget ?? _defaultErrorWidget();
    }

    if (image is Uint8List) {
      return Image.memory(
        image as Uint8List,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, stack) => errorWidget ?? _defaultErrorWidget(),
      );
    }

    if (image is XFile) {
      final xfile = image as XFile;
      if (kIsWeb) {
        return Image.network(
          xfile.path,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) => errorWidget ?? _defaultErrorWidget(),
        );
      } else {
        return Image.file(
          File(xfile.path),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) => errorWidget ?? _defaultErrorWidget(),
        );
      }
    }

    if (image is File) {
      final file = image as File;
      if (kIsWeb) {
        return Image.network(
          file.path,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) => errorWidget ?? _defaultErrorWidget(),
        );
      } else {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) => errorWidget ?? _defaultErrorWidget(),
        );
      }
    }

    if (image is String) {
      final str = (image as String).trim();
      if (str.isEmpty) return errorWidget ?? _defaultErrorWidget();

      final resolvedUrl = _resolveImageUrl(str);
      return Image.network(
        resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (ctx, err, stack) => errorWidget ?? _defaultErrorWidget(),
      );
    }

    return errorWidget ?? _defaultErrorWidget();
  }

  Widget _defaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }

  String _resolveImageUrl(String raw) {
    if (raw.startsWith('blob:')) return raw;

    const serverHost = 'https://nasty-seahorse-19.loca.lt';

    if (raw.startsWith('http://localhost') || raw.startsWith('http://127.0.0.1')) {
      final uri = Uri.parse(raw);
      return '$serverHost${uri.path}';
    }

    if (raw.startsWith('https://api.example.com')) {
      final uri = Uri.parse(raw);
      return '$serverHost${uri.path}';
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    final cleanPath = raw.startsWith('/') ? raw : '/$raw';
    return '$serverHost$cleanPath';
  }
}
