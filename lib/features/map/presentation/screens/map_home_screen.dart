import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:codoky/core/config/constants/app_constants.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/features/map/presentation/widgets/map_bottom_sheet.dart';
import 'package:codoky/features/map/presentation/widgets/place_marker.dart';
import 'package:codoky/shared/widgets/glass_container.dart';

class MapHomeScreen extends ConsumerStatefulWidget {
  const MapHomeScreen({super.key});

  @override
  ConsumerState<MapHomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends ConsumerState<MapHomeScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapProvider.notifier).loadPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 1. OpenStreetMap Layer (No Google Maps API Key required)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                AppConstants.defaultMapLatitude,
                AppConstants.defaultMapLongitude,
              ),
              initialZoom: AppConstants.defaultMapZoom.toDouble(),
              onTap: (_, __) => ref.read(mapProvider.notifier).clearSelection(),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.codoky.app',
              ),
              MarkerLayer(
                markers: _buildMarkers(state.places, state.selectedPlace),
              ),
            ],
          ),

          // 2. Selected Place Bottom Sheet
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

          // 3. Floating Glassmorphic Search & Filter Bar Header
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassContainer(
                  blur: 16,
                  opacity: 0.88,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9B1B30),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9B1B30).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'CodoKy Map',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9B1B30),
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${state.places.length} địa điểm đang hiển thị',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (state.isLoading)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF9B1B30),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'Tất cả', state),
                      const SizedBox(width: 8),
                      _buildFilterChip('attraction', 'Địa điểm', state),
                      const SizedBox(width: 8),
                      _buildFilterChip('tomb', 'Lăng tẩm', state),
                      const SizedBox(width: 8),
                      _buildFilterChip('temple', 'Chùa', state),
                      const SizedBox(width: 8),
                      _buildFilterChip('restaurant', 'Quán ăn', state),
                    ],
                  ),
                ),
              ],
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

  List<Marker> _buildMarkers(List<dynamic> places, dynamic selectedPlace) {
    final markers = <Marker>[];
    for (final place in places) {
      final lat = place['latitude'] as double? ?? (place.latitude as double?);
      final lng = place['longitude'] as double? ?? (place.longitude as double?);
      final category = place['category'] as String? ?? (place.category as String? ?? 'attraction');
      final rating = (place['rating'] as num?)?.toDouble() ?? 0.0;
      final isSelected = selectedPlace != null && (place['id'] == selectedPlace['id']);

      if (lat != null && lng != null) {
        markers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 48,
            height: 48,
            child: GestureDetector(
              onTap: () {
                ref.read(mapProvider.notifier).selectPlace(place);
              },
              child: PlaceMarker(
                category: category,
                rating: rating,
                isSelected: isSelected,
              ),
            ),
          ),
        );
      }
    }
    return markers;
  }

  void _goToCurrentLocation() {
    _mapController.move(
      LatLng(
        AppConstants.defaultMapLatitude,
        AppConstants.defaultMapLongitude,
      ),
      AppConstants.defaultMapZoom.toDouble(),
    );
  }
}
