import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:codoky/core/config/constants/app_constants.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/core/utils/helpers/app_snackbar.dart';
import 'package:vibration/vibration.dart';
import 'package:codoky/core/logging/app_logger.dart';
import 'package:codoky/core/services/audio/tts_service.dart';
import 'package:codoky/core/services/location/location_service.dart';
import 'package:codoky/features/map/data/datasources/cached_disk_tile_provider.dart';
import 'package:codoky/features/map/data/datasources/hue_boundary_loader.dart';
import 'package:codoky/features/map/data/datasources/vietnam_boundary_loader.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/features/map/presentation/providers/current_weather_provider.dart';
import 'package:codoky/features/map/presentation/widgets/map_bottom_sheet.dart';
import 'package:codoky/features/map/presentation/widgets/map_search_bar_widget.dart';
import 'package:codoky/features/map/presentation/widgets/map_toolbar_widget.dart';
import 'package:codoky/features/map/presentation/widgets/place_marker.dart';
import 'package:codoky/features/map/presentation/widgets/marker_constants.dart';
import 'package:codoky/features/map/utils/marker_overlap_resolver.dart';

class MapHomeScreen extends ConsumerStatefulWidget {
  const MapHomeScreen({super.key});

  @override
  ConsumerState<MapHomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends ConsumerState<MapHomeScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final LocationService _locationService;
  late AnimationController _pulseController;
  List<LatLng>? _hueBoundary;
  List<List<LatLng>>? _vietnamRings;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    HueBoundaryLoader.loadBoundaryRing().then((ring) {
      if (!mounted) return;
      setState(() => _hueBoundary = ring);
    });

    VietnamBoundaryLoader.loadBoundaryRings().then((rings) {
      if (!mounted) return;
      setState(() => _vietnamRings = rings);
    });

