import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kids_transport/core/network/api_exception.dart';
import 'package:kids_transport/core/routes/app_router.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/widgets/empty_state_placeholder.dart';
import 'package:kids_transport/features/driver/trips/logic/driver_trips_cubit/driver_trips_cubit.dart';
import 'package:kids_transport/features/driver/trips/presentation/widgets/trip_card.dart';

/// شاشة "رحلاتي اليوم" — التبويب الرئيسي للرحلات في تطبيق السائق
class DriverTripsScreen extends StatefulWidget {
  const DriverTripsScreen({super.key});

  @override
  State<DriverTripsScreen> createState() => _DriverTripsScreenState();
}

class _DriverTripsScreenState extends State<DriverTripsScreen> {
  int? _startingTripId;

  @override
  void initState() {
    super.initState();
    context.read<DriverTripsCubit>().loadTripsToday();
  }

  Future<void> _startTrip(int tripId) async {
    setState(() => _startingTripId = tripId);
    try {
      final position = await _capturePosition();
      if (!mounted) return;
      final startedTripId = await context.read<DriverTripsCubit>().startTrip(
            tripId,
            latitude: position?.latitude,
            longitude: position?.longitude,
          );
      if (!mounted) return;
      await Navigator.pushNamed(
        context,
        AppRoutes.driverLiveTrip,
        arguments: startedTripId,
      );
      if (mounted) context.read<DriverTripsCubit>().refresh();
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : 'فشل بدء الرحلة: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _startingTripId = null);
    }
  }

  Future<Position?> _capturePosition() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverTripsCubit, DriverTripsState>(
      buildWhen: (previous, current) =>
          current is DriverTripsLoading ||
          current is DriverTripsInitial ||
          current is DriverTripsLoaded ||
          current is DriverTripsError,
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => context.read<DriverTripsCubit>().refresh(),
          child: Builder(
            builder: (_) {
              if (state is DriverTripsLoading || state is DriverTripsInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is DriverTripsError) {
                return _ErrorView(
                  message: state.message,
                  onRetry: () => context.read<DriverTripsCubit>().loadTripsToday(),
                );
              }

              final trips = state is DriverTripsLoaded ? state.trips : const [];

              if (trips.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 500,
                    child: EmptyStatePlaceholder(
                      icon: Icons.event_available_rounded,
                      title: 'لا توجد رحلات اليوم',
                      subtitle: 'ستظهر هنا رحلاتك بمجرد توليدها من النظام.',
                    ),
                  ),
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: TripCard(
                      trip: trip,
                      isStarting: _startingTripId == trip.tripId,
                      onDetails: () => Navigator.pushNamed(
                        context,
                        AppRoutes.driverTripDetails,
                        arguments: trip.tripId,
                      ),
                      onStart: () => _startTrip(trip.tripId),
                      onLive: () => Navigator.pushNamed(
                        context,
                        AppRoutes.driverLiveTrip,
                        arguments: trip.tripId,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 50, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.style(fontSize: 14, color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
