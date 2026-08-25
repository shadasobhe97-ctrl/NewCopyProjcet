import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kids_transport/core/network/api_endpoints.dart';

class AppImageWidget extends StatelessWidget {
  final dynamic image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  static final Map<String, Uint8List> _networkImageCache = {};
  static final Map<String, Future<Uint8List?>> _inFlightRequests = {};
  static final Dio _sharedDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  const AppImageWidget({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  Future<Uint8List?> _loadNetworkImageBytes(String url) {
    if (_networkImageCache.containsKey(url)) {
      return Future.value(_networkImageCache[url]);
    }
    if (_inFlightRequests.containsKey(url)) {
      return _inFlightRequests[url]!;
    }

    final future = _fetchBytesWithRetry(url);
    _inFlightRequests[url] = future;
    return future;
  }

  Future<Uint8List?> _fetchBytesWithRetry(String url) async {
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await _sharedDio.get<List<int>>(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            headers: const {
              'Accept': 'image/*, */*',
              'bypass-tunnel-reminder': 'true',
            },
          ),
        );

        if (response.statusCode == 200 && response.data != null) {
          final bytes = Uint8List.fromList(response.data!);
          _networkImageCache[url] = bytes;
          _inFlightRequests.remove(url);
          debugPrint('✅ [AppImageWidget] Successfully fetched image bytes: $url (${bytes.length} bytes)');
          return bytes;
        }
      } catch (e) {
        debugPrint('⚠️ [AppImageWidget] Attempt $attempt failed for $url: $e');
        if (attempt == 0) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    }
    _inFlightRequests.remove(url);
    return null;
  }

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

      if (_networkImageCache.containsKey(resolvedUrl)) {
        return Image.memory(
          _networkImageCache[resolvedUrl]!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) =>
              errorWidget ?? _defaultErrorWidget(),
        );
      }

      return FutureBuilder<Uint8List?>(
        future: _loadNetworkImageBytes(resolvedUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData &&
              snapshot.data != null) {
            return Image.memory(
              snapshot.data!,
              width: width,
              height: height,
              fit: fit,
              errorBuilder: (ctx, err, stack) =>
                  errorWidget ?? _defaultErrorWidget(),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return placeholder ??
                Container(
                  width: width,
                  height: height,
                  color: Colors.grey[200],
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
          }

          // Fallback to standard Image.network
          return Image.network(
            resolvedUrl,
            width: width,
            height: height,
            fit: fit,
            headers: kIsWeb ? null : const {'bypass-tunnel-reminder': 'true'},
            errorBuilder: (ctx, err, stack) {
              debugPrint('❌ [AppImageWidget] FAILED loading image: "$resolvedUrl" | Error: $err');
              return errorWidget ?? _defaultErrorWidget();
            },
          );
        },
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

    final serverHost =
        ApiEndpoints.baseUrl.replaceAll(RegExp(r'/?api/?$'), '');
    final isHttpsBase = ApiEndpoints.baseUrl.startsWith('https://');

    String resolved = raw;

    if (raw.startsWith('http://localhost') || raw.startsWith('http://127.0.0.1')) {
      final uri = Uri.parse(raw);
      resolved = '$serverHost${uri.path}';
    } else if (raw.startsWith('https://api.example.com')) {
      final uri = Uri.parse(raw);
      resolved = '$serverHost${uri.path}';
    } else if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      final cleanPath = raw.startsWith('/') ? raw : '/$raw';
      resolved = '$serverHost$cleanPath';
    }

    // إذا كان السيرفر يستعمل https، نحول رابط الصورة من http إلى https لتفادي منع المتصفح (Mixed Content Block)
    if (isHttpsBase && resolved.startsWith('http://')) {
      resolved = 'https://${resolved.substring(7)}';
    }

    return resolved;
  }
}