    Future.microtask(() {
      ref.read(mapProvider.notifier).loadPlaces();
      _initLocation();
    });
  }

  Future<void> _initLocation() async {
    try {
      final hasPermission = await _locationService.ensureLocationPermission(context);
      if (!hasPermission) return;

      final res = await _locationService.getAccuratePosition(
        onFastFix: (fastResult) {
          if (mounted) {
            ref.read(mapProvider.notifier).setCurrentLocation(fastResult.position);
            _animatedMapMove(fastResult.position, 16.5);
          }
        },
      );
      if (res != null && mounted) {
        ref.read(mapProvider.notifier).setCurrentLocation(res.position);
        _animatedMapMove(res.position, 16.5);
        // Fetch thời tiết hiện tại đúng 1 lần tại fix GPS chính xác đầu tiên.
        // KHÔNG gắn vào onLocationUpdate stream — cache đã có trong Notifier.
        if (!mounted) return;
        ref.read(currentWeatherProvider.notifier)
            .refreshIfNeeded(res.position);
      }
    } catch (e) {
      AppLogger.w('Location permission or fetch warning: $e');
    }
  }

  bool _isLiveTracking = false;
  bool _isAutoFollowUser = true;
  bool _isGpsWeak = false;
  double? _currentHeading;

  @override
  void dispose() {
    _stopLiveNavigation();
    _pulseController.dispose();
    super.dispose();
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final startLat = start.latitude * (math.pi / 180.0);
    final startLng = start.longitude * (math.pi / 180.0);
    final endLat = end.latitude * (math.pi / 180.0);
    final endLng = end.longitude * (math.pi / 180.0);

    final dLng = endLng - startLng;

    final y = math.sin(dLng) * math.cos(endLat);
    final x = math.cos(startLat) * math.sin(endLat) -
        math.sin(startLat) * math.cos(endLat) * math.cos(dLng);

    return math.atan2(y, x);
  }

  double _calculateDistanceMeters(LatLng p1, LatLng p2) {
    const double r = 6371000;
    final lat1 = p1.latitude * (math.pi / 180.0);
    final lat2 = p2.latitude * (math.pi / 180.0);
    final dLat = (p2.latitude - p1.latitude) * (math.pi / 180.0);
    final dLng = (p2.longitude - p1.longitude) * (math.pi / 180.0);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  int _announcedStepIndex = -1;
  int _announcedLevel = 0;

  void _checkVoiceTriggers(LatLng userPos) {
    final state = ref.read(mapProvider);
    final route = state.activeRoute;
    if (route == null || route.steps.isEmpty || state.isVoiceMuted) return;

    final steps = route.steps;
    final stepIdx = state.currentStepIndex.clamp(0, steps.length - 1);

    if (_announcedStepIndex != stepIdx) {
      _announcedStepIndex = stepIdx;
      _announcedLevel = 0;
    }

    final currentStep = steps[stepIdx];
    final distMeters = _calculateDistanceMeters(userPos, currentStep.location);

    if (distMeters <= 200 && distMeters > 50 && _announcedLevel < 1) {
      _announcedLevel = 1;
      final text = context.l10n.ttsApproach(distMeters.round(), currentStep.instruction);
      TtsService().speak(text);
    } else if (distMeters <= 50 && _announcedLevel < 2) {
      _announcedLevel = 2;
      final text = currentStep.instruction;
      TtsService().speak(text);

      if (stepIdx < steps.length - 1) {
        ref.read(mapProvider.notifier).setCurrentStepIndex(stepIdx + 1);
      }
    }
  }

  double _getOffRouteThreshold(String mode) {
    switch (mode) {
      case 'foot':
        return 30.0;
      case 'driving':
        return 70.0;
      case 'motorbike':
      default:
        return 50.0;
    }
  }

  double _minDistanceToPolyline(LatLng point, List<LatLng> polyline) {
    if (polyline.isEmpty) return double.infinity;
    if (polyline.length == 1) return _calculateDistanceMeters(point, polyline.first);

    double minDistance = double.infinity;
    for (int i = 0; i < polyline.length - 1; i++) {
      final dist = _distanceToSegmentMeters(point, polyline[i], polyline[i + 1]);
      if (dist < minDistance) {
        minDistance = dist;
      }
    }
    return minDistance;
  }

  double _distanceToSegmentMeters(LatLng p, LatLng a, LatLng b) {
    const double latMetersPerDegree = 111000.0;
    final lngMetersPerDegree = 111000.0 * math.cos(p.latitude * math.pi / 180.0);

    final px = p.longitude * lngMetersPerDegree;
    final py = p.latitude * latMetersPerDegree;
    final ax = a.longitude * lngMetersPerDegree;
    final ay = a.latitude * latMetersPerDegree;
    final bx = b.longitude * lngMetersPerDegree;
    final by = b.latitude * latMetersPerDegree;

    final dx = bx - ax;
    final dy = by - ay;

    if (dx == 0 && dy == 0) {
      return _calculateDistanceMeters(p, a);
    }

    final t = ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy);

    if (t < 0) {
      return _calculateDistanceMeters(p, a);
    } else if (t > 1) {
      return _calculateDistanceMeters(p, b);
    }

    final projX = ax + t * dx;
    final projY = ay + t * dy;

    final projLat = projY / latMetersPerDegree;
    final projLng = projX / lngMetersPerDegree;

    return _calculateDistanceMeters(p, LatLng(projLat, projLng));
  }

  DateTime? _offRouteStartTime;
  bool _isRecalculatingRoute = false;

  void _checkOffRouteAndRecalculate(LatLng userPos) {
    final state = ref.read(mapProvider);
    final route = state.activeRoute;
    if (route == null || route.points.isEmpty || _isRecalculatingRoute) return;

    final minDistance = _minDistanceToPolyline(userPos, route.points);
    final threshold = _getOffRouteThreshold(state.travelMode);

    if (minDistance > threshold) {
      _offRouteStartTime ??= DateTime.now();
      final offRouteSeconds = DateTime.now().difference(_offRouteStartTime!).inSeconds;

      if (offRouteSeconds >= 5) {
        _triggerReroute(userPos);
      }
    } else {
      _offRouteStartTime = null;
    }
  }

  Future<void> _triggerReroute(LatLng userPos) async {
    if (_isRecalculatingRoute) return;

    _isRecalculatingRoute = true;
    _offRouteStartTime = null;

    AppLogger.i('🔄 Phát hiện đi lệch route (>5s). Tiến hành tự động tính lại tuyến đường...');

    if (!ref.read(mapProvider).isVoiceMuted) {
      TtsService().speak(context.l10n.ttsRecalculating);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.recalculatingSnackbar),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFFFF7A00),
        ),
      );
    }

    final activeRoute = ref.read(mapProvider).activeRoute;
    if (activeRoute != null && activeRoute.points.isNotEmpty) {
      final destination = activeRoute.points.last;
      final targetPlace = {'latitude': destination.latitude, 'longitude': destination.longitude};

      final success = await ref.read(mapProvider.notifier).fetchRouteToPlace(targetPlace);
      if (success && mounted) {
        ref.read(mapProvider.notifier).setCurrentStepIndex(0);
        _announcedStepIndex = -1;
        _announcedLevel = 0;

        final newRoute = ref.read(mapProvider).activeRoute;
        if (newRoute != null) {
          _fitRouteBounds(newRoute.points);
        }
      }
    }

    _isRecalculatingRoute = false;
  }

  void _startLiveNavigation() {
    if (_isLiveTracking) return;

    setState(() {
      _isLiveTracking = true;
      _isAutoFollowUser = true;
      _isGpsWeak = false;
      _announcedStepIndex = -1;
      _announcedLevel = 0;
      _offRouteStartTime = null;
      _isRecalculatingRoute = false;
      _hasArrived = false;
    });


    _locationService.startLiveTracking(
      distanceFilterMeters: 3,
      onLocationUpdate: (LatLng newPos, double accuracy) {
        if (!mounted) return;

        final prevPos = ref.read(mapProvider).currentLocation;
        double? heading = _currentHeading;

        if (prevPos != null) {
          final dist = _calculateDistanceMeters(prevPos, newPos);
          if (dist > 2.0) {
            heading = _calculateBearing(prevPos, newPos);
          }
        }

        final isWeak = accuracy > 50.0;

        setState(() {
          _isGpsWeak = isWeak;
          _currentHeading = heading;
        });

        ref.read(mapProvider.notifier).setCurrentLocation(newPos);
        _checkVoiceTriggers(newPos);
        _checkOffRouteAndRecalculate(newPos);
        _checkDestinationArrival(newPos);

        final hasRoute = ref.read(mapProvider).activeRoute != null;
        if (_isAutoFollowUser && hasRoute) {
          _animatedMapMove(newPos, 17.0, duration: AppMotion.micro * 2, curve: AppMotion.standardCurve);
        }
      },
    );

    // ✔️ Cờ hiệu isNavigating → UI chuyển sang chế độ Navigate (chips ẩn, ETA hiện)
    ref.read(mapProvider.notifier).startNavigating();

    AppLogger.i('📡 Đã khởi chạy Real-Time GPS Live Navigation Tracking (Voice, Re-routing & Arrival Enabled)');
  }

  bool _hasArrived = false;

  void _checkDestinationArrival(LatLng userPos) {
    if (_hasArrived) return;
    final state = ref.read(mapProvider);
    final route = state.activeRoute;
    if (route == null || route.points.isEmpty) return;

    final destPos = route.points.last;
    final distToDest = _calculateDistanceMeters(userPos, destPos);

    if (distToDest <= 25.0) {
      _hasArrived = true;
      _triggerArrival();
    }
  }

  Future<void> _triggerArrival() async {
    final l10n = context.l10n;
    _stopLiveNavigation();

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 1000);
      }
    } catch (e) {
      AppLogger.w('Vibration error: $e');
    }

    if (!ref.read(mapProvider).isVoiceMuted) {
      TtsService().speak(l10n.ttsArrived);
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
              const SizedBox(width: 10),
              Text(l10n.arrivedTitle),
            ],
          ),
          content: Text(l10n.arrivedMessage),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.close),
            ),
          ],
        ),
      );
    }
  }


  void _stopLiveNavigation() {
    _locationService.stopLiveTracking();
    TtsService().stop();
    if (mounted) {
      setState(() {
        _isLiveTracking = false;
        _isGpsWeak = false;
        _currentHeading = null;
        _announcedStepIndex = -1;
        _announcedLevel = 0;
        _offRouteStartTime = null;
        _isRecalculatingRoute = false;
      });
    }
    // ✔️ Hạ cờ isNavigating → UI quay lại Preview mode
    ref.read(mapProvider.notifier).stopNavigating();
    AppLogger.i('🛑 Đã dừng Real-Time GPS Live Navigation Tracking');
  }




  LatLng? _previousCameraCenter;
  double? _previousCameraZoom;

  void _animatedMapMove(
    LatLng destLocation,
    double destZoom, {
    Curve curve = AppMotion.emphasizedCurve,
    Duration duration = AppMotion.emphasized,
  }) {
    final camera = _mapController.camera;
    final latTween = Tween<double>(begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(
      duration: duration,
      vsync: this,
    );

    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: curve,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _clearSelectionAndZoomOut() {
    ref.read(mapProvider.notifier).clearSelection();
    if (_previousCameraCenter != null) {
      _animatedMapMove(_previousCameraCenter!, _previousCameraZoom ?? 15.0);
    }
    _previousCameraCenter = null;
    _previousCameraZoom = null;
  }

  void _fitRouteBounds(List<LatLng> points) {
    if (points.isEmpty) return;
    try {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.fromLTRB(40, 140, 40, 140),
        ),
      );
    } catch (e) {
      AppLogger.w('Fit route bounds warning: $e');
    }
  }

  Map<String, Offset> _markerOverlapOffsets = {};

  void _recalculateMarkerOverlapOffsets(List<dynamic> places) {
    if (places.isEmpty) return;
    final entries = <MapEntry<String, Offset>>[];
    for (final place in places) {
      final lat = place['latitude'] as double? ?? (place.latitude as double?);
      final lng = place['longitude'] as double? ?? (place.longitude as double?);
      final pId = (place['id'] as dynamic)?.toString() ?? '';
      if (lat != null && lng != null && pId.isNotEmpty) {
        final point = _mapController.camera.latLngToScreenPoint(LatLng(lat, lng));
        entries.add(MapEntry(pId, Offset(point.x, point.y)));
      }
    }
    final resolved = MarkerOverlapResolver.resolveOverlaps(
      screenPositions: entries,
      threshold: MarkerConstants.overlapThresholdPx,
    );
    if (mounted) {
      setState(() {
        _markerOverlapOffsets = resolved;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          FlutterMap(
                mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                AppConstants.defaultMapLatitude,
                AppConstants.defaultMapLongitude,
              ),
              initialZoom: AppConstants.defaultMapZoom.toDouble(),
              minZoom: AppConstants.minMapZoom,
              maxZoom: AppConstants.maxMapZoom,
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  AppConstants.vietnamSouthWest,
                  AppConstants.vietnamNorthEast,
                ),
              ),
              onTap: (_, _) => _clearSelectionAndZoomOut(),
              onMapEvent: (event) {
                if (event is MapEventMoveEnd || event is MapEventFlingAnimationEnd) {
                  _recalculateMarkerOverlapOffsets(state.places);
                }
              },
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && _isAutoFollowUser && state.activeRoute != null) {
                  setState(() {
                    _isAutoFollowUser = false;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _getTileUrlTemplate(state.mapTileStyle),
                userAgentPackageName: 'com.codoky.app',
                tileProvider: CachedDiskTileProvider(
                  userAgent: 'com.codoky.app',
                  maxCacheSizeBytes: 250 * 1024 * 1024,
                  maxCacheAge: const Duration(days: 30),
                ),
              ),
              // Tầng overlay ranh giới Việt Nam (Đất liền + Hoàng Sa + Trường Sa + Phú Quốc):
              // Mask phủ mờ các quốc gia khác, giữ trọn vẹn lãnh thổ Việt Nam tươi sáng.
              if ((_vietnamRings != null && _vietnamRings!.isNotEmpty) || _hueBoundary != null)
                IgnorePointer(
                  child: PolygonLayer(
                    polygonCulling: false,
                    polygons: [
                      Polygon(
                        points: _worldMaskPolygon,
                        holePointsList: [
                          ...?_vietnamRings,
                          if (_vietnamRings == null && _hueBoundary != null) _hueBoundary!,
                        ],
                        color: _boundaryMaskColor(context),
                        borderStrokeWidth: 0,
                        disableHolesBorder: true,
                      ),
                    ],
                  ),
                ),
              // Marker khẳng định chủ quyền quốc gia Hoàng Sa & Trường Sa của Việt Nam 🇻🇳
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(16.50, 112.00),
                    width: 220,
                    height: 48,
                    alignment: Alignment.center,
                    child: _buildIslandSovereigntyBadge('Quần đảo Hoàng Sa (Việt Nam)'),
                  ),
                  Marker(
                    point: const LatLng(9.50, 113.80),
                    width: 220,
                    height: 48,
                    alignment: Alignment.center,
                    child: _buildIslandSovereigntyBadge('Quần đảo Trường Sa (Việt Nam)'),
                  ),
                ],
              ),
              if (_hueBoundary != null)
                IgnorePointer(
                  child: PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _hueBoundary!,
                        strokeWidth: 3.0,
                        color: _boundaryLineColor(context),
                        pattern: StrokePattern.dashed(segments: [12, 10]),
                      ),
                    ],
                  ),
                ),
              if (state.alternativeRoutes.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    // Các tuyến AI gợi ý (chưa được chọn) -> Nét đứt (Dashed), màu xám nhạt hơn
                    for (int i = 0; i < state.alternativeRoutes.length; i++)
                      if (i != state.selectedRouteIndex)
                        Polyline(
                          points: state.alternativeRoutes[i].points,
                          strokeWidth: 4.0,
                          color: const Color(0xFF94A3B8).withValues(alpha: 0.8),
                          pattern: StrokePattern.dashed(segments: [15, 10]),
                        ),
                    // Tuyến đường đang được chọn (Active Route) -> Nét liền (Solid), màu Crimson Huế chuyên nghiệp
                    if (state.activeRoute != null)
                      Polyline(
                        points: state.activeRoute!.points,
                        strokeWidth: 5.0,
                        color: const Color(0xFF8B1522),
                        borderStrokeWidth: 2.0,
                        borderColor: Colors.white,
                      ),
                  ],
                )
              else if (state.activeRoute != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: state.activeRoute!.points,
                      strokeWidth: 5.0,
                      color: const Color(0xFF8B1522),
                      borderStrokeWidth: 2.0,
                      borderColor: Colors.white,
                    ),
                  ],
                ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 60,
                  size: const Size(42, 42),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  rotate: true,
                  markers: (state.activeRoute != null && state.selectedPlace != null)
                      ? _buildMarkers([state.selectedPlace!], state.selectedPlace)
                      : _buildMarkers(state.places, state.selectedPlace),
                  builder: (context, markers) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF8B1522), Color(0xFFA61C31)],
                        ),
                        border: Border.all(color: Colors.white, width: 2.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x408B1522),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (state.currentLocation != null)
                MarkerLayer(
                  markers: [
                    _buildUserLocationMarker(state.currentLocation!),
                  ],
                ),
            ],
          ),
          // BottomSheet chỉ hiện ở chế độ Preview (chưa navigate) với animation Slide + Fade
          Positioned(
            bottom: state.activeRoute != null ? 164 : 96,
            left: 14,
            right: 14,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              reverseDuration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.35),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: (state.selectedPlace != null && !state.isNavigating)
                  ? MapBottomSheet(
                      key: ValueKey(
                        state.selectedPlace is Map
                            ? (state.selectedPlace['id']?.toString() ?? '1')
                            : (state.selectedPlace.id?.toString() ?? '1'),
                      ),
                      place: state.selectedPlace!,
                      onClose: _clearSelectionAndZoomOut,
                      onNavigate: () async {
                        if (state.isFetchingRoute) return;
                        final targetPlace = state.selectedPlace;
                        if (state.activeRoute == null) {
                          // Preview mode 1: Fetch routes but don't close bottom sheet
                          final success = await ref.read(mapProvider.notifier).fetchRouteToPlace(targetPlace);
                          if (!mounted) return;
                          if (success) {
                            final route = ref.read(mapProvider).activeRoute;
                            if (route != null) {
                              _fitRouteBounds(route.points);
                            }
                          } else {
                            if (!context.mounted) return;
                            final err = ref.read(mapProvider).routeErrorMessage ?? context.l10n.errorWith(context.l10n.noPlacesFound);
                            AppSnackBar.show(context, err, isError: true);
                          }
                        } else {
                          // Preview mode 2: Start actual live navigation
                          _startLiveNavigation();
                        }
                      },
                    )
                  : const SizedBox.shrink(key: ValueKey('empty_sheet')),
            ),
          ),

          // Top Navigation Banner (Turn-by-turn instruction full-width white card)
          if (state.activeRoute != null && state.activeRoute!.steps.isNotEmpty && !state.isFetchingRoute)
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: _buildTurnByTurnBanner(state),
            ),

          // Tầng 2: Thanh Điều Khiển Hành Trình Gộp Chung Cố Định (Single Consolidated Control Bar)
          if (state.activeRoute != null && !state.isFetchingRoute)
            Positioned(
              bottom: 96,
              left: 14,
              right: 14,
              child: _buildConsolidatedNavigationControlBar(state),
            ),


          if (state.activeRoute == null)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: MapSearchBarWidget(),
            ),


          Positioned(
            top: state.activeRoute != null ? 96 : 124,
            right: 14,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              // Toolbar hiện khi:
              // - Không có địa điểm nào (bình thường)
              // - Đang điều hướng thực tế (cần nút recenter GPS)
              // Ẩn khi: có địa điểm nhưng chưa navigate (bottom sheet đang mở)
              opacity: (state.selectedPlace != null && !state.isNavigating) ? 0.0 : 1.0,
              child: IgnorePointer(
                ignoring: state.selectedPlace != null && !state.isNavigating,
                child: MapToolbarWidget(
                  isAutoFollowUser: _isAutoFollowUser,
                  onRecenterGps: () {
                    setState(() {
                      _isAutoFollowUser = true;
                    });
                    final userPos = ref.read(mapProvider).currentLocation;
                    if (userPos != null) {
                      _animatedMapMove(userPos, 17.0);
                    }
                  },
                  onLocateUser: _goToCurrentLocation,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Chip phương tiện — có thể bấm, đồng bộ Royal Blue token, dùng Material Icon không dùng emoji
  Widget _buildMiniTravelModeChip(String mode, String currentMode) {
    final isSelected = mode == currentMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final IconData icon;
    final String label;
    switch (mode) {
      case 'motorbike':
        icon = Icons.two_wheeler_rounded;
        label = context.l10n.travelMotorbike;
      case 'driving':
        icon = Icons.directions_car_rounded;
        label = context.l10n.travelDriving;
      default:
        icon = Icons.directions_walk_rounded;
        label = context.l10n.travelWalking;
    }

    return GestureDetector(
      onTap: () => ref.read(mapProvider.notifier).setTravelMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : AppColors.primaryContainer.withValues(alpha: 0.40)),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : AppColors.primary.withValues(alpha: 0.18)),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : AppColors.primary),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : AppColors.primaryDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsolidatedNavigationControlBar(MapState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeRoute = state.activeRoute!;

    // Glass tint chuẩn theo UI_RULES: 20% white/black trong suốt
    final glassSurface = isDark
        ? const Color(0x33000000)
        : Colors.white.withValues(alpha: 0.92);

    // ETA: giờ đến dự kiến = hiện tại + remainingDuration
    final etaTime = DateTime.now().add(
      Duration(seconds: activeRoute.durationSeconds.toInt()),
    );
    final etaLabel =
        '${etaTime.hour.toString().padLeft(2, '0')}:${etaTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: glassSurface,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.07),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: state.isNavigating
          // ============================================================
          // CHẾNG NAVIGATE: Distance · Duration · ETA | GPS Recenter | Hủy
          // ============================================================
          ? Row(
              children: [
                // Khoảng cách + thời gian còn lại
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            activeRoute.formattedDistance,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: isDark ? Colors.white : AppColors.primaryDark,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '·',
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark
                                    ? Colors.white38
                                    : AppColors.primary.withValues(alpha: 0.40),
                              ),
                            ),
                          ),
                          Text(
                            activeRoute.formattedDuration,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: isDark ? Colors.white70 : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      // ETA — giờ đến dự kiến
                      Row(
                        children: [
                          Icon(
                            Icons.flag_rounded,
                            size: 10,
                            color: isDark
                                ? Colors.white38
                                : AppColors.primary.withValues(alpha: 0.50),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            context.l10n.etaLabel(etaLabel),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white38
                                  : AppColors.primary.withValues(alpha: 0.60),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Nút Recenter GPS — quan trọng khi đang navigate và bản đồ bị pan
                GestureDetector(
                  onTap: () {
                    setState(() => _isAutoFollowUser = true);
                    final userPos = ref.read(mapProvider).currentLocation;
                    if (userPos != null) _animatedMapMove(userPos, 17.0);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isAutoFollowUser
                          ? AppColors.primary
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.10)
                              : AppColors.primaryContainer),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isAutoFollowUser
                            ? AppColors.primaryDark
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : AppColors.primary.withValues(alpha: 0.25)),
                        width: 1.0,
                      ),
                    ),
                    child: Icon(
                      _isAutoFollowUser
                          ? Icons.my_location_rounded
                          : Icons.location_searching_rounded,
                      size: 16,
                      color: _isAutoFollowUser
                          ? Colors.white
                          : (isDark ? Colors.white70 : AppColors.primary),
                    ),
                  ),
                ),

                // Divider mỏng
                Container(
                  width: 1,
                  height: 20,
                  margin: const EdgeInsets.only(right: 8),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.15),
                ),

                // Nút Hủy
                GestureDetector(
                  onTap: () {
                    _stopLiveNavigation();
                    ref.read(mapProvider.notifier).clearRoute();
                    AppSnackBar.show(context, context.l10n.routeCancelled);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.red.withValues(alpha: 0.18)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: isDark
                            ? Colors.red.withValues(alpha: 0.35)
                            : const Color(0xFFFCA5A5),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close_rounded, size: 13,
                            color: isDark ? Colors.red[300] : const Color(0xFFDC2626)),
                        const SizedBox(width: 4),
                        Text(context.l10n.cancel,
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: isDark ? Colors.red[300] : const Color(0xFFDC2626),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            )
          // ============================================================
          // CHẾNG PREVIEW: Distance · Duration | Chips phương tiện | Hủy
          // ============================================================
          : Row(
              children: [
                // Khoảng cách & Thời gian
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        activeRoute.formattedDistance,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '·',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: isDark
                                ? Colors.white38
                                : AppColors.primary.withValues(alpha: 0.40),
                          ),
                        ),
                      ),
                      Text(
                        activeRoute.formattedDuration,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDark ? Colors.white70 : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider mỏng
                Container(
                  width: 1, height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.15),
                ),

                // 3 chip phương tiện bấm được
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMiniTravelModeChip('motorbike', state.travelMode),
                      _buildMiniTravelModeChip('driving', state.travelMode),
                      _buildMiniTravelModeChip('walking', state.travelMode),
                    ],
                  ),
                ),

                // Divider mỏng
                Container(
                  width: 1, height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.15),
                ),

                // Nút Hủy
                GestureDetector(
                  onTap: () {
                    _stopLiveNavigation();
                    ref.read(mapProvider.notifier).clearRoute();
                    AppSnackBar.show(context, context.l10n.routeCancelled);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.red.withValues(alpha: 0.18)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: isDark
                            ? Colors.red.withValues(alpha: 0.35)
                            : const Color(0xFFFCA5A5),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close_rounded, size: 13,
                            color: isDark ? Colors.red[300] : const Color(0xFFDC2626)),
                        const SizedBox(width: 4),
                        Text(context.l10n.cancel,
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: isDark ? Colors.red[300] : const Color(0xFFDC2626),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTurnByTurnBanner(MapState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final steps = state.activeRoute!.steps;
    final idx = state.currentStepIndex.clamp(0, steps.length - 1);
    final currentStep = steps[idx];

    final currentPos = state.currentLocation ?? const LatLng(16.4637, 107.5909);
    final distMeters = _calculateDistanceMeters(currentPos, currentStep.location);
    final distText = distMeters >= 1000
        ? context.l10n.distanceKm((distMeters / 1000).toStringAsFixed(1))
        : context.l10n.distanceM(distMeters.round().toString());

    IconData turnIcon = Icons.straight_rounded;
    if (currentStep.type == 'arrive') {
      turnIcon = Icons.location_on_rounded;
    } else if (currentStep.modifier.contains('left')) {
      turnIcon = Icons.turn_left_rounded;
    } else if (currentStep.modifier.contains('right')) {
      turnIcon = Icons.turn_right_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(turnIcon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.remainingDistance(distText),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentStep.instruction,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              ref.read(mapProvider.notifier).toggleVoiceMute();
            },
            icon: Icon(
              state.isVoiceMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: state.isVoiceMuted ? const Color(0xFF94A3B8) : const Color(0xFF2563EB),
              size: 22,
            ),
            tooltip: state.isVoiceMuted ? context.l10n.voiceOn : context.l10n.voiceOff,
          ),
        ],
      ),
    );
  }



  Marker _buildUserLocationMarker(LatLng position) {
    final opacityFactor = _isGpsWeak ? 0.5 : 1.0;

    return Marker(
      point: position,
      width: 60,
      height: 60,
      rotate: true,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + (_pulseController.value * 0.45);
          final opacity = (1.0 - _pulseController.value).clamp(0.0, 1.0);

          return Opacity(
            opacity: opacityFactor,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isGpsWeak
                          ? const Color(0xFFF59E0B).withValues(alpha: opacity * 0.35)
                          : const Color(0xFF1E88E5).withValues(alpha: opacity * 0.35),
                    ),
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isGpsWeak
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                        : const Color(0xFF1E88E5).withValues(alpha: 0.2),
                    border: Border.all(
                      color: _isGpsWeak
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.8)
                          : const Color(0xFF1E88E5).withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                ),
                if (_currentHeading != null)
                  Transform.rotate(
                    angle: _currentHeading!,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7A00),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.navigation_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  )
                else ...[
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isGpsWeak
                            ? const [Color(0xFFFBBF24), Color(0xFFD97706)]
                            : const [Color(0xFF42A5F5), Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }


  // ------------------------------------------------------------
  // Mask ranh giới Huế: polygon nền phủ toàn cầu (toạ độ cố định, không phụ
  // thuộc viewport) với ranh giới Huế được "khoét lỗ" + viền nét đứt.
  // Phải nằm DƯỚI lớp marker để không chặn hitTest người dùng.
  // ------------------------------------------------------------

  /// Ring khổng lồ phủ toàn cầu (bao cả bản sao world khi wrap quanh kinh
  /// tuyến 180°) để mask không bao giờ lộ viền dù zoom out tối đa.
  static final List<LatLng> _worldMaskPolygon = _buildWorldMaskPolygon();

  static List<LatLng> _buildWorldMaskPolygon() {
    // Phủ ±7200° kinh độ (= 20 bản sao thế giới) để mask luôn phủ kín viewport
    // dù zoom out tối đa (zoom 0 hiển thị tới ~5 bản sao world) hay pan xa.
    const double lonEdge = 7200.0;
    const double northLat = 89.9;
    const double southLat = -89.9;
    const int steps = 72;
    final points = <LatLng>[];
    for (int i = 0; i <= steps; i++) {
      points.add(LatLng(northLat, -lonEdge + i * (lonEdge * 2) / steps));
    }
    for (int i = 0; i <= steps; i++) {
      points.add(LatLng(northLat - (northLat - southLat) * i / steps, lonEdge));
    }
    for (int i = 0; i <= steps; i++) {
      points.add(LatLng(southLat, lonEdge - i * (lonEdge * 2) / steps));
    }
    for (int i = 0; i <= steps; i++) {
      points.add(LatLng(southLat + (northLat - southLat) * i / steps, -lonEdge));
    }
    return points;
  }

  /// Màu overlay ngoài ranh giới: trắng/xám alpha ~0.5 (sáng) hoặc tối nhẹ
  /// (bản đồ dark) — phần trong Huế giữ nguyên trong suốt.
  Color _boundaryMaskColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.68);
  }

  /// Màu viền nét đứt theo ranh giới — tương phản tốt trên cả 2 nền tile.
  Color _boundaryLineColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF334155);
  }

  /// Badge khẳng định chủ quyền lãnh hải & hải đảo Việt Nam 🇻🇳
  Widget _buildIslandSovereigntyBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66991B1B),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFFDE047), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFDE047), size: 15),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(List<dynamic> places, dynamic selectedPlace) {
    final markers = <Marker>[];
    final mapState = ref.watch(mapProvider);
    final savedIds = mapState.savedPlaceIds;

    for (final place in places) {
      final lat = place['latitude'] as double? ?? (place.latitude as double?);
      final lng = place['longitude'] as double? ?? (place.longitude as double?);
      final category = place['category'] as String? ?? (place.category as String? ?? 'attraction');
      final pId = (place['id'] as dynamic)?.toString() ?? '';
      final rating = (place['rating'] as num?)?.toDouble() ?? 0.0;
      final isFeatured = (place['is_featured'] == true) || (place['featured'] == true) || rating >= 4.5;
      final isSaved = savedIds.contains(pId);
      final isSelected = selectedPlace != null && (place['id'] == selectedPlace['id']);

      if (lat != null && lng != null) {
        final targetPos = LatLng(lat, lng);
        final overlapOffset = _markerOverlapOffsets[pId] ?? Offset.zero;

        markers.add(
          Marker(
            point: targetPos,
            width: 140,
            height: 96,
            alignment: Alignment.topCenter,
            rotate: true,
            child: Transform.translate(
              offset: overlapOffset,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                // Mutual exclusion: Hạ Bảng Thời Tiết (WeatherDetailSheet) nếu đang mở
                Navigator.of(context).maybePop();
                if (_previousCameraCenter == null) {
                  _previousCameraCenter = _mapController.camera.center;
                  _previousCameraZoom = _mapController.camera.zoom;
                }
                ref.read(mapProvider.notifier).selectPlace(place);
                _animatedMapMove(
                  targetPos,
                  16.8,
                  curve: Curves.easeInOutCubic,
                  duration: const Duration(milliseconds: 650),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlaceMarker(
                    category: category,
                    isSelected: isSelected,
                    isSaved: isSaved,
                    isFeatured: isFeatured,
                    style: mapState.markerStyle,
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    opacity: isSelected ? 1.0 : 0.0,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOutCubic,
                      scale: isSelected ? 1.0 : 0.75,
                      child: Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          (place['name'] as String? ?? place.name as String? ?? ''),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      }
    }
    return markers;
  }

  String _getTileUrlTemplate(MapTileStyle? style) {
    switch (style) {
      case MapTileStyle.cartoVoyager:
        return 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
      case MapTileStyle.cartoDark:
        return 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
      case MapTileStyle.cartoPositron:
        return 'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';
      case MapTileStyle.osmStandard:
      default:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  Future<void> _goToCurrentLocation() async {
    final hasPermission = await _locationService.ensureLocationPermission(context);
    if (!hasPermission) return;

    final activePos = ref.read(mapProvider).currentLocation ??
        LatLng(AppConstants.defaultMapLatitude, AppConstants.defaultMapLongitude);

    _animatedMapMove(activePos, 17.0);

    final result = await _locationService.getAccuratePosition(
      onFastFix: (fastResult) {
        if (mounted) {
          ref.read(mapProvider.notifier).setCurrentLocation(fastResult.position);
          _animatedMapMove(fastResult.position, 17.0);
        }
      },
    );

    if (result != null && mounted) {
      ref.read(mapProvider.notifier).setCurrentLocation(result.position);
      _animatedMapMove(result.position, 17.0);
      AppLogger.i('GPS thực tế: lat=${result.position.latitude}, lng=${result.position.longitude} (Độ chính xác: ${result.accuracy.toStringAsFixed(1)}m)');
    }
  }


}

