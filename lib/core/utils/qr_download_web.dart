import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_colors.dart';

Future<void> saveOrDownloadQr({
  required String qrData,
  required String childName,
  required BuildContext context,
}) async {
  try {
    final painter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: true,
    );

    final ui.Image image = await painter.toImage(600);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('فشل في تحويل الرمز إلى صورة.');
    }

    final Uint8List pngBytes = byteData.buffer.asUint8List();
    final cleanName = childName.replaceAll(' ', '_');
    final fileName = 'darbi_qr_$cleanName.png';

    final blob = html.Blob([pngBytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تنزيل بطاقة الـ QR بنجاح في المتصفح ⬇️'),
        backgroundColor: AppColors.success,
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('حدث خطأ أثناء تنزيل الصورة: $e'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
