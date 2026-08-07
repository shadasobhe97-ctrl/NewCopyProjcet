import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_history_model.dart';
import 'package:kids_transport/features/driver/trips/logic/driver_trips_history_cubit/driver_trips_history_cubit.dart';
import 'package:kids_transport/features/driver/trips/presentation/widgets/trip_child_status_badge.dart';
import 'package:kids_transport/features/driver/trips/presentation/widgets/trip_status_badge.dart';

/// شاشة تفاصيل رحلة من السجل
class TripHistoryDetailsScreen extends StatefulWidget {
  final int tripId;

  const TripHistoryDetailsScreen({super.key, required this.tripId});

  @override
  State<TripHistoryDetailsScreen> createState() => _TripHistoryDetailsScreenState();
}

class _TripHistoryDetailsScreenState extends State<TripHistoryDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DriverTripsHistoryCubit>().loadHistoryDetails(widget.tripId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(title: const Text('تفاصيل الرحلة')),
        body: BlocBuilder<DriverTripsHistoryCubit, DriverTripsHistoryState>(
          builder: (context, state) {
            if (state is DriverTripHistoryDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DriverTripHistoryDetailsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 50, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: AppTextStyles.style(fontSize: 14, color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is DriverTripHistoryDetailsLoaded) {
              final details = state.details;
              final isDark = context.isDarkMode;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.boxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.white,
                        borderRadius: AppTheme.radius(16),
                        border: AppTheme.border(
                          color: isDark ? AppColors.grey800 : AppColors.grey.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  details.routeName.isNotEmpty
                                      ? details.routeName
                                      : 'رحلة #${details.tripId}',
                                  style: AppTextStyles.style(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              TripStatusBadge(status: details.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${details.tripDate} • ${details.duration} دقيقة',
                            style: AppTextStyles.style(fontSize: 13, color: context.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'الأطفال (${details.children.length})',
                      style: AppTextStyles.style(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    if (details.children.isEmpty)
                      Text(
                        'لا تتوفر بيانات أطفال لهذه الرحلة.',
                        style: AppTextStyles.style(fontSize: 13, color: context.textMuted),
                      ),
                    ...details.children.map((child) => _ChildHistoryTile(child: child)),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ChildHistoryTile extends StatelessWidget {
  final TripHistoryChildModel child;

  const _ChildHistoryTile({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.boxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppTheme.radius(12),
        border: AppTheme.border(
          color: isDark ? AppColors.grey800 : AppColors.grey.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.childName,
                      style: AppTextStyles.style(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    if (child.school.isNotEmpty)
                      Text(
                        child.school,
                        style: AppTextStyles.style(fontSize: 12, color: context.textMuted),
                      ),
                  ],
                ),
              ),
              if (child.status.isNotEmpty) TripChildStatusBadge(status: child.status, compact: true),
            ],
          ),
          if (child.pickupAddress.isNotEmpty || child.scannedPickupAt != null) ...[
            const SizedBox(height: 8),
            _EventRow(
              icon: Icons.home_rounded,
              label: child.pickupAddress.isNotEmpty ? child.pickupAddress : 'الاصطحاب',
              time: child.pickupTime ?? child.scannedPickupAt,
            ),
          ],
          if (child.dropoffAddress.isNotEmpty || child.scannedDropoffAt != null) ...[
            const SizedBox(height: 4),
            _EventRow(
              icon: Icons.school_rounded,
              label: child.dropoffAddress.isNotEmpty ? child.dropoffAddress : 'التسليم',
              time: child.dropoffTime ?? child.scannedDropoffAt,
            ),
          ],
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? time;

  const _EventRow({required this.icon, required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.style(fontSize: 12, color: context.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (time != null)
          Text(
            time!,
            style: AppTextStyles.style(fontSize: 11, fontWeight: FontWeight.w600),
          ),
      ],
    );
  }
}
