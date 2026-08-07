import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';

/// Dialog حاجز يمنع إنهاء الرحلة عند وجود أطفال لم تُحسم حالتهم (FORGOTTEN_CHILDREN_ON_BUS)
class ForgottenChildrenDialog extends StatelessWidget {
  final String message;
  final VoidCallback onGoToStops;

  const ForgottenChildrenDialog({
    super.key,
    required this.message,
    required this.onGoToStops,
  });

  static Future<void> show(
    BuildContext context, {
    required String message,
    required VoidCallback onGoToStops,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ForgottenChildrenDialog(message: message, onGoToStops: onGoToStops),
    );
  }

  List<String> get _names {
    final match = RegExp(r'\(([^)]+)\)').firstMatch(message);
    if (match == null) return const [];
    return match
        .group(1)!
        .split(RegExp('[،,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final names = _names;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: AppTheme.roundedRectangleBorder(borderRadius: AppTheme.radius(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 26),
            const SizedBox(width: 8),
            const Text('لا يمكن إنهاء الرحلة'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              names.isNotEmpty
                  ? 'يوجد أطفال لم تُحسم حالتهم بعد. يجب تأكيد نزولهم أو تسجيل غيابهم أولاً:'
                  : message,
              textAlign: TextAlign.right,
              style: AppTextStyles.style(fontSize: 14),
            ),
            if (names.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...names.map(
                (name) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.child_care_rounded, size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(name, style: AppTextStyles.style(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onGoToStops();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('الذهاب لمحطتهم'),
          ),
        ],
      ),
    );
  }
}
