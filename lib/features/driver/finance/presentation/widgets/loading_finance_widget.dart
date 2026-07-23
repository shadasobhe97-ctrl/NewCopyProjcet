import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/utils/theme_context.dart';

class LoadingFinanceWidget extends StatelessWidget {
  final int itemCount;

  const LoadingFinanceWidget({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AppTheme.boxDecoration(
            color: context.cardSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
            ),
          ),
        );
      },
    );
  }
}
