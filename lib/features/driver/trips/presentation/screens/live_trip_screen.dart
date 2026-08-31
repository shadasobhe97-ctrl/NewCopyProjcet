import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/app_theme.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import 'package:kids_transport/core/widgets/primary_button.dart';
import 'package:kids_transport/features/driver/trips/data/models/driver_trip_stop_model.dart';
import 'package:kids_transport/features/driver/trips/data/models/live_trip_child_item.dart';
import 'package:kids_transport/features/driver/trips/logic/live_trip_cubit/live_trip_cubit.dart';
import 'package:kids_transport/features/driver/trips/presentation/widgets/forgotten_children_dialog.dart';
import 'package:kids_transport/features/driver/trips/presentation/widgets/qr_scan_sheet.dart';
import 'package:kids_transport/features/driver/trips/presentation/widgets/trip_progress_bar.dart';
import 'package:kids_transport/features/driver/trips/presentation/widgets/trip_child_action_card.dart';
import 'package:kids_transport/features/driver/trips/data/models/vehicle_breakdown_model.dart';

/// شاشة الرحلة الحية: الخريطة، المحطات، الطفل الحالي، التقدّم، والإجراءات
class LiveTripScreen extends StatefulWidget {
  final int tripId;

  const LiveTripScreen({super.key, required this.tripId});

  @override
  State<LiveTripScreen> createState() => _LiveTripScreenState();
}

class _LiveTripScreenState extends State<LiveTripScreen> {
  final MapController _mapController = MapController();
  Position? _driverPosition;

  @override
  void initState() {
    super.initState();
    context.read<LiveTripCubit>().loadAll(widget.tripId);
    context.read<LiveTripCubit>().startBackgroundSync(widget.tripId);
    _listenToPosition();
  }

