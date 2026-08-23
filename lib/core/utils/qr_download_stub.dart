import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
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

    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(pngBytes);

    final xFile = XFile(file.path, mimeType: 'image/png', name: fileName);
    await Share.shareXFiles(
      [xFile],
      text: 'بطاقة صعود دربي الخاصة بـ $childName',
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('حدث خطأ أثناء حفظ الصورة: $e'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
