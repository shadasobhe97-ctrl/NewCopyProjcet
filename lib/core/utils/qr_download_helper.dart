import 'package:flutter/material.dart';
import 'qr_download_stub.dart'
    if (dart.library.html) 'qr_download_web.dart';

abstract class QrDownloadHelper {
  static Future<void> downloadOrShareQr({
    required String qrData,
    required String childName,
    required BuildContext context,
  }) {
    return saveOrDownloadQr(
      qrData: qrData,
      childName: childName,
      context: context,
    );
  }
}