  Future<void> _listenToPosition() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
      ).listen((position) {
        if (mounted) setState(() => _driverPosition = position);
      });
    } catch (_) {}
  }

  double? _distanceToChild(LiveTripChildItem item) {
    if (_driverPosition == null) return null;
    if (item.targetLatitude == null || item.targetLongitude == null) return null;
    return Geolocator.distanceBetween(
      _driverPosition!.latitude,
      _driverPosition!.longitude,
      item.targetLatitude!,
      item.targetLongitude!,
    );
  }

  Future<void> _handleManualConfirm(LiveTripChildItem item) async {
    Position? pos = _driverPosition;
    if (pos == null) {
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
      } catch (_) {}
    }
    if (pos == null) {
      _showSnack(
        'يتعذر الحصول على الموقع الجغرافي الحالي لتأكيد الإجراء، يرجى تفعيل الموقع أو استخدام مسح QR.',
        isError: true,
      );
      return;
    }
    if (!mounted) return;
    final cubit = context.read<LiveTripCubit>();
    if (item.isDropoffPhase) {
      await cubit.manualDropoff(
        widget.tripId,
        item,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
    } else {
      await cubit.manualPickup(
        widget.tripId,
        item,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
    }
  }

  Future<void> _handleScanQr(LiveTripChildItem item) async {
    final token = await QrScanSheet.show(context, title: item.name);
    if (token == null || token.isEmpty || !mounted) return;
    final stage = item.isDropoffPhase ? 'dropoff' : null;
    await context.read<LiveTripCubit>().scanQr(widget.tripId, item, token, stage: stage);
  }

  Future<void> _confirmAndRunWithLocation(
    String title,
    String message,
    void Function(double lat, double lng) onConfirm,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: Text(title, textAlign: TextAlign.right),
        content: Text(message, textAlign: TextAlign.right),
        actions: [
          TextButton(onPressed: () => Navigator.of(dCtx).pop(false), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.of(dCtx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      Position? pos = _driverPosition;
      if (pos == null) {
        try {
          pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
          );
        } catch (_) {}
      }
      if (pos == null) {
        if (!mounted) return;
        _showSnack(
          'يتعذر الحصول على الموقع الجغرافي الحالي لتأكيد الإجراء، يرجى تفعيل الموقع أو استخدام مسح QR.',
          isError: true,
        );
        return;
      }
      onConfirm(pos.latitude, pos.longitude);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  Future<void> _handleComplete() async {
    await context.read<LiveTripCubit>().completeTrip(widget.tripId);
  }

  Future<void> _handleReportBreakdown() async {
    final controller = TextEditingController();
    String? errorText;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.error),
              const SizedBox(width: 8),
              const Text('إبلاغ طوارئ تعطل المركبة', textAlign: TextAlign.right),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'يرجى كتابة سبب العطل بشكل دقيق للإدارة والسائقين البدلاء قبل إرسال بلاغ الطوارئ:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                textAlign: TextAlign.right,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'مثال: عطل في المحرك وتوقف تام للمركبة في طريق الشط',
                  errorText: errorText,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) {
                  if (errorText != null) {
                    setStateDialog(() => errorText = null);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dCtx).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) {
                  setStateDialog(() => errorText = 'يرجى إدخال سبب العطل لتفعيل بلاغ الطوارئ');
                  return;
                }
                Navigator.of(dCtx).pop(true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('إرسال بلاغ الطوارئ'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || confirmed != true) return;

    final reason = controller.text.trim();

    // Get exact current GPS location at moment of breakdown report
    Position position;
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (_) {
      position = Position(
        latitude: _driverPosition?.latitude ?? 0.0,
        longitude: _driverPosition?.longitude ?? 0.0,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    }

    if (!mounted) return;
    String? currentAddress;
    final currentState = context.read<LiveTripCubit>().state;
    if (currentState is LiveTripLoaded) {
      currentAddress = currentState.currentChild?.pickupAddress ??
          currentState.stops.firstOrNull?.label;
    }

    final request = VehicleBreakdownRequestModel(
      latitude: position.latitude,
      longitude: position.longitude,
      reason: reason,
      accuracy: position.accuracy,
      speed: position.speed,
      address: currentAddress,
    );

    if (!mounted) return;
    await context.read<LiveTripCubit>().reportBreakdown(widget.tripId, request);
  }


  void _showBreakdownResultDialog(VehicleBreakdownResponseModel result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              result.isNoSubstitutes ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
              color: result.isNoSubstitutes ? AppColors.warning : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                result.isBroadcasted
                    ? 'تم بث بلاغ الطوارئ'
                    : (result.isNoSubstitutes ? 'تنبيه السائقين البدلاء' : 'نتيجة بلاغ الطوارئ'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message, style: const TextStyle(fontSize: 14)),
            if (result.strandedChildrenCount > 0) ...[
              const SizedBox(height: 10),
              Text(
                'عدد الأطفال المتأثرين بالتعطل: ${result.strandedChildrenCount}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
            if (result.isBroadcasted && result.candidatesCount > 0) ...[
              const SizedBox(height: 6),
              Text(
                'عدد السائقين المتاحين بالمنطقة: ${result.candidatesCount}',
                style: const TextStyle(fontSize: 13, color: AppColors.primary),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dCtx).pop(),
            child: const Text('حسنًا'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.backgroundSurface,
        appBar: AppBar(
          title: const Text('الرحلة الحية'),
          actions: [
            BlocBuilder<LiveTripCubit, LiveTripState>(
              builder: (context, state) {
                if (state is! LiveTripLoaded) return const SizedBox.shrink();
                if (state.isInProgress) {
                  return IconButton(
                    tooltip: 'الإبلاغ عن عطل',
                    icon: const Icon(Icons.report_problem_outlined),
                    onPressed: _handleReportBreakdown,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<LiveTripCubit, LiveTripState>(
          listenWhen: (previous, current) =>
              current is LiveTripLoaded &&
              (current.blockingErrorMessage != null ||
                  current.actionErrorMessage != null ||
                  current.isCompleted ||
                  current.breakdownResult != null),
          listener: (context, state) {
            if (state is! LiveTripLoaded) return;
            if (state.blockingErrorMessage != null) {
              final cubit = context.read<LiveTripCubit>();
              ForgottenChildrenDialog.show(
                context,
                message: state.blockingErrorMessage!,
                onGoToStops: cubit.clearBlockingError,
              ).then((_) => cubit.clearBlockingError());
            } else if (state.actionErrorMessage != null) {
              _showSnack(state.actionErrorMessage!, isError: true);
              context.read<LiveTripCubit>().clearActionError();
            } else if (state.breakdownResult != null) {
              _showBreakdownResultDialog(state.breakdownResult!);
            } else if (state.isCompleted && state.completedSummary != null) {
              _showCompletionDialog(state);
            }
          },
          builder: (context, state) {
            if (state is LiveTripLoading || state is LiveTripInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is LiveTripError) {
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
                        onPressed: () => context.read<LiveTripCubit>().loadAll(widget.tripId),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final loaded = state as LiveTripLoaded;
            return Column(
              children: [
                SizedBox(height: 220, child: _buildMap(loaded.stops)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TripProgressBar(
                    completed: loaded.progress.completed,
                    total: loaded.progress.total,
                  ),
                ),
                if (loaded.isSuspended) _buildSuspendedBanner(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: loaded.childItems.length,
                    itemBuilder: (context, index) {
                      final item = loaded.childItems[index];
                      final isCurrent = loaded.currentChild?.tripChildId == item.tripChildId;
                      return TripChildActionCard(
                        item: item,
                        isCurrent: isCurrent,
                        isPendingAction: loaded.pendingActionTripChildId == item.tripChildId,
                        distanceMeters: _distanceToChild(item),
                        onManualConfirm: loaded.isSuspended ? () {} : () => _handleManualConfirm(item),
                        onScanQr: loaded.isSuspended ? () {} : () => _handleScanQr(item),
                        onAbsent: loaded.isSuspended
                            ? () {}
                            : () => _confirmAndRunWithLocation(
                                  'تأكيد الغياب',
                                  'هل تؤكد أن ${item.name} غير موجود في هذه المحطة؟',
                                  (lat, lng) => context.read<LiveTripCubit>().markAbsent(
                                        widget.tripId,
                                        item,
                                        latitude: lat,
                                        longitude: lng,
                                      ),
                                ),
                        onSkip: loaded.isSuspended
                            ? () {}
                            : () => context.read<LiveTripCubit>().skipChild(widget.tripId, item),
                        onDropoffFailed: loaded.isSuspended
                            ? () {}
                            : () => _confirmAndRunWithLocation(
                                  'تعذر التسليم',
                                  'سيتم تسجيل هذه المحطة كحالة تعذر تسليم. هل أنت متأكد؟',
                                  (lat, lng) => context.read<LiveTripCubit>().markDropoffFailed(
                                        widget.tripId,
                                        item,
                                        latitude: lat,
                                        longitude: lng,
                                      ),
                                ),
                        onDirectParentHandling: loaded.isSuspended
                            ? () {}
                            : () => _confirmAndRunWithLocation(
                                  'تسليم مباشر لولي الأمر',
                                  'سيتم تسجيل استلام ولي الأمر للطفل مباشرة. هل أنت متأكد؟',
                                  (lat, lng) => context.read<LiveTripCubit>().markDirectParentHandling(
                                        widget.tripId,
                                        item,
                                        latitude: lat,
                                        longitude: lng,
                                      ),
                                ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: loaded.isSuspended
                      ? PrimaryButton(
                          label: 'استئناف الرحلة',
                          icon: Icons.play_circle_outline_rounded,
                          width: double.infinity,
                          onPressed: () => context.read<LiveTripCubit>().resumeTrip(widget.tripId),
                        )
                      : PrimaryButton(
                          label: 'إنهاء الرحلة',
                          icon: Icons.flag_circle_rounded,
                          backgroundColor: loaded.canComplete ? AppColors.success : AppColors.grey400,
                          width: double.infinity,
                          onPressed: _handleComplete,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuspendedBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.boxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: AppTheme.radius(12),
        border: AppTheme.border(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.report_problem_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'الرحلة متوقفة مؤقتاً (عطل) — استأنفها للاستمرار في الإجراءات.',
              style: AppTextStyles.style(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(List<DriverTripStopModel> stops) {
    final driverLatLng = _driverPosition != null
        ? LatLng(_driverPosition!.latitude, _driverPosition!.longitude)
        : (stops.isNotEmpty ? LatLng(stops.first.latitude, stops.first.longitude) : const LatLng(0, 0));

    final markers = <Marker>[
      if (_driverPosition != null)
        Marker(
          point: driverLatLng,
          width: 46,
          height: 46,
          child: Container(
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.directions_bus_filled_rounded, color: AppColors.white, size: 22),
          ),
        ),
      ...stops.map(
        (stop) => Marker(
          point: LatLng(stop.latitude, stop.longitude),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: stop.isResolved ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 2),
            ),
            child: Icon(
              stop.isSchool ? Icons.school_rounded : Icons.home_rounded,
              color: AppColors.white,
              size: 16,
            ),
          ),
        ),
      ),
    ];

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: driverLatLng, initialZoom: 14),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.kids_transport.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: stops.map((s) => LatLng(s.latitude, s.longitude)).toList(),
              strokeWidth: 4,
              color: AppColors.primaryLight,
            ),
          ],
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  void _showCompletionDialog(LiveTripLoaded state) {
    final summary = state.completedSummary!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) => AlertDialog(
        shape: AppTheme.roundedRectangleBorder(borderRadius: AppTheme.radius(16)),
        title: const Row(
          children: [
            Icon(Icons.celebration_rounded, color: AppColors.success),
            SizedBox(width: 8),
            Text('تم إنهاء الرحلة بنجاح'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SummaryRow(label: 'عدد الأطفال', value: '${summary.children}'),
            _SummaryRow(label: 'تم اصطحابهم', value: '${summary.pickedUp}'),
            _SummaryRow(label: 'تم تسليمهم', value: '${summary.droppedOff}'),
            _SummaryRow(label: 'الغياب', value: '${summary.absent}'),
            _SummaryRow(label: 'المدة', value: '${summary.duration} دقيقة'),
            _SummaryRow(label: 'المسافة', value: '${summary.distance.toStringAsFixed(1)} كم'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dCtx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.style(fontSize: 13, color: AppColors.textMuted)),
          Text(value, style: AppTextStyles.style(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
