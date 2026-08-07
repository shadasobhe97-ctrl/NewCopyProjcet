import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_history_model.dart';
import 'package:kids_transport/features/driver/trips/presentation/widgets/trip_status_badge.dart';

/// بطاقة رحلة في سجل الرحلات
class TripHistoryCard extends StatelessWidget {
  final DriverTripHistoryModel trip;
  final VoidCallback onTap;

  const TripHistoryCard({super.key, required this.trip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: AppTheme.radius(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.boxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: AppTheme.radius(16),
          border: AppTheme.border(
            color: isDark ? AppColors.grey800 : AppColors.grey.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: AppTheme.boxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_rounded, color: AppColors.primaryLight, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.routeName.isNotEmpty ? trip.routeName : 'رحلة #${trip.tripId}',
                    style: AppTextStyles.style(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${trip.tripDate} • ${trip.duration} دقيقة',
                    style: AppTextStyles.style(fontSize: 12, color: context.textMuted),
                  ),
                ],
              ),
            ),
            TripStatusBadge(status: trip.status),
          ],
        ),
      ),
    );
  }
}
