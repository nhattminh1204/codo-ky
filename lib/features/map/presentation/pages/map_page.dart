import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:codoky/core/config/constants/app_constants.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/features/map/presentation/widgets/map_bottom_sheet.dart';
import 'package:codoky/features/map/presentation/widgets/place_marker.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
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
          if (state.selectedPlace != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: MapBottomSheet(
                place: state.selectedPlace!,
                onClose: () => ref.read(mapProvider.notifier).clearSelection(),
                onNavigate: () {
                  // TODO: Open navigation
                },
              ),
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 6,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF9B1B30), size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'CodoKy - Khám phá Huế',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF9B1B30),
                                    ),
                              ),
                              Text(
                                '${state.places.length} địa điểm đang hiển thị',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[700],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (state.isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
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
                      _buildFilterChip('restaurant', 'Quán ăn / Nhà hàng', state),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          heroTag: 'locate',
          onPressed: _goToCurrentLocation,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF9B1B30),
          child: const Icon(Icons.my_location),
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
      backgroundColor: Colors.white.withValues(alpha: 0.95),
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

  void _showFilterDialog() {
    // TODO: Show filter dialog
  }
}