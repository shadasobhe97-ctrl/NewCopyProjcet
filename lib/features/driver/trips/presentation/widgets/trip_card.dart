import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/primary_button.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_model.dart';
import 'package:kids_transport/features/driver/trips/presentation/widgets/trip_status_badge.dart';

/// بطاقة رحلة في قائمة "رحلات اليوم"
class TripCard extends StatelessWidget {
  final DriverTripModel trip;
  final bool isStarting;
  final VoidCallback onDetails;
  final VoidCallback onStart;
  final VoidCallback onLive;

  const TripCard({
    super.key,
    required this.trip,
    required this.isStarting,
    required this.onDetails,
    required this.onStart,
    required this.onLive,
  });

  String get _tripTypeLabel => trip.tripType == 'Morning' ? 'صباحي' : 'مسائي';

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppTheme.radius(18),
        border: AppTheme.border(
          color: isDark ? AppColors.grey800 : AppColors.grey.withValues(alpha: 0.15),
        ),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  trip.routeName.isNotEmpty ? trip.routeName : _tripTypeLabel,
                  style: AppTextStyles.style(fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TripStatusBadge(status: trip.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(icon: Icons.child_care_rounded, label: '${trip.childrenCount} طفل'),
              const SizedBox(width: 8),
              _InfoChip(icon: Icons.school_rounded, label: '${trip.schoolsCount} مدرسة'),
              const SizedBox(width: 8),
              _InfoChip(icon: Icons.timelapse_rounded, label: '${trip.estimatedDuration} د'),
            ],
          ),
          if (trip.recommendedDeparture != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 14, color: context.textMuted),
                const SizedBox(width: 6),
                Text(
                  'الانطلاق المقترح: ${trip.recommendedDeparture}',
                  style: AppTextStyles.style(fontSize: 12, color: context.textMuted),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDetails,
                  style: AppTheme.outlinedButtonStyle(
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('التفاصيل'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: trip.isPending
                    ? PrimaryButton(
                        label: 'بدء الرحلة',
                        icon: Icons.play_arrow_rounded,
                        isLoading: isStarting,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        borderRadius: 10,
                        onPressed: onStart,
                      )
                    : PrimaryButton(
                        label: trip.isInProgress || trip.isSuspended ? 'الرحلة الحية' : 'مكتملة',
                        icon: Icons.navigation_rounded,
                        backgroundColor:
                            trip.isCompleted ? AppColors.grey400 : AppColors.primaryLight,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        borderRadius: 10,
                        onPressed: trip.isCompleted ? null : onLive,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: AppTheme.boxDecoration(
        color: AppColors.grey.withValues(alpha: 0.08),
        borderRadius: AppTheme.radius(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: context.textMuted),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.style(fontSize: 11, color: context.textMuted)),
        ],
      ),
    );
  }
}
