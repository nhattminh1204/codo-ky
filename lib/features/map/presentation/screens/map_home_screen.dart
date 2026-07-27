import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:codoky/core/config/constants/app_constants.dart';
import 'package:codoky/core/logging/app_logger.dart';
import 'package:codoky/core/services/location/location_service.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/features/map/presentation/screens/filter_category_sheet.dart';
import 'package:codoky/features/map/presentation/widgets/map_bottom_sheet.dart';
import 'package:codoky/features/map/presentation/widgets/place_marker.dart';
import 'package:codoky/shared/widgets/glass_container.dart';

class MapHomeScreen extends ConsumerStatefulWidget {
  const MapHomeScreen({super.key});

  @override
  ConsumerState<MapHomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends ConsumerState<MapHomeScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
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
      final res = await _locationService.getAccuratePosition();
      if (res != null && mounted) {
        ref.read(mapProvider.notifier).setCurrentLocation(res.position);
      }
    } catch (e) {
      AppLogger.w('Location permission or fetch warning: $e');
    }
  }

  @override
  void dispose() {
    _locationService.stopLiveTracking();
    _searchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = _mapController.camera;
    final latTween = Tween<double>(begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(
      duration: const Duration(milliseconds: 950),
      vsync: this,
    );

    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);

    return Scaffold(
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
              onTap: (_, _) => ref.read(mapProvider.notifier).clearSelection(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.codoky.app',
              ),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  builder: (context, markers) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFF9B1B30),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
              MarkerLayer(
                markers: _buildMarkers(state.places, state.selectedPlace),
              ),
              const SimpleAttributionWidget(
                source: Text('© OpenStreetMap contributors'),
              ),
            ],
          ),

          if (state.selectedPlace != null)
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: MapBottomSheet(
                place: state.selectedPlace!,
                onClose: () => ref.read(mapProvider.notifier).clearSelection(),
                onNavigate: () {},
              ),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassContainer(
                    blur: 15,
                    opacity: 0.85,
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  ref.read(mapProvider.notifier).setSearchQuery(val);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Tìm kiếm địa điểm Huế...',
                                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                                  border: InputBorder.none,
                                  isDense: true,
                                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9B1B30), size: 22),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                          onPressed: () {
                                            _searchController.clear();
                                            ref.read(mapProvider.notifier).setSearchQuery('');
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            if (state.isLoading)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  color: Color(0xFF9B1B30),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9B1B30).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${state.places.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF9B1B30),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => context.push('/profile'),
                              child: CircleAvatar(
                                radius: 17,
                                backgroundColor: const Color(0xFF9B1B30),
                                backgroundImage: ref.watch(authProvider).user?.avatarUrl != null
                                    ? NetworkImage(ref.watch(authProvider).user!.avatarUrl!)
                                    : null,
                                child: ref.watch(authProvider).user?.avatarUrl == null
                                    ? const Icon(Icons.person, size: 20, color: Colors.white)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const FilterCategorySheet(),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: state.selectedCategories.isNotEmpty ? const Color(0xFF9B1B30) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF9B1B30).withValues(alpha: 0.4)),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.tune_rounded, size: 16, color: state.selectedCategories.isNotEmpty ? Colors.white : const Color(0xFF9B1B30)),
                                const SizedBox(width: 4),
                                Text(
                                  state.selectedCategories.isNotEmpty ? 'Lọc (${state.selectedCategories.length})' : 'Bộ lọc',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: state.selectedCategories.isNotEmpty ? Colors.white : const Color(0xFF9B1B30)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildFilterChip('all', 'Tất cả', state),
                        const SizedBox(width: 8),
                        _buildFilterChip('restaurant', 'Quán ăn', state),
                        const SizedBox(width: 8),
                        _buildFilterChip('attraction', 'Địa điểm', state),
                        const SizedBox(width: 8),
                        _buildFilterChip('tomb', 'Lăng tẩm', state),
                        const SizedBox(width: 8),
                        _buildFilterChip('temple', 'Chùa', state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          heroTag: 'locate',
          onPressed: _goToCurrentLocation,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF9B1B30),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.my_location_rounded),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String categoryId, String label, MapState state) {
    final isSelected = (state.selectedCategory == categoryId) ||
        (state.selectedCategory == null && categoryId == 'all');

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF9B1B30),
      backgroundColor: Colors.white.withValues(alpha: 0.92),
      elevation: isSelected ? 4 : 2,
      shadowColor: Colors.black26,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      onSelected: (_) {
        ref.read(mapProvider.notifier).filterByCategory(categoryId);
      },
    );
  }

  Marker _buildUserLocationMarker(LatLng position) {
    return Marker(
      point: position,
      width: 60,
      height: 60,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + (_pulseController.value * 0.45);
          final opacity = (1.0 - _pulseController.value).clamp(0.0, 1.0);

          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer expanding pulse wave
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E88E5).withValues(alpha: opacity * 0.35),
                  ),
                ),
              ),
              // Glowing aura ring
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E88E5).withValues(alpha: 0.2),
                  border: Border.all(
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
              ),
              // Inner glossy white disc with soft shadow
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
              // Blue gradient core point
              Container(
                width: 13,
                height: 13,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ],
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
        markers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 44,
            height: 44,
            child: GestureDetector(
              onTap: () {
                ref.read(mapProvider.notifier).selectPlace(place);
              },
              child: PlaceMarker(
                category: category,
                isSelected: isSelected,
              ),
            ),
          ),
        );
      }
    }
    return markers;
  }

  Future<void> _goToCurrentLocation() async {
    // 1. Instantly get current active location
    final activePos = ref.read(mapProvider).currentLocation ??
        LatLng(AppConstants.defaultMapLatitude, AppConstants.defaultMapLongitude);

    // 2. Guarantee immediate smooth animated zoom to 17.0 level
    _animatedMapMove(activePos, 17.0);

    // 3. Acquire fresh high-accuracy GPS fix in background
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã phóng to vị trí GPS: (${result.position.latitude.toStringAsFixed(4)}, ${result.position.longitude.toStringAsFixed(4)}) [±${result.accuracy.toStringAsFixed(0)}m]',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      final hasPermission = await _locationService.checkPermission();
      if (!hasPermission && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã phóng to vị trí hiện tại. Vui lòng bật GPS để định vị vệ tinh chính xác.'),
            action: SnackBarAction(
              label: 'Cài đặt',
              onPressed: () {
                _locationService.openAppSettings();
              },
            ),
          ),
        );
      }
    }
  }
}
