import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_blur_detection/image_blur_detection.dart';
import 'package:image_picker/image_picker.dart';

class ImageQualityCheckResult {
  final bool isValid;
  final List<String> issues;
  final String? errorMessage;

  const ImageQualityCheckResult({
    required this.isValid,
    this.issues = const [],
    this.errorMessage,
  });
}

class ImageQualityService {
  static final ImageQualityValidator _validator = ImageQualityValidator(
    config: QualityConfig.documentScanning,
  );

  /// يفحص جودة الصورة المحددة ويرجع نتيجة تفصيلية مترجمة للعربية.
  static Future<ImageQualityCheckResult> validateImage(XFile imageFile) async {
    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      if (bytes.isEmpty) {
        return const ImageQualityCheckResult(
          isValid: false,
          issues: ['جودة الصورة ضعيفة'],
          errorMessage: 'جودة الصورة ضعيفة',
        );
      }

      final QualityResult result = await _validator.validate(bytes);

      if (result.isValid) {
        return const ImageQualityCheckResult(isValid: true);
      }

      final List<String> arabicIssues = [];

      for (final issue in result.issues) {
        final issueStr = issue.toString().toLowerCase();
        if (issueStr.contains('blur')) {
          if (!arabicIssues.contains('الصورة غير واضحة')) {
            arabicIssues.add('الصورة غير واضحة');
          }
        } else if (issueStr.contains('dark') || issueStr.contains('underexposed')) {
          if (!arabicIssues.contains('الصورة مظلمة')) {
            arabicIssues.add('الصورة مظلمة');
          }
        } else if (issueStr.contains('bright') || issueStr.contains('overexposed')) {
          if (!arabicIssues.contains('الصورة ساطعة جداً')) {
            arabicIssues.add('الصورة ساطعة جداً');
          }
        } else {
          if (!arabicIssues.contains('جودة الصورة ضعيفة')) {
            arabicIssues.add('جودة الصورة ضعيفة');
          }
        }
      }

      if (arabicIssues.isEmpty) {
        arabicIssues.add('جودة الصورة ضعيفة');
      }

      final String mainError = arabicIssues.first;

      return ImageQualityCheckResult(
        isValid: false,
        issues: arabicIssues,
        errorMessage: mainError,
      );
    } catch (e) {
      debugPrint('خطأ في فحص جودة الصورة: $e');
      // عند الانقطاع أو استثناء غير متوقع، نمنع الـ crash ونعامل الصورة بحذر أو نسمح بالاستمرار بدون crash
      return const ImageQualityCheckResult(
        isValid: true,
      );
    }
  }
}
