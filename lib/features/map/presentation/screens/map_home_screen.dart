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
import 'package:codoky/core/utils/helpers/bottom_sheet_helper.dart';
import 'package:codoky/features/map/data/models/osrm_route_model.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/features/map/presentation/providers/current_weather_provider.dart';
import 'package:codoky/features/map/presentation/widgets/map_bottom_sheet.dart';
import 'package:codoky/features/map/presentation/widgets/map_search_bar_widget.dart';
import 'package:codoky/features/map/presentation/widgets/map_toolbar_widget.dart';
import 'package:codoky/features/map/presentation/widgets/place_marker.dart';
import 'package:codoky/features/map/presentation/widgets/marker_constants.dart';
import 'package:codoky/features/map/presentation/widgets/vietnam_territory_layers.dart';
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
  VietnamTerritoryLayerState _layerState = const VietnamTerritoryLayerState();
  bool _showLayerPanel = false;
  bool _isManualLayerOverride = false;

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
  bool _is3dPerspective = true;
  bool _isGpsWeak = false;
  double? _currentHeading;

  void _toggle3dPerspective() {
    setState(() {
      _is3dPerspective = !_is3dPerspective;
    });
    if (!_is3dPerspective) {
      _mapController.rotate(0.0);
    } else {
      final heading = _currentHeading ?? 0.0;
      final headingDeg = heading * (180.0 / math.pi);
      _mapController.rotate(-headingDeg);
    }
  }

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
          _animatedMapMove(newPos, 17.5, duration: AppMotion.micro * 2, curve: AppMotion.standardCurve);
          if (_is3dPerspective && heading != null) {
            final headingDeg = heading * (180.0 / math.pi);
            _mapController.rotate(-headingDeg);
          }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                _handleZoomBasedTerritoryLayers(position.zoom);
                if (hasGesture && _isAutoFollowUser && state.activeRoute != null) {
                  setState(() {
                    _isAutoFollowUser = false;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _getTileUrlTemplate(state.mapTileStyle, isDark),
                userAgentPackageName: 'com.codoky.app',
                tileProvider: CachedDiskTileProvider(
                  userAgent: 'com.codoky.app',
                  maxCacheSizeBytes: 250 * 1024 * 1024,
                  maxCacheAge: const Duration(days: 30),
                ),
              ),
              // ─────────────────────────────────────────────────────────────
              // HỆ THỐNG ĐA LỚP LÃNH THỔ VIỆT NAM — chuẩn pháp lý & địa lý
              // EPSG:4326 (WGS84): tọa độ khóa chặt ở mọi mức zoom/pan.
              //  Layer 1: EEZ 200 hải lý (tuyên bố chủ quyền VN)
              //  Layer 2: Lãnh hải 12 hải lý
              //  Layer 3: Mask phủ mờ quốc gia khác (hole = lãnh thổ VN)
              //  Layer 4: Đường viền biên giới đất liền sáng
              // ─────────────────────────────────────────────────────────────
              if (_vietnamRings != null && _vietnamRings!.isNotEmpty)
                VietnamTerritoryLayers(
                  landRings: _vietnamRings!,
                  currentZoom: _mapController.camera.zoom,
                  showWorldMask: _layerState.showWorldMask,
                ),
              // Marker khẳng định chủ quyền quốc gia Hoàng Sa & Trường Sa của Việt Nam 🇻🇳
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(16.50, 112.00),
                    width: 240,
                    height: 48,
                    alignment: Alignment.center,
                    child: _buildIslandSovereigntyBadge('Quần đảo Hoàng Sa (Việt Nam)'),
                  ),
                  Marker(
                    point: const LatLng(9.50, 113.80),
                    width: 240,
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
                    // Tuyến đường đang được chọn (Active Route) -> Nét liền (Solid), màu Neon Laser Sky Blue ở Dark Mode
                    if (state.activeRoute != null)
                      Polyline(
                        points: state.activeRoute!.points,
                        strokeWidth: 5.5,
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF8B1522),
                        borderStrokeWidth: 2.0,
                        borderColor: isDark ? const Color(0xFF0288D1) : Colors.white,
                      ),
                  ],
                )
              else if (state.activeRoute != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: state.activeRoute!.points,
                      strokeWidth: 5.5,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF8B1522),
                      borderStrokeWidth: 2.0,
                      borderColor: isDark ? const Color(0xFF0288D1) : Colors.white,
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
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? const [Color(0xFF0288D1), Color(0xFF00B0FF)]
                              : const [Color(0xFF8B1522), Color(0xFFA61C31)],
                        ),
                        border: Border.all(color: Colors.white, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? const Color(0x6600B0FF) : const Color(0x408B1522),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
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
          // BottomSheet chỉ hiện ở chế độ chọn địa điểm ban đầu (khi chưa có route) với animation Slide + Fade
          Positioned(
            bottom: 96,
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
              child: (state.selectedPlace != null && !state.isNavigating && state.activeRoute == null)
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

          // Tầng 2: Thanh Điều Khiển Buồng Lái Đáy (Cockpit Bar) — đặt sát đáy màn hình khi đã có tuyến đường
          if (state.activeRoute != null && !state.isFetchingRoute)
            Positioned(
              bottom: 14,
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

          // Map Toolbar (GPS Recenter, Compass / Layers) đặt bên phải, không bị đè lên banner
          Positioned(
            top: state.activeRoute != null ? 136 : 88,
            right: 14,
            child: MapToolbarWidget(
              isAutoFollowUser: _isAutoFollowUser,
              is3dPerspective: _is3dPerspective,
              isLayerPanelOpen: _showLayerPanel,
              onToggleLayers: () {
                setState(() {
                  _showLayerPanel = !_showLayerPanel;
                });
              },
              onToggle3dPerspective: _toggle3dPerspective,
              onRecenterGps: () {
                setState(() {
                  _isAutoFollowUser = true;
                });
                final userPos = ref.read(mapProvider).currentLocation;
                if (userPos != null) {
                  _animatedMapMove(userPos, 17.5);
                }
              },
              onFitRouteOverview: state.activeRoute != null
                  ? () => _zoomToFitRoute(state.activeRoute!)
                  : null,
              onLocateUser: _goToCurrentLocation,
            ),
          ),

          // Layers legend panel — hiện khi _showLayerPanel = true
          if (_showLayerPanel && state.activeRoute == null)
            Positioned(
              top: 88,
              right: 64,
              child: _buildTerritoryLayerPanel(context),
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

    final etaTime = DateTime.now().add(
      Duration(seconds: activeRoute.durationSeconds.toInt()),
    );
    final etaLabel =
        '${etaTime.hour.toString().padLeft(2, '0')}:${etaTime.minute.toString().padLeft(2, '0')}';

    final placeName = (state.selectedPlace != null)
        ? (state.selectedPlace['name'] as String? ?? state.selectedPlace.name as String? ?? 'Cửa Chánh Tây')
        : 'Thành phố Huế';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222D) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row: Destination + Subtitle + "Đường tốt nhất" badge
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFB45309).withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  color: Color(0xFFFBBF24),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      placeName,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Thành phố Huế, Thừa Thiên Huế',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B).withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.40),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  context.l10n.bestRouteBadge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF34D399),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3 Metrics Cards (Khoảng cách · Thời gian (highlight) · Đến lúc)
          Row(
            children: [
              // 1. Khoảng cách
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF151922) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        context.l10n.distanceHeader,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeRoute.formattedDistance,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 2. Thời gian (Highlighted center card in Royal Blue)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.40),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.65),
                      width: 1.4,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        context.l10n.durationHeader,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF60A5FA),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeRoute.formattedDuration,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF93C5FD),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 3. Đến lúc
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF151922) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        context.l10n.etaHeader,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        etaLabel,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Bottom Action Row: Search along route input + Cancel Button
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showSearchAlongRouteSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF151922) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 16,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.l10n.searchAlongRoute,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  _stopLiveNavigation();
                  ref.read(mapProvider.notifier).clearRoute();
                  AppSnackBar.show(context, context.l10n.routeCancelled);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F1D1D).withValues(alpha: 0.38),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.55),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Color(0xFFF87171),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.cancel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF87171),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

    final turnIcon = _getTurnManeuverIcon(currentStep.type, currentStep.modifier);

    return GestureDetector(
      onTap: () => _showTurnByTurnListSheet(context, state.activeRoute!),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E222D) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.50 : 0.16),
              blurRadius: 26,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1. Khối Icon Rẽ Siêu To & Đậm Nét (Prominent Royal Blue Turn Box)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(turnIcon, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 14),

            // 2. Thông số khoảng cách lớn + Dòng chỉ dẫn đường trực quan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.remainingDistance(distText),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        Icons.navigation_rounded,
                        size: 13,
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          currentStep.instruction,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // 3. Cụm điều khiển: Loa giọng nói + Biển báo Tối đa 50 km/h
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nút Bật/Tắt Giọng Nói
                GestureDetector(
                  onTap: () => ref.read(mapProvider.notifier).toggleVoiceMute(),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Icon(
                      state.isVoiceMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      size: 19,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Biển báo Giới Hạn Tốc Độ Tối Đa P.127 (Chuẩn Quốc gia Việt Nam: Tròn trắng viền đỏ số đen)
                Tooltip(
                  message: context.l10n.speedLimitSignTooltip,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFDC2626),
                        width: 3.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.20),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '50',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTurnByTurnListSheet(BuildContext context, OsrmRoute route) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showAppBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.alt_route_rounded, color: Color(0xFF2563EB), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.turnByTurnSteps,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: route.steps.length,
                  separatorBuilder: (_, __) => Divider(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                    height: 1,
                  ),
                  itemBuilder: (ctx, i) {
                    final step = route.steps[i];
                    final stepIcon = _getTurnManeuverIcon(step.type, step.modifier);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFEFF6FF),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(stepIcon, color: const Color(0xFF2563EB), size: 18),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              step.instruction,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSearchAlongRouteSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showAppBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.searchAlongRoute,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildQuickPoiCategoryButton(
                    context: context,
                    icon: Icons.local_gas_station_rounded,
                    label: context.l10n.gasStations,
                    color: const Color(0xFFF59E0B),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ref.read(mapProvider.notifier).setSearchQuery('xăng');
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildQuickPoiCategoryButton(
                    context: context,
                    icon: Icons.local_parking_rounded,
                    label: context.l10n.parkingLots,
                    color: const Color(0xFF3B82F6),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ref.read(mapProvider.notifier).setSearchQuery('bãi đỗ');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildQuickPoiCategoryButton(
                    context: context,
                    icon: Icons.coffee_rounded,
                    label: context.l10n.coffeeSpots,
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ref.read(mapProvider.notifier).filterByCategory('restaurant');
                    },
                  ),
                  const SizedBox(width: 10),
                  _buildQuickPoiCategoryButton(
                    context: context,
                    icon: Icons.restaurant_rounded,
                    label: context.l10n.catRestaurant,
                    color: const Color(0xFFEC4899),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ref.read(mapProvider.notifier).filterByCategory('restaurant');
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickPoiCategoryButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _zoomToFitRoute(OsrmRoute route) {
    if (route.points.isEmpty) return;
    setState(() {
      _isAutoFollowUser = false;
    });

    final state = ref.read(mapProvider);
    final userPos = state.currentLocation;
    LatLng? destPos;
    final place = state.selectedPlace;
    if (place != null) {
      if (place is Map) {
        final lat = place['latitude'] ?? place['lat'];
        final lng = place['longitude'] ?? place['lng'] ?? place['lon'];
        if (lat != null && lng != null) {
          destPos = LatLng((lat as num).toDouble(), (lng as num).toDouble());
        }
      } else {
        try {
          final lat = (place as dynamic).latitude ?? (place as dynamic).lat;
          final lng = (place as dynamic).longitude ?? (place as dynamic).lng;
          if (lat != null && lng != null) {
            destPos = LatLng((lat as num).toDouble(), (lng as num).toDouble());
          }
        } catch (_) {}
      }
    }
    destPos ??= (route.points.isNotEmpty ? route.points.last : null);

    // Tập hợp 100% các điểm quan trọng: Tọa độ xe GPS + Toàn bộ polyline OSRM + Điểm đích đến
    final List<LatLng> allBoundsPoints = [
      if (userPos != null) userPos,
      ...route.points,
      if (destPos != null) destPos,
    ];

    if (allBoundsPoints.isEmpty) return;

    final rawBounds = LatLngBounds.fromPoints(allBoundsPoints);
    final latSpan = (rawBounds.north - rawBounds.south).abs();
    final lngSpan = (rawBounds.east - rawBounds.west).abs();

    // Buffer đệm 15-20% theo cả 4 hướng để các Marker Callout Tag không bị cắt mép
    final latBuffer = math.max(latSpan * 0.18, 0.0035);
    final lngBuffer = math.max(lngSpan * 0.18, 0.0035);

    final expandedBounds = LatLngBounds(
      LatLng(rawBounds.south - latBuffer, rawBounds.west - lngBuffer),
      LatLng(rawBounds.north + latBuffer, rawBounds.east + lngBuffer),
    );

    // Tính toán lề an toàn chuẩn xác theo Safe Area và chiều cao thực tế của Banner đỉnh & Cockpit đáy
    final mediaQuery = MediaQuery.of(context);
    final topSafePadding = mediaQuery.padding.top + 140.0;
    final bottomSafePadding = mediaQuery.padding.bottom + 260.0;

    final fitted = CameraFit.bounds(
      bounds: expandedBounds,
      padding: EdgeInsets.fromLTRB(54, topSafePadding, 54, bottomSafePadding),
      maxZoom: 16.5,
      minZoom: 11.5,
    ).fit(_mapController.camera);

    final clampedZoom = fitted.zoom.clamp(11.5, 16.5);

    _animatedMapMove(
      fitted.center,
      clampedZoom,
      duration: const Duration(milliseconds: 750),
      curve: Curves.easeInOutCubic,
    );
  }

  IconData _getTurnManeuverIcon(String type, String modifier) {
    final mod = modifier.toLowerCase();
    final typ = type.toLowerCase();

    if (typ == 'arrive' || typ.contains('arrive')) {
      return Icons.location_on_rounded;
    }
    if (mod.contains('u-turn') || mod.contains('uturn') || mod.contains('vòng lui') || mod.contains('quay đầu')) {
      return mod.contains('left') ? Icons.u_turn_left_rounded : Icons.u_turn_right_rounded;
    }
    if (typ.contains('rotary') || typ.contains('roundabout') || mod.contains('bùng binh') || mod.contains('vòng xuyến')) {
      return mod.contains('left') ? Icons.roundabout_left_rounded : Icons.roundabout_right_rounded;
    }
    if (mod.contains('sharp left')) {
      return Icons.turn_sharp_left_rounded;
    }
    if (mod.contains('sharp right')) {
      return Icons.turn_sharp_right_rounded;
    }
    if (mod.contains('slight left')) {
      return Icons.turn_slight_left_rounded;
    }
    if (mod.contains('slight right')) {
      return Icons.turn_slight_right_rounded;
    }
    if (mod.contains('left')) {
      return Icons.turn_left_rounded;
    }
    if (mod.contains('right')) {
      return Icons.turn_right_rounded;
    }
    if (mod.contains('straight') || typ.contains('continue') || typ.contains('depart')) {
      return Icons.straight_rounded;
    }
    return Icons.straight_rounded;
  }

  Marker _buildUserLocationMarker(LatLng position) {
    final opacityFactor = _isGpsWeak ? 0.5 : 1.0;
    final state = ref.read(mapProvider);
    final isNavigating = state.activeRoute != null;

    final effectiveHeading = _currentHeading ??
        (state.activeRoute != null && state.activeRoute!.points.length > 1
            ? _calculateBearing(position, state.activeRoute!.points[1])
            : null);

    return Marker(
      point: position,
      width: isNavigating ? 84 : 60,
      height: isNavigating ? 84 : 60,
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
                // 1. Radar Pulse Wave phát sáng tỏa tròn
                Transform.scale(
                  scale: scale,
                  child: Container(
                    width: isNavigating ? 64 : 46,
                    height: isNavigating ? 64 : 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isGpsWeak
                          ? const Color(0xFFF59E0B).withValues(alpha: opacity * 0.35)
                          : (isNavigating
                              ? const Color(0xFF38BDF8).withValues(alpha: opacity * 0.40)
                              : const Color(0xFF1E88E5).withValues(alpha: opacity * 0.35)),
                    ),
                  ),
                ),

                // 2. Chùm sáng dẫn đường 3D chiếu về phía trước (Forward Vision Beam) khi đang lái xe
                if (isNavigating && effectiveHeading != null)
                  Transform.rotate(
                    angle: effectiveHeading,
                    child: Transform.translate(
                      offset: const Offset(0, -22),
                      child: Container(
                        width: 44,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0, 1.0),
                            radius: 0.9,
                            colors: [
                              const Color(0xFF38BDF8).withValues(alpha: 0.55),
                              const Color(0xFF38BDF8).withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                // 3. Vòng bảo vệ lõi định vị
                Container(
                  width: isNavigating ? 42 : 34,
                  height: isNavigating ? 42 : 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isGpsWeak
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                        : (isNavigating
                            ? const Color(0xFF0284C7).withValues(alpha: 0.25)
                            : const Color(0xFF1E88E5).withValues(alpha: 0.2)),
                    border: Border.all(
                      color: _isGpsWeak
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.8)
                          : (isNavigating
                              ? const Color(0xFF38BDF8).withValues(alpha: 0.85)
                              : const Color(0xFF1E88E5).withValues(alpha: 0.6)),
                      width: 1.5,
                    ),
                  ),
                ),

                // 4. Con trỏ Mũi Tên Dẫn Đường 3D (Aerodynamic 3D Navigation Arrow Puck)
                if (isNavigating || effectiveHeading != null)
                  Transform.rotate(
                    angle: effectiveHeading ?? 0.0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF38BDF8), // Cyan phát sáng dạ quang ở chóp
                            Color(0xFF2563EB), // Royal Blue đậm ở thân
                            Color(0xFF1D4ED8), // Deep Blue ở chân
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.6),
                            blurRadius: 8,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.navigation_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else ...[
                  // Khi ở chế độ xem bản đồ 2D tĩnh
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
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Nút nhỏ bật/tắt panel lớp lãnh thổ Việt Nam (EEZ, lãnh hải, mask)
  Widget _buildLayersToggleButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => setState(() => _showLayerPanel = !_showLayerPanel),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _showLayerPanel
              ? const Color(0xFF1565C0)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _showLayerPanel
                ? const Color(0xFF1565C0)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.black.withValues(alpha: 0.08)),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          Icons.layers_rounded,
          size: 18,
          color: _showLayerPanel
              ? Colors.white
              : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF2563EB)),
        ),
      ),
    );
  }

  void _handleZoomBasedTerritoryLayers(double zoom) {
    if (_isManualLayerOverride) return;

    // Zoom level rules:
    //  - zoom < 4.0: show EEZ, hide territorial sea (too small to render clearly)
    //  - 4.0 <= zoom <= 8.0: show EEZ + territorial sea
    //  - zoom > 8.0: hide EEZ (out of viewport), keep territorial sea + land border
    final shouldShowEez = zoom <= 8.0;
    final shouldShowSea = zoom >= 4.0;

    if (_layerState.showEez != shouldShowEez ||
        _layerState.showTerritorialSea != shouldShowSea) {
      setState(() {
        _layerState = _layerState.copyWith(
          showEez: shouldShowEez,
          showTerritorialSea: shouldShowSea,
        );
      });
    }
  }

  /// Toggle một trạng thái lớp trong [VietnamTerritoryLayerState].
  void _toggleLayer({bool? eez, bool? territorialSea, bool? worldMask}) {
    setState(() {
      _isManualLayerOverride = true;
      _layerState = _layerState.copyWith(
        showEez: eez ?? _layerState.showEez,
        showTerritorialSea: territorialSea ?? _layerState.showTerritorialSea,
        showWorldMask: worldMask ?? _layerState.showWorldMask,
      );
    });
  }

  /// Legend + toggle panel hiển thị / ẩn các lớp lãnh thổ Việt Nam.
  Widget _buildTerritoryLayerPanel(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: 210,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xCC0F172A)
            : const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1565C0).withValues(alpha: 0.3),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🗺️ ${l10n.territoryLayersTitle}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(width: 8),
              if (_isManualLayerOverride)
                GestureDetector(
                  onTap: () => setState(() {
                    _isManualLayerOverride = false;
                    _handleZoomBasedTerritoryLayers(_mapController.camera.zoom);
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Auto',
                      style: TextStyle(fontSize: 10, color: Color(0xFF1565C0), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          _buildLayerToggleRow(
            color: const Color(0xFF1565C0),
            label: l10n.eezLayerTitle,
            isOn: _layerState.showEez,
            onToggle: (v) => _toggleLayer(eez: v),
          ),
          _buildLayerToggleRow(
            color: const Color(0xFF0288D1),
            label: l10n.territorialSeaTitle,
            isOn: _layerState.showTerritorialSea,
            onToggle: (v) => _toggleLayer(territorialSea: v),
          ),
          _buildLayerToggleRow(
            color: const Color(0x88000000),
            label: l10n.worldMaskTitle,
            isOn: _layerState.showWorldMask,
            onToggle: (v) => _toggleLayer(worldMask: v),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerToggleRow({
    required Color color,
    required String label,
    required bool isOn,
    required ValueChanged<bool> onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: color, width: 1.2),
            ),
          ),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 11.5)),
          ),
          Transform.scale(
            scale: 0.75,
            child: Switch.adaptive(
              value: isOn,
              onChanged: onToggle,
              activeThumbColor: const Color(0xFF1565C0),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: Color(0xFF0F172A),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              (place['name'] as String? ?? place.name as String? ?? ''),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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

  String _getTileUrlTemplate(MapTileStyle? style, bool isDark) {
    if (style != null && style != MapTileStyle.osmStandard) {
      switch (style) {
        case MapTileStyle.cartoVoyager:
          return 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
        case MapTileStyle.cartoDark:
          return 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
        case MapTileStyle.cartoPositron:
          return 'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';
        case MapTileStyle.osmStandard:
          return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      }
    }
    return isDark
        ? 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
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

