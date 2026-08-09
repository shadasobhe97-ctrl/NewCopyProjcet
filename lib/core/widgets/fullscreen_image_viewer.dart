import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

class FullscreenImageViewer extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
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
    File? imageFile,
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
            tag: imageUrl ?? imageFile?.path ?? 'fullscreen_image',
            child: imageFile != null
                ? Image.file(imageFile!, fit: BoxFit.contain)
                : Image.network(
                    imageUrl!,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: AppColors.primaryLight,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.broken_image_rounded,
                          size: 64,
                          color: Colors.white54,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'تعذر تحميل الصورة',
                          style: AppTextStyles.style(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
