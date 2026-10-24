import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';

/// 🌟 مساعد موحد لإدارة وبناء وتحميل الصور بأمان عبر مختلف المنصات (Flutter Web و Mobile)
class AppImageHelper {
  AppImageHelper._();

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

  /// قائمة مفاتيح حقول الصور الشائعة في استجابات الـ API
  static const Set<String> imageFieldKeys = {
    'photo_url',
    'photo',
    'avatar_url',
    'avatar',
    'image',
    'image_url',
    'child_photo',
    'driver_avatar',
    'other_user_photo_url',
    'driver_photo_url',
    'parent_photo_url',
    'logo_url',
    'receipt_url',
    'vehicle_photo',
    'license_photo',
    'document_photo',
    'media_url',
  };

  /// هيدر تجاوز صفحة تحذير localtunnel (loca.lt) - يتم تعطيله في الويب لتفادي حظر CORS
  static Map<String, String>? get safeHttpHeaders {
    if (kIsWeb) return null;
    return const {'bypass-tunnel-reminder': 'true'};
  }

  /// استخراج النطاق الأساسي للخادم بدون /api
  static String get serverBaseUrl {
    final base = ApiEndpoints.baseUrl.trim();
    return base.replaceAll(RegExp(r'/?api/?$'), '');
  }

  /// تحويل أي رابط صورة (نسبي، localhost، http غير آمن، إلخ) إلى رابط كامل صالح ومستقر
  static String? resolveUrl(dynamic raw) {
    if (raw == null) return null;
    final str = raw.toString().trim();
    if (str.isEmpty ||
        str.toLowerCase() == 'null' ||
        str.toLowerCase() == 'undefined' ||
        str.toLowerCase() == 'none') {
      return null;
    }

    // إذا كان الرابط blob محلي أو data URI أو asset
    if (str.startsWith('blob:') ||
        str.startsWith('data:') ||
        str.startsWith('assets/')) {
      return str;
    }

    final serverHost = serverBaseUrl;
    final isServerHttps = ApiEndpoints.baseUrl.startsWith('https://');
    String resolved = str;

    // استبدال localhost أو 127.0.0.1 أو النطاقات الوهمية بنطاق السيرفر الحالي
    if (str.startsWith('http://localhost') ||
        str.startsWith('http://127.0.0.1') ||
        str.startsWith('https://localhost') ||
        str.startsWith('https://127.0.0.1') ||
        str.startsWith('https://api.example.com')) {
      final uri = Uri.parse(str);
      resolved = '$serverHost${uri.path}';
      if (uri.hasQuery) {
        resolved += '?${uri.query}';
      }
    } else if (str.startsWith('//')) {
      resolved = 'https:$str';
    } else if (!str.startsWith('http://') && !str.startsWith('https://')) {
      final clean = str.startsWith('/') ? str : '/$str';
      resolved = '$serverHost$clean';
    }

    // إزالة أي تكرار لـ /storage/ إذا وجد في الرابط النهائي
    if (resolved.contains('/storage/storage/')) {
      resolved = resolved.replaceAll('/storage/storage/', '/storage/');
    }

    // ترقية http إلى https إذا كان السيرفر على https لتفادي حظر المحتوى المختلط في كروم
    if (isServerHttps && resolved.startsWith('http://')) {
      resolved = 'https://${resolved.substring(7)}';
    }

    return resolved;
  }

  /// فحص متقدم للتأكد من أن الرابط يمثل صورة حقيقية وليس نصاً فارغاً أو افتراضياً
  static bool isValidImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final lower = url.trim().toLowerCase();
    if (lower == 'null' ||
        lower == 'undefined' ||
        lower == 'none' ||
        lower.contains('default-child') ||
        lower.contains('assets/images/default') ||
        lower.endsWith('default-child.png')) {
      return false;
    }
    return true;
  }

  /// تطبيع استجابات الـ API تلقائياً لحل كافة روابط الصور داخل الـ Maps والـ Lists
  static dynamic normalizeJson(dynamic data) {
    if (data is Map) {
      final result = <String, dynamic>{};
      for (final entry in data.entries) {
        final key = entry.key.toString();
        final value = entry.value;
        if (imageFieldKeys.contains(key.toLowerCase())) {
          if (value is String) {
            result[key] = resolveUrl(value);
          } else {
            result[key] = value;
          }
        } else if (value is Map || value is List) {
          result[key] = normalizeJson(value);
        } else {
          result[key] = value;
        }
      }
      return result;
    } else if (data is List) {
      return data.map(normalizeJson).toList();
    }
    return data;
  }

  /// التحميل المسبق للأصول الصورية الأساسية في Flutter Web لضمان ظهورها من أول فريم
  static void precacheAppAssets(BuildContext context) {
    const assets = [
      'assets/images/ligth_logo.png',
      'assets/images/dark_logo.png',
      'assets/images/Onboarding1.png',
      'assets/images/hastrips.png',
    ];
    for (final asset in assets) {
      precacheImage(AssetImage(asset), context).catchError((e) {
        debugPrint('⚠️ [AppImageHelper] Precache error for $asset: $e');
      });
    }
  }
}
