import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class AppImageHelper {
  /// تحويل أي مصدر صورة (XFile, File, Uint8List, String path) إلى Dio MultipartFile متوافق مع Web والموبايل
  static Future<MultipartFile?> createMultipartFile(
    dynamic fileInput, {
    String defaultFilename = 'upload.jpg',
  }) async {
    if (fileInput == null) return null;

    if (fileInput is XFile) {
      final bytes = await fileInput.readAsBytes();
      final filename =
          fileInput.name.isNotEmpty ? fileInput.name : defaultFilename;
      return MultipartFile.fromBytes(bytes, filename: filename);
    }

    if (fileInput is Uint8List) {
      return MultipartFile.fromBytes(fileInput, filename: defaultFilename);
    }

    if (fileInput is File) {
      if (kIsWeb) {
        final bytes = await fileInput.readAsBytes();
        return MultipartFile.fromBytes(bytes, filename: defaultFilename);
      } else {
        final filename = fileInput.path.split('/').last.split('\\').last;
        return await MultipartFile.fromFile(
          fileInput.path,
          filename: filename.isNotEmpty ? filename : defaultFilename,
        );
      }
    }

    if (fileInput is String) {
      if (fileInput.isEmpty) return null;
      if (fileInput.startsWith('http://') ||
          fileInput.startsWith('https://') ||
          fileInput.startsWith('blob:')) {
        return null;
      }
      if (!kIsWeb) {
        final filename = fileInput.split('/').last.split('\\').last;
        return await MultipartFile.fromFile(
          fileInput,
          filename: filename.isNotEmpty ? filename : defaultFilename,
        );
      }
    }

    return null;
  }
}
