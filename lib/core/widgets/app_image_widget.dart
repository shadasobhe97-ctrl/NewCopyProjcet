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
      final str = image as String;
      if (str.isEmpty) return errorWidget ?? _defaultErrorWidget();

      if (str.startsWith('http://') ||
          str.startsWith('https://') ||
          str.startsWith('blob:')) {
        return Image.network(
          str,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) => errorWidget ?? _defaultErrorWidget(),
        );
      } else {
        if (kIsWeb) {
          return Image.network(
            str,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (ctx, err, stack) => errorWidget ?? _defaultErrorWidget(),
          );
        } else {
          return Image.file(
            File(str),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (ctx, err, stack) => errorWidget ?? _defaultErrorWidget(),
          );
        }
      }
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
}
