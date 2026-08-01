import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:codoky/core/config/constants/app_constants.dart';
import 'package:codoky/core/theme/motion.dart';
import 'package:codoky/core/utils/helpers/app_snackbar.dart';
import 'package:vibration/vibration.dart';
import 'package:codoky/core/logging/app_logger.dart';
import 'package:codoky/core/services/audio/tts_service.dart';
import 'package:codoky/core/services/location/location_service.dart';
import 'package:codoky/features/map/data/datasources/cached_disk_tile_provider.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/features/map/presentation/widgets/map_bottom_sheet.dart';
import 'package:codoky/features/map/presentation/widgets/map_search_bar_widget.dart';
import 'package:codoky/features/map/presentation/widgets/map_toolbar_widget.dart';
import 'package:codoky/features/map/presentation/widgets/place_marker.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class MapHomeScreen extends ConsumerStatefulWidget {
  const MapHomeScreen({super.key});

  @override
  ConsumerState<MapHomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends ConsumerState<MapHomeScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final LocationService _locationService;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

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
      }
    } catch (e) {
      AppLogger.w('Location permission or fetch warning: $e');
    }
  }

  bool _isLiveTracking = false;
  bool _isAutoFollowUser = true;
  bool _isGpsWeak = false;
  double? _lastGpsAccuracy;
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
      final text = 'Sau ${distMeters.round()} mét nữa, ${currentStep.instruction}';
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
      TtsService().speak('Đang tính lại tuyến đường mới');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 Đang tự động tính lại tuyến mới...'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFFFF7A00),
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
          _lastGpsAccuracy = accuracy;
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
      TtsService().speak('Bạn đã đến điểm đến! Chúc bạn có trải nghiệm tuyệt vời tại Cố đô Huế.');
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
              SizedBox(width: 10),
              Text('Đã Đến Điểm Đến!'),
            ],
          ),
          content: const Text(
            '🎉 Bạn đã đến địa điểm an toàn. Chúc bạn có những phút giây khám phá Cố đô Huế tuyệt vời!',
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B1B30),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Đóng'),
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
    if (_previousCameraCenter != null && _previousCameraZoom != null) {
      _animatedMapMove(
        _previousCameraCenter!,
        _previousCameraZoom!,
        curve: AppMotion.standardCurve,
        duration: AppMotion.standard,
      );
      _previousCameraCenter = null;
      _previousCameraZoom = null;
    }
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
              onTap: (_, _) => _clearSelectionAndZoomOut(),
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
                  markers: _buildMarkers(state.places, state.selectedPlace),
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
          if (state.selectedPlace != null)
            Positioned(
              bottom: 96,
              left: 14,
              right: 14,
              child: MapBottomSheet(
                place: state.selectedPlace!,
                onClose: _clearSelectionAndZoomOut,
                onNavigate: () async {
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
                      final err = ref.read(mapProvider).routeErrorMessage ?? 'Không thể lấy chỉ đường OSRM';
                      AppSnackBar.show(context, err, isError: true);
                    }
                  } else {
                    // Preview mode 2: Start actual live navigation
                    ref.read(mapProvider.notifier).clearSelection();
                    _startLiveNavigation();
                  }
                },
              ),
            ),

          // Top Navigation & Overlay Banners (Turn-by-turn instruction, GPS weak status, OSRM fetching, error)
          Positioned(
            top: state.activeRoute != null ? 48 : 135,
            left: 14,
            right: 70,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.activeRoute != null && state.activeRoute!.steps.isNotEmpty && !state.isFetchingRoute)
                  _buildTurnByTurnBanner(state),

                if (_isGpsWeak && state.activeRoute != null) ...[
                  const SizedBox(height: 8),
                  _buildGlassOverlay(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.gps_not_fixed_rounded, color: Colors.orangeAccent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _lastGpsAccuracy != null
                                ? 'Đang chờ tín hiệu GPS chính xác (bán kính ${_lastGpsAccuracy!.toStringAsFixed(0)}m)...'
                                : 'Đang kết nối tín hiệu vệ tinh GPS...',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (state.isFetchingRoute) ...[
                  const SizedBox(height: 8),
                  _buildGlassOverlay(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFFF7A00)),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Đang lấy dữ liệu chỉ đường OSRM...',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E1E1E)),
                        ),
                      ],
                    ),
                  ),
                ],

                if (state.errorMessage != null && !state.isLoading) ...[
                  const SizedBox(height: 8),
                  _buildGlassOverlay(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9B1B30),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            ref.read(mapProvider.notifier).loadPlaces(forceRefresh: true);
                          },
                          child: const Text(
                            'Thử lại',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (state.activeRoute != null && !state.isFetchingRoute)
            Positioned(
              bottom: 90,
              left: 16,
              right: 16,
              child: _buildGlassOverlay(
                quality: GlassQuality.premium,
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                glassColor: const Color(0x22FF7A00),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF7A00).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.navigation_rounded, color: Color(0xFFFF7A00), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Đang chỉ đường',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                state.activeRoute!.formattedDistance,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E1E1E)),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  state.activeRoute!.formattedDuration,
                                  style: const TextStyle(color: Color(0xFF047857), fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildMiniTravelModeChip('motorbike', '🛵 Xe máy', state.travelMode),
                              const SizedBox(width: 4),
                              _buildMiniTravelModeChip('driving', '🚗 Ô tô', state.travelMode),
                              const SizedBox(width: 4),
                              _buildMiniTravelModeChip('walking', '🚶 Đi bộ', state.travelMode),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton.icon(
                      onPressed: () {
                        _stopLiveNavigation();
                        ref.read(mapProvider.notifier).clearRoute();
                        AppSnackBar.show(context, 'Đã hủy lộ trình chỉ đường');
                      },

                      icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                      label: const Text(
                        'Hủy',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),


          if (state.activeRoute == null)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: MapSearchBarWidget(),
            ),
          Positioned(
            top: state.activeRoute != null ? 115 : 175,
            right: 14,
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
        ],
      ),
    );
  }

  Widget _buildMiniTravelModeChip(String mode, String label, String currentMode) {
    final isSelected = mode == currentMode;
    return GestureDetector(
      onTap: () {
        ref.read(mapProvider.notifier).setTravelMode(mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF5E36) : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF5E36) : const Color(0xFFCBD5E1),
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF5E36).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassOverlay({
    required Widget child,
    required double borderRadius,
    EdgeInsetsGeometry? padding,
    Color? glassColor,
    GlassQuality quality = GlassQuality.standard,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.2 : 0.4),
          width: 1.2,
        ),
      ),
      child: GlassContainer(
        useOwnLayer: true,
        quality: quality,
        shape: LiquidRoundedRectangle(borderRadius: borderRadius),
        padding: padding,
        settings: glassColor != null ? LiquidGlassSettings(glassColor: glassColor) : null,
        child: child,
      ),
    );
  }

  Widget _buildTurnByTurnBanner(MapState state) {
    final steps = state.activeRoute!.steps;
    final idx = state.currentStepIndex.clamp(0, steps.length - 1);
    final currentStep = steps[idx];

    final currentPos = state.currentLocation ?? const LatLng(16.4637, 107.5909);
    final distMeters = _calculateDistanceMeters(currentPos, currentStep.location);
    final distText = distMeters >= 1000
        ? '${(distMeters / 1000).toStringAsFixed(1)} km'
        : '${distMeters.round()} m';

    IconData turnIcon = Icons.straight_rounded;
    if (currentStep.type == 'arrive') {
      turnIcon = Icons.location_on_rounded;
    } else if (currentStep.modifier.contains('left')) {
      turnIcon = Icons.turn_left_rounded;
    } else if (currentStep.modifier.contains('right')) {
      turnIcon = Icons.turn_right_rounded;
    }

    return _buildGlassOverlay(
      quality: GlassQuality.premium,
      borderRadius: 18,
      glassColor: const Color(0x1A9B1B30),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF9B1B30),
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
                  'Còn $distText',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF9B1B30),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentStep.instruction,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E1E1E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(mapProvider.notifier).toggleVoiceMute();
            },
            icon: Icon(
              state.isVoiceMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: state.isVoiceMuted ? Colors.grey : const Color(0xFFFF5E36),
              size: 24,
            ),
            tooltip: state.isVoiceMuted ? 'Bật giọng nói' : 'Tắt giọng nói',
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


  List<Marker> _buildMarkers(List<dynamic> places, dynamic selectedPlace) {
    final markers = <Marker>[];
    for (final place in places) {
      final lat = place['latitude'] as double? ?? (place.latitude as double?);
      final lng = place['longitude'] as double? ?? (place.longitude as double?);
      final category = place['category'] as String? ?? (place.category as String? ?? 'attraction');
      final isSelected = selectedPlace != null && (place['id'] == selectedPlace['id']);

      if (lat != null && lng != null) {
        final targetPos = LatLng(lat, lng);
        markers.add(
          Marker(
            point: targetPos,
            width: isSelected ? 130 : 52,
            height: isSelected ? 86 : 58,
            alignment: Alignment.topCenter,
            rotate: true,
            child: GestureDetector(
              onTap: () {
                if (_previousCameraCenter == null) {
                  _previousCameraCenter = _mapController.camera.center;
                  _previousCameraZoom = _mapController.camera.zoom;
                }
                ref.read(mapProvider.notifier).selectPlace(place);
                _animatedMapMove(
                  targetPos,
                  16.5,
                  curve: AppMotion.emphasizedCurve,
                  duration: AppMotion.emphasized,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlaceMarker(
                    category: category,
                    isSelected: isSelected,
                    style: ref.watch(mapProvider).markerStyle,
                  ),
                  if (isSelected)
                    Container(
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
                ],
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

