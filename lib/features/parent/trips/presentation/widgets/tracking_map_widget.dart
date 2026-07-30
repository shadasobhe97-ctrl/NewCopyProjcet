import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/utils/theme_context.dart';
import '../../data/models/active_trip_model.dart';
import '../../data/models/trip_track_model.dart';

class TrackingMapWidget extends StatefulWidget {
  final MapController mapController;
  final bool isMultiMode;
  final LiveTrackingModel? singleTrack;
  final ActiveTripModel? singleTrip;
  final List<LiveTrackingModel> multiTracks;
  final List<ActiveTripModel> multiTrips;
  final Function(int tripId)? onSelectTrip;

  const TrackingMapWidget({
    super.key,
    required this.mapController,
    required this.isMultiMode,
    this.singleTrack,
    this.singleTrip,
    this.multiTracks = const [],
    this.multiTrips = const [],
    this.onSelectTrip,
  });

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  static const LatLng defaultLocation = LatLng(32.8872, 13.1913); // Tripoli fallback

  final List<Color> _polylineColors = const [
    AppColors.primaryLight,
    AppColors.amber,
    AppColors.accentPurple,
    AppColors.green,
    AppColors.femalePink,
  ];

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _zoomIn() {
    final currentZoom = widget.mapController.camera.zoom;
    widget.mapController.move(widget.mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = widget.mapController.camera.zoom;
    widget.mapController.move(widget.mapController.camera.center, currentZoom - 1);
  }

  void _centerDriver() {
    if (!widget.isMultiMode && widget.singleTrack != null) {
      widget.mapController.move(
        LatLng(widget.singleTrack!.driverLat, widget.singleTrack!.driverLng),
        15.0,
      );
    } else if (widget.multiTracks.isNotEmpty) {
      widget.mapController.move(
        LatLng(widget.multiTracks.first.driverLat, widget.multiTracks.first.driverLng),
        13.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = [];
    List<Polyline> polylines = [];
    LatLng initialCenter = defaultLocation;

    if (!widget.isMultiMode && widget.singleTrack != null) {
      final driverLatLng = LatLng(widget.singleTrack!.driverLat, widget.singleTrack!.driverLng);
      initialCenter = driverLatLng;

      // Driver marker
      markers.add(
        Marker(
          point: driverLatLng,
          width: 50.r,
          height: 50.r,
          child: _buildBusMarker(context, AppColors.primaryLight, widget.singleTrip?.driverName ?? 'السائق'),
        ),
      );

      // Destination marker
      if (widget.singleTrip != null) {
        final destLatLng = LatLng(widget.singleTrip!.destination.lat, widget.singleTrip!.destination.lng);
        markers.add(
          Marker(
            point: destLatLng,
            width: 44.r,
            height: 44.r,
            child: _buildDestinationMarker(
              context,
              widget.singleTrip!.destination.type == 'home' ? Icons.home_rounded : Icons.school_rounded,
              widget.singleTrip!.destination.name,
            ),
          ),
        );

        // Polyline connecting driver to destination
        polylines.add(
          Polyline(
            points: [driverLatLng, destLatLng],
            strokeWidth: 4.5,
            color: context.primaryColor,
          ),
        );
      }
    } else if (widget.isMultiMode && widget.multiTracks.isNotEmpty) {
      initialCenter = LatLng(widget.multiTracks.first.driverLat, widget.multiTracks.first.driverLng);

      for (int i = 0; i < widget.multiTracks.length; i++) {
        final track = widget.multiTracks[i];
        final color = _polylineColors[i % _polylineColors.length];
        final driverLatLng = LatLng(track.driverLat, track.driverLng);

        ActiveTripModel? tripMatch;
        try {
          tripMatch = widget.multiTrips.firstWhere((t) => t.tripId == track.tripId);
        } catch (_) {}

        // Driver Marker
        markers.add(
          Marker(
            point: driverLatLng,
            width: 50.r,
            height: 50.r,
            child: GestureDetector(
              onTap: () {
                if (widget.onSelectTrip != null) {
                  widget.onSelectTrip!(track.tripId);
                }
              },
              child: _buildBusMarker(context, color, tripMatch?.driverName ?? 'حافلة ${i + 1}'),
            ),
          ),
        );

        // Destination Marker
        if (tripMatch != null) {
          final destLatLng = LatLng(tripMatch.destination.lat, tripMatch.destination.lng);
          markers.add(
            Marker(
              point: destLatLng,
              width: 44.r,
              height: 44.r,
              child: _buildDestinationMarker(
                context,
                tripMatch.destination.type == 'home' ? Icons.home_rounded : Icons.school_rounded,
                tripMatch.destination.name,
              ),
            ),
          );

          polylines.add(
            Polyline(
              points: [driverLatLng, destLatLng],
              strokeWidth: 4.5,
              color: color,
            ),
          );
        }
      }
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: widget.isMultiMode ? 13.0 : 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.kids_transport.app',
            ),
            PolylineLayer(polylines: polylines),
            MarkerLayer(markers: markers),
          ],
        ),

        // Floating Control Buttons
        Positioned(
          left: 16.w,
          top: 16.h,
          child: Column(
            children: [
              _buildFloatingBtn(
                icon: Icons.add_rounded,
                onPressed: _zoomIn,
              ),
              SizedBox(height: 8.h),
              _buildFloatingBtn(
                icon: Icons.remove_rounded,
                onPressed: _zoomOut,
              ),
              SizedBox(height: 8.h),
              _buildFloatingBtn(
                icon: Icons.my_location_rounded,
                onPressed: _centerDriver,
              ),
              SizedBox(height: 8.h),
              _buildFloatingBtn(
                icon: Icons.map_rounded,
                color: AppColors.green,
                iconColor: AppColors.white,
                onPressed: () {
                  if (widget.singleTrack != null) {
                    _openGoogleMaps(widget.singleTrack!.driverLat, widget.singleTrack!.driverLng);
                  } else if (widget.multiTracks.isNotEmpty) {
                    _openGoogleMaps(widget.multiTracks.first.driverLat, widget.multiTracks.first.driverLng);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusMarker(BuildContext context, Color color, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
          child: Icon(
            Icons.directions_bus_filled_rounded,
            color: AppColors.white,
            size: 22.r,
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationMarker(BuildContext context, IconData icon, String label) {
    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: const BoxDecoration(
        color: AppColors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Icon(
        icon,
        color: AppColors.white,
        size: 20.r,
      ),
    );
  }

  Widget _buildFloatingBtn({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
    Color? iconColor,
  }) {
    final isDark = context.isDarkMode;
    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        color: color ?? (isDark ? context.cardSurface : AppColors.white),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 20.r,
          color: iconColor ?? (isDark ? AppColors.white : AppColors.textDark),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
