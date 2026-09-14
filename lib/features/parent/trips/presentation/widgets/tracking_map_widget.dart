import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kids_transport/core/theme/app_colors.dart';
import 'package:kids_transport/core/theme/text_styles.dart';
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
  static const LatLng defaultLocation = LatLng(32.8872, 13.1913);

  final Dio _dio = Dio();
  final Map<String, List<LatLng>> _routeCache = {};
  final Set<String> _pendingRouteRequests = {};

  final List<Color> _paletteColors = const [
    AppColors.primaryLight,
    AppColors.secondaryDark,
    AppColors.accentPurple,
    AppColors.accentGreen,
    AppColors.maleBlue,
  ];

  List<LatLng> _getPolylinePoints(LatLng start, LatLng end) {
    if (start.latitude == 0.0 || start.longitude == 0.0 || end.latitude == 0.0 || end.longitude == 0.0) {
      return [start, end];
    }

    final key = '${start.latitude.toStringAsFixed(4)},${start.longitude.toStringAsFixed(4)}->${end.latitude.toStringAsFixed(4)},${end.longitude.toStringAsFixed(4)}';

    if (_routeCache.containsKey(key)) {
      return _routeCache[key]!;
    }

    if (!_pendingRouteRequests.contains(key)) {
      _pendingRouteRequests.add(key);
      _fetchOSRMRoute(key, start, end);
    }

    return [start, end];
  }

  Future<void> _fetchOSRMRoute(String key, LatLng start, LatLng end) async {
    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/'
          '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
          '?overview=full&geometries=geojson';

      final response = await _dio.get(url).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        if (data['code'] == 'Ok' && data['routes'] is List && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];
          if (geometry is Map && geometry['coordinates'] is List) {
            final List coords = geometry['coordinates'] as List;
            final List<LatLng> path = coords.map<LatLng>((c) {
              final List pair = c as List;
              final double lng = (pair[0] as num).toDouble();
              final double lat = (pair[1] as num).toDouble();
              return LatLng(lat, lng);
            }).toList();

            if (path.isNotEmpty) {
              _routeCache[key] = path;
              debugPrint('🛣️ [OSRM ROUTE SUCCESS] Loaded ${path.length} road waypoints for key: $key');
              if (mounted) {
                setState(() {});
              }
              return;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ [OSRM ROUTE FALLBACK] Failed to fetch road route ($key): $e');
    } finally {
      _pendingRouteRequests.remove(key);
    }

    // Fallback if network or routing failed
    _routeCache[key] = [start, end];
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _zoomIn() {
    final currentZoom = widget.mapController.camera.zoom;
    widget.mapController.move(
      widget.mapController.camera.center,
      currentZoom + 1,
    );
  }

  void _zoomOut() {
    final currentZoom = widget.mapController.camera.zoom;
    widget.mapController.move(
      widget.mapController.camera.center,
      currentZoom - 1,
    );
  }

  void _centerDriver() {
    LatLng target = defaultLocation;

    if (!widget.isMultiMode && widget.singleTrack != null && widget.singleTrack!.driverLat != 0.0 && widget.singleTrack!.driverLng != 0.0) {
      target = LatLng(widget.singleTrack!.driverLat, widget.singleTrack!.driverLng);
    } else if (widget.multiTracks.isNotEmpty) {
      final valid = widget.multiTracks.firstWhere(
        (t) => t.driverLat != 0.0 && t.driverLng != 0.0,
        orElse: () => widget.multiTracks.first,
      );
      if (valid.driverLat != 0.0 && valid.driverLng != 0.0) {
        target = LatLng(valid.driverLat, valid.driverLng);
      }
    } else if (widget.singleTrip != null) {
      if (widget.singleTrip!.uniqueSchools.isNotEmpty) {
        target = LatLng(widget.singleTrip!.uniqueSchools.first.lat, widget.singleTrip!.uniqueSchools.first.lng);
      } else if (widget.singleTrip!.uniqueHomeAddresses.isNotEmpty) {
        target = LatLng(widget.singleTrip!.uniqueHomeAddresses.first.lat, widget.singleTrip!.uniqueHomeAddresses.first.lng);
      }
    } else if (widget.multiTrips.isNotEmpty) {
      final firstTrip = widget.multiTrips.first;
      if (firstTrip.uniqueSchools.isNotEmpty) {
        target = LatLng(firstTrip.uniqueSchools.first.lat, firstTrip.uniqueSchools.first.lng);
      } else if (firstTrip.uniqueHomeAddresses.isNotEmpty) {
        target = LatLng(firstTrip.uniqueHomeAddresses.first.lat, firstTrip.uniqueHomeAddresses.first.lng);
      }
    }

    debugPrint('🎯 [MAP RE-CENTER] Moving camera to Lat: ${target.latitude}, Lng: ${target.longitude}');
    widget.mapController.move(target, widget.isMultiMode ? 13.5 : 15.0);
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = [];
    List<Polyline> polylines = [];
    LatLng initialCenter = defaultLocation;

    // Build effective tracking list for MultiMode
    List<LiveTrackingModel> effectiveMultiTracks = widget.multiTracks;
    if (widget.isMultiMode && effectiveMultiTracks.isEmpty && widget.multiTrips.isNotEmpty) {
      effectiveMultiTracks = widget.multiTrips.map((trip) {
        double lat = trip.destination.lat;
        double lng = trip.destination.lng;
        if ((lat == 0.0 || lng == 0.0) && trip.uniqueSchools.isNotEmpty) {
          lat = trip.uniqueSchools.first.lat;
          lng = trip.uniqueSchools.first.lng;
        }
        if ((lat == 0.0 || lng == 0.0) && trip.uniqueHomeAddresses.isNotEmpty) {
          lat = trip.uniqueHomeAddresses.first.lat;
          lng = trip.uniqueHomeAddresses.first.lng;
        }
        return LiveTrackingModel(
          tripId: trip.tripId,
          status: trip.status,
          driverLat: lat,
          driverLng: lng,
          driverName: trip.driver.name,
          lastUpdated: 'من الباك إند',
        );
      }).toList();
    }

    // Build effective single track
    LiveTrackingModel? effectiveSingleTrack = widget.singleTrack;
    if (!widget.isMultiMode && effectiveSingleTrack == null && widget.singleTrip != null) {
      final trip = widget.singleTrip!;
      double lat = trip.destination.lat;
      double lng = trip.destination.lng;
      if ((lat == 0.0 || lng == 0.0) && trip.uniqueSchools.isNotEmpty) {
        lat = trip.uniqueSchools.first.lat;
        lng = trip.uniqueSchools.first.lng;
      }
      if ((lat == 0.0 || lng == 0.0) && trip.uniqueHomeAddresses.isNotEmpty) {
        lat = trip.uniqueHomeAddresses.first.lat;
        lng = trip.uniqueHomeAddresses.first.lng;
      }
      effectiveSingleTrack = LiveTrackingModel(
        tripId: trip.tripId,
        status: trip.status,
        driverLat: lat,
        driverLng: lng,
        driverName: trip.driver.name,
        lastUpdated: 'من الباك إند',
      );
    }

    if (!widget.isMultiMode && effectiveSingleTrack != null) {
      final driverLatLng = LatLng(
        effectiveSingleTrack.driverLat != 0.0 ? effectiveSingleTrack.driverLat : defaultLocation.latitude,
        effectiveSingleTrack.driverLng != 0.0 ? effectiveSingleTrack.driverLng : defaultLocation.longitude,
      );
      initialCenter = driverLatLng;

      // Driver marker
      markers.add(
        Marker(
          point: driverLatLng,
          width: 70.w,
          height: 70.h,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'السائق: ${widget.singleTrip?.driverName ?? effectiveSingleTrack?.driverName ?? "السائق"}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: _buildDriverBusMarker(
              context,
              context.primaryColor,
              widget.singleTrip?.driverName ?? effectiveSingleTrack.driverName ?? 'السائق',
            ),
          ),
        ),
      );

      // Destination / Schools / Home markers with Name Tag above
      final List<ChildSchoolModel> uniqueSchools = widget.singleTrip?.uniqueSchools ??
          effectiveSingleTrack.uniqueSchools;
      final List<ChildAddressModel> uniqueHomes = widget.singleTrip?.uniqueHomeAddresses ??
          effectiveSingleTrack.uniqueHomeAddresses;

      // Render Unique Schools (Deduplicated)
      for (final school in uniqueSchools) {
        final schoolLatLng = LatLng(school.lat, school.lng);
        markers.add(
          Marker(
            point: schoolLatLng,
            width: 110.w,
            height: 75.h,
            child: _buildDestinationMarker(
              context,
              Icons.school_rounded,
              school.name,
            ),
          ),
        );

        polylines.add(
          Polyline(
            points: _getPolylinePoints(driverLatLng, schoolLatLng),
            strokeWidth: 5.0,
            color: context.primaryColor,
          ),
        );
      }

      // Render Unique Home Addresses (Deduplicated)
      for (final home in uniqueHomes) {
        final homeLatLng = LatLng(home.lat, home.lng);
        markers.add(
          Marker(
            point: homeLatLng,
            width: 110.w,
            height: 75.h,
            child: _buildDestinationMarker(
              context,
              Icons.home_rounded,
              home.title.isNotEmpty ? home.title : 'المنزل',
            ),
          ),
        );

        polylines.add(
          Polyline(
            points: _getPolylinePoints(driverLatLng, homeLatLng),
            strokeWidth: 5.0,
            color: AppColors.accentPurple,
          ),
        );
      }

      // Fallback for destination if unique arrays are empty
      if (uniqueSchools.isEmpty && uniqueHomes.isEmpty) {
        final destName = widget.singleTrip?.destination.name ?? effectiveSingleTrack.destination?.name;
        final destType = widget.singleTrip?.destination.type ?? effectiveSingleTrack.destination?.type ?? 'school';
        final destLat = widget.singleTrip?.destination.lat ?? effectiveSingleTrack.destination?.lat;
        final destLng = widget.singleTrip?.destination.lng ?? effectiveSingleTrack.destination?.lng;

        if (destLat != null && destLng != null && destLat != 0.0 && destLng != 0.0) {
          final destLatLng = LatLng(destLat, destLng);
          final isHomeDest = destType.toLowerCase() == 'home';

          markers.add(
            Marker(
              point: destLatLng,
              width: 110.w,
              height: 75.h,
              child: _buildDestinationMarker(
                context,
                isHomeDest ? Icons.home_rounded : Icons.school_rounded,
                (destName != null && destName.isNotEmpty)
                    ? destName
                    : (isHomeDest ? 'المنزل (الوجهة)' : 'المدرسة (الوجهة)'),
              ),
            ),
          );

          polylines.add(
            Polyline(
              points: _getPolylinePoints(driverLatLng, destLatLng),
              strokeWidth: 5.0,
              color: isHomeDest ? AppColors.accentPurple : context.primaryColor,
            ),
          );
        }
      }
    } else if (widget.isMultiMode && effectiveMultiTracks.isNotEmpty) {
      initialCenter = LatLng(
        effectiveMultiTracks.first.driverLat != 0.0 ? effectiveMultiTracks.first.driverLat : defaultLocation.latitude,
        effectiveMultiTracks.first.driverLng != 0.0 ? effectiveMultiTracks.first.driverLng : defaultLocation.longitude,
      );

      for (int i = 0; i < effectiveMultiTracks.length; i++) {
        final track = effectiveMultiTracks[i];
        final color = _paletteColors[i % _paletteColors.length];
        final driverLatLng = LatLng(
          track.driverLat != 0.0 ? track.driverLat : defaultLocation.latitude,
          track.driverLng != 0.0 ? track.driverLng : defaultLocation.longitude,
        );

        ActiveTripModel? tripMatch;
        try {
          tripMatch = widget.multiTrips.firstWhere(
            (t) => t.tripId == track.tripId,
          );
        } catch (_) {}

        // Driver Marker
        markers.add(
          Marker(
            point: driverLatLng,
            width: 70.w,
            height: 70.h,
            child: GestureDetector(
              onTap: () {
                if (widget.onSelectTrip != null) {
                  widget.onSelectTrip!(track.tripId);
                }
              },
              child: _buildDriverBusMarker(
                context,
                color,
                tripMatch?.driverName ?? track.driverName ?? 'حافلة ${i + 1}',
              ),
            ),
          ),
        );

        // Destination Markers (Deduplicated across tripMatch or track)
        final List<ChildSchoolModel> uniqueSchools = tripMatch?.uniqueSchools ?? track.uniqueSchools;
        final List<ChildAddressModel> uniqueHomes = tripMatch?.uniqueHomeAddresses ?? track.uniqueHomeAddresses;

        if (uniqueSchools.isNotEmpty) {
          for (final school in uniqueSchools) {
            final schoolLatLng = LatLng(school.lat, school.lng);
            markers.add(
              Marker(
                point: schoolLatLng,
                width: 110.w,
                height: 75.h,
                child: _buildDestinationMarker(
                  context,
                  Icons.school_rounded,
                  school.name,
                ),
              ),
            );
            polylines.add(
              Polyline(
                points: _getPolylinePoints(driverLatLng, schoolLatLng),
                strokeWidth: 5.0,
                color: color,
              ),
            );
          }
        }

        if (uniqueHomes.isNotEmpty) {
          for (final home in uniqueHomes) {
            final homeLatLng = LatLng(home.lat, home.lng);
            markers.add(
              Marker(
                point: homeLatLng,
                width: 110.w,
                height: 75.h,
                child: _buildDestinationMarker(
                  context,
                  Icons.home_rounded,
                  home.title.isNotEmpty ? home.title : 'المنزل',
                ),
              ),
            );
            polylines.add(
              Polyline(
                points: _getPolylinePoints(driverLatLng, homeLatLng),
                strokeWidth: 5.0,
                color: color,
              ),
            );
          }
        }

        if (uniqueSchools.isEmpty && uniqueHomes.isEmpty) {
          final destName = tripMatch?.destination.name ?? track.destination?.name;
          final destType = tripMatch?.destination.type ?? track.destination?.type ?? 'school';
          final destLat = tripMatch?.destination.lat ?? track.destination?.lat;
          final destLng = tripMatch?.destination.lng ?? track.destination?.lng;

          if (destLat != null && destLng != null && destLat != 0.0 && destLng != 0.0) {
            final destLatLng = LatLng(destLat, destLng);
            final isHomeDest = destType.toLowerCase() == 'home';

            markers.add(
              Marker(
                point: destLatLng,
                width: 110.w,
                height: 75.h,
                child: _buildDestinationMarker(
                  context,
                  isHomeDest ? Icons.home_rounded : Icons.school_rounded,
                  (destName != null && destName.isNotEmpty)
                      ? destName
                      : (isHomeDest ? 'المنزل' : 'المدرسة'),
                ),
              ),
            );

            polylines.add(
              Polyline(
                points: _getPolylinePoints(driverLatLng, destLatLng),
                strokeWidth: 5.0,
                color: color,
              ),
            );
          }
        }
      }
    }

    debugPrint(
      '\n🗺️ ==================== [MAP RENDER DEBUG] ====================\n'
      'Mode: ${widget.isMultiMode ? "Multi (All Trips)" : "Single (One Child)"}\n'
      'SingleTrack Driver Lat: ${widget.singleTrack?.driverLat}, Lng: ${widget.singleTrack?.driverLng}\n'
      'Effective Single Driver Lat: ${effectiveSingleTrack?.driverLat}, Lng: ${effectiveSingleTrack?.driverLng}\n'
      'Firebase MultiTracks Count: ${widget.multiTracks.length}\n'
      'Effective MultiTracks Count: ${effectiveMultiTracks.length}\n'
      'Total Generated Markers: ${markers.length} | Polylines: ${polylines.length}\n'
      '=================================================================\n',
    );

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
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.kids_transport.app',
            ),
            PolylineLayer(polylines: polylines),
            MarkerLayer(markers: markers),
          ],
        ),

        // Re-arranged Floating Buttons: 📍 Locate -> 🧭 Navigation -> ➕ Zoom In -> ➖ Zoom Out
        Positioned(
          left: 16.w,
          top: 16.h,
          child: Column(
            children: [
              _buildFloatingBtn(
                icon: Icons.my_location_rounded,
                tooltip: 'إعادة التوسيط ومتابعة موقع الحافلة',
                onPressed: _centerDriver,
              ),
              SizedBox(height: 10.h),
              _buildFloatingBtn(
                icon: Icons.near_me_rounded,
                tooltip: 'فتح المسار في Google Maps',
                color: AppColors.green,
                iconColor: AppColors.white,
                onPressed: () {
                  if (widget.singleTrack != null) {
                    _openGoogleMaps(
                      widget.singleTrack!.driverLat,
                      widget.singleTrack!.driverLng,
                    );
                  } else if (widget.multiTracks.isNotEmpty) {
                    _openGoogleMaps(
                      widget.multiTracks.first.driverLat,
                      widget.multiTracks.first.driverLng,
                    );
                  }
                },
              ),
              SizedBox(height: 10.h),
              _buildFloatingBtn(
                icon: Icons.add_rounded,
                tooltip: 'تكبير الخريطة',
                onPressed: _zoomIn,
              ),
              SizedBox(height: 10.h),
              _buildFloatingBtn(
                icon: Icons.remove_rounded,
                tooltip: 'تصغير الخريطة',
                onPressed: _zoomOut,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverBusMarker(
    BuildContext context,
    Color color,
    String driverName,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.directions_bus_filled_rounded,
            color: AppColors.white,
            size: 24.r,
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationMarker(
    BuildContext context,
    IconData icon,
    String destinationName,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Destination Label Pill
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: context.isDarkMode ? context.cardSurface : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.red, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            destinationName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.style(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: const BoxDecoration(
            color: AppColors.red,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.white, size: 18.r),
        ),
      ],
    );
  }

  Widget _buildFloatingBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
    Color? iconColor,
  }) {
    final isDark = context.isDarkMode;
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: color ?? (isDark ? context.cardSurface : AppColors.white),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Tooltip(
        message: tooltip,
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            icon,
            size: 22.r,
            color: iconColor ?? (isDark ? AppColors.white : AppColors.textDark),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
