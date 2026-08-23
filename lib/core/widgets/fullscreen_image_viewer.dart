import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/widgets/app_image_widget.dart';

class FullscreenImageViewer extends StatelessWidget {
  final String? imageUrl;
  final dynamic imageFile;
  final String title;

  const FullscreenImageViewer({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.title = 'معاينة الصورة',
  }) : assert(
         imageUrl != null || imageFile != null,
         'Must provide imageUrl or imageFile',
       );

  static void show(
    BuildContext context, {
    String? imageUrl,
    dynamic imageFile,
    String title = 'معاينة الصورة',
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenImageViewer(
          imageUrl: imageUrl,
          imageFile: imageFile,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: AppTextStyles.style(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: imageUrl ?? imageFile?.toString() ?? 'fullscreen_image',
            child: AppImageWidget(
              image: imageFile ?? imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
