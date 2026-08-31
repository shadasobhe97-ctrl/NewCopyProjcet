import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'uagdqgc9';
  static const String uploadPreset = 'darby_preset';

  final http.Client _client;

  CloudinaryService({http.Client? client}) : _client = client ?? http.Client();

  /// Uploads media file or raw bytes directly to Cloudinary using Unsigned REST API.
  /// Returns direct secure URL ([secure_url]).
  ///
  /// [resourceType] must be 'image' or 'video' (Audio files require 'video').
  Future<String> uploadMedia({
    File? file,
    Uint8List? bytes,
    required String fileName,
    required String resourceType,
  }) async {
    // Audio files must use 'video' as resourceType in Cloudinary
    final String actualResourceType =
        (resourceType.toLowerCase() == 'audio' ||
                resourceType.toLowerCase() == 'audios')
            ? 'video'
            : resourceType.toLowerCase();

    debugPrint(
        '☁️ [CloudinaryService] Starting upload: fileName="$fileName", inputResourceType="$resourceType", actualResourceType="$actualResourceType"');

    try {
      final Uri uploadUri = Uri.parse(
          'https://api.cloudinary.com/v1_1/$cloudName/$actualResourceType/upload');

      debugPrint('☁️ [CloudinaryService] Target URL: $uploadUri');

      final request = http.MultipartRequest('POST', uploadUri);
      request.fields['upload_preset'] = uploadPreset;

      if (bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: fileName,
          ),
        );
        debugPrint(
            '☁️ [CloudinaryService] Attached file bytes (Length: ${bytes.length} bytes)');
      } else if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            filename: fileName,
          ),
        );
        debugPrint(
            '☁️ [CloudinaryService] Attached file path: ${file.path}');
      } else {
        const errorMsg =
            '☁️ [CloudinaryService] Error: Neither file nor bytes was provided for upload.';
        debugPrint(errorMsg);
        throw Exception(errorMsg);
      }

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint(
          '☁️ [CloudinaryService] Response StatusCode: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String? secureUrl = data['secure_url']?.toString();
        if (secureUrl != null && secureUrl.isNotEmpty) {
          debugPrint(
              '✅ [CloudinaryService] Upload SUCCESS! Status: ${response.statusCode}, secure_url: $secureUrl');
          return secureUrl;
        } else {
          final errorMsg =
              '❌ [CloudinaryService] Upload Response missing secure_url. Body: ${response.body}';
          debugPrint(errorMsg);
          throw Exception(errorMsg);
        }
      } else {
        final errorMsg =
            '❌ [CloudinaryService] Upload FAILED! StatusCode: ${response.statusCode}, Response Body: ${response.body}';
        debugPrint(errorMsg);
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [CloudinaryService] Exception during upload: $e');
      debugPrint('StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Convenience method for uploading bytes.
  Future<String> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    required String folderName,
  }) async {
    final String resourceType =
        (folderName == 'audios' || folderName == 'videos') ? 'video' : 'image';
    return uploadMedia(
      bytes: bytes,
      fileName: fileName,
      resourceType: resourceType,
    );
  }

  /// Convenience method for uploading a File.
  Future<String> uploadFile({
    required File file,
    required String folderName,
  }) async {
    final String resourceType =
        (folderName == 'audios' || folderName == 'videos') ? 'video' : 'image';
    final String fileName = file.path.split('/').last.split('\\').last;
    return uploadMedia(
      file: file,
      fileName: fileName,
      resourceType: resourceType,
    );
  }
}
