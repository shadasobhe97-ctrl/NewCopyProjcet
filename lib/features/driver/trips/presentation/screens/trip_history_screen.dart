import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/empty_state_placeholder.dart';
import 'package:kids_transport/features/driver/trips/logic/driver_trips_history_cubit/driver_trips_history_cubit.dart';
import 'package:kids_transport/features/driver/trips/presentation/widgets/trip_history_card.dart';

/// شاشة سجل الرحلات
class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DriverTripsHistoryCubit>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(title: const Text('سجل الرحلات')),
        body: BlocBuilder<DriverTripsHistoryCubit, DriverTripsHistoryState>(
          builder: (context, state) {
            if (state is DriverTripsHistoryLoading || state is DriverTripsHistoryInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is DriverTripsHistoryError) {
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
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.read<DriverTripsHistoryCubit>().loadHistory(),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final trips = state is DriverTripsHistoryLoaded ? state.trips : const [];
            if (trips.isEmpty) {
              return const EmptyStatePlaceholder(
                icon: Icons.history_rounded,
                title: 'لا يوجد سجل رحلات',
                subtitle: 'ستظهر هنا رحلاتك المكتملة سابقاً.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: trips.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final trip = trips[index];
                return TripHistoryCard(
                  trip: trip,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.driverTripHistoryDetails,
                    arguments: trip.tripId,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
