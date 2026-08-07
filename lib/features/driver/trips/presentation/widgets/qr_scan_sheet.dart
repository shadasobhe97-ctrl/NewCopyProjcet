import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// شاشة مسح رمز QR الخاص بالطفل — تُرجع الكود الممسوح عبر Navigator.pop
class QrScanSheet extends StatefulWidget {
  final String title;

  const QrScanSheet({super.key, required this.title});

  static Future<String?> show(BuildContext context, {required String title}) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => QrScanSheet(title: title)),
    );
  }

  @override
  State<QrScanSheet> createState() => _QrScanSheetState();
}

class _QrScanSheetState extends State<QrScanSheet> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;
    _handled = true;
    Navigator.of(context).pop(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
          title: Text(widget.title, style: AppTextStyles.style(color: AppColors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.flash_on_rounded),
              onPressed: () => _controller.toggleTorch(),
            ),
          ],
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            MobileScanner(controller: _controller, onDetect: _onDetect),
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.white, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            Positioned(
              bottom: 40,
              child: Text(
                'وجّه الكاميرا نحو رمز QR الخاص بالطفل',
                style: AppTextStyles.style(color: AppColors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
