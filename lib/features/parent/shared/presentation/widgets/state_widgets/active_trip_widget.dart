import 'package:flutter/material.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/features/parent/trips/data/models/active_trip_model.dart';

class ActiveTripWidget extends StatelessWidget {
  final List<Map<String, dynamic>> todayTrips;
  final Map<String, dynamic>? activeTrip;

  const ActiveTripWidget({
    super.key,
    required this.todayTrips,
    this.activeTrip,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ─── كرت الرحلة الجارية ──────────────────────────────────────
        if (activeTrip != null) ...[
          _buildActiveTripCard(activeTrip!, context),
          const SizedBox(height: 20),
        ],

        // ─── جدول رحلات اليوم ────────────────────────────────────────
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: AppTheme.boxDecoration(
                color: context.primaryColor.withValues(alpha: 0.1),
                borderRadius: AppTheme.radius(9),
              ),
              child: Icon(
                Icons.directions_bus_rounded,
                color: context.primaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "جدول رحلات اليوم",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...todayTrips.map((trip) => _buildTripCard(context, trip)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActiveTripCard(
    Map<String, dynamic> activeTrip,
    BuildContext context,
  ) {
    return Container(
      decoration: AppTheme.boxDecoration(
        gradient: AppTheme.linearGradient(
          colors: [context.successColor, AppColors.successDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: AppTheme.radius(20),
        boxShadow: [
          AppTheme.boxShadow(
            color: context.successColor.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // هيدر الكرت
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // مؤشر الحياة
                Row(
                  children: [
                    SizedBox(
                      width: 10,
                      height: 10,
                      child: DecoratedBox(
                        decoration: AppTheme.boxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "رحلة جارية الآن",
                      style: AppTextStyles.style(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                // زر التتبع
                ElevatedButton.icon(
                  onPressed: () {
                    final tripModel = ActiveTripModel(
                      tripId: activeTrip['trip_id'] as int? ?? 1,
                      tripType: activeTrip['trip_type']?.toString() ?? 'to_school',
                      status: activeTrip['status']?.toString() ?? 'started',
                      driverName: activeTrip['driver_name']?.toString() ?? 'سائق',
                      driverPhone: activeTrip['driver_phone']?.toString() ?? '0910000000',
                      vehicleInfo: activeTrip['vehicle_info']?.toString() ?? 'سيارة',
                      childId: activeTrip['child_id'] as int? ?? 1,
                      childName: activeTrip['child_name']?.toString() ?? 'الطفل',
                      childStatus: activeTrip['status']?.toString() ?? 'في الطريق',
                      startedAt: DateTime.now().toIso8601String(),
                    );
                    Navigator.pushNamed(
                      context,
                      AppRoutes.parentTripTracking,
                      arguments: tripModel,
                    );
                  },
                  icon: Icon(
                    Icons.map_rounded,
                    size: 16,
                    color: context.successColor,
                  ),
                  label: Text(
                    "تتبع",
                    style: AppTextStyles.style(
                      color: context.successColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  style: AppTheme.elevatedButtonStyle(
                    backgroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: AppTheme.roundedRectangleBorder(
                      borderRadius: AppTheme.radius(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.white.withValues(alpha: 0.25), height: 1),
          // تفاصيل الرحلة
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeTrip['child_name'] ?? '',
                  style: AppTextStyles.style(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.person_pin_circle_rounded,
                      color: AppColors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        "${activeTrip['status']} مع الكابتن ${activeTrip['driver_name']}",
                        style: AppTextStyles.style(
                          color: AppColors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Map<String, dynamic> trip) {
    final isDone = trip['status'] == 'تم الاستلام';
    final statusColor = isDone ? context.successColor : context.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.boxDecoration(
        color: context.cardSurface,
        borderRadius: AppTheme.radius(16),
        boxShadow: [
          AppTheme.boxShadow(
            color: AppColors.black.withValues(
              alpha: context.isDarkMode ? 0.2 : 0.05,
            ),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: AppTheme.boxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone
                  ? Icons.check_circle_rounded
                  : Icons.directions_bus_filled_rounded,
              color: statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip['name'] ?? '',
                  style: AppTextStyles.style(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "وقت التحرك: ${trip['time']}",
                  style: AppTextStyles.style(fontSize: 12, color: context.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: AppTheme.boxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: AppTheme.radius(10),
            ),
            child: Text(
              trip['status'] ?? '',
              style: AppTextStyles.style(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
