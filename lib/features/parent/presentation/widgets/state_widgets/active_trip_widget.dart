import 'package:flutter/material.dart';
import 'package:kids_transport/core/theme/app_colors.dart';

class ActiveTripWidget extends StatelessWidget {
  final List<Map<String, dynamic>> todayTrips;
  final Map<String, dynamic>? activeTrip;

  const ActiveTripWidget(
      {super.key, required this.todayTrips, this.activeTrip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.directions_bus_rounded,
                  color: AppColors.primaryLight, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              "جدول رحلات اليوم",
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...todayTrips.map((trip) => _buildTripCard(trip, isDark)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActiveTripCard(
      Map<String, dynamic> activeTrip, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.success, Color(0xFF16A34A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.35),
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
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "رحلة جارية الآن",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                // زر التتبع
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: فتح خريطة التتبع
                  },
                  icon: const Icon(Icons.map_rounded,
                      size: 16, color: AppColors.success),
                  label: const Text(
                    "تتبع",
                    style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.25), height: 1),
          // تفاصيل الرحلة
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeTrip['child_name'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_pin_circle_rounded,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        "${activeTrip['status']} مع الكابتن ${activeTrip['driver_name']}",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
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

  Widget _buildTripCard(Map<String, dynamic> trip, bool isDark) {
    final isDone = trip['status'] == 'تم الاستلام';
    final statusColor = isDone ? AppColors.success : AppColors.primaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
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
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
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
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  "وقت التحرك: ${trip['time']}",
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              trip['status'] ?? '',
              style: TextStyle(
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