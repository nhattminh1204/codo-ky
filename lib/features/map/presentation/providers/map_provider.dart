import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class MapState {
  final List<dynamic> allPlaces;
  final List<dynamic> places;
  final dynamic selectedPlace;
  final LatLng? currentLocation;
  final String? selectedCategory;
  final bool isLoading;

  const MapState({
    this.allPlaces = const [],
    this.places = const [],
    this.selectedPlace,
    this.currentLocation,
    this.selectedCategory,
    this.isLoading = false,
  });

  MapState copyWith({
    List<dynamic>? allPlaces,
    List<dynamic>? places,
    dynamic selectedPlace,
    LatLng? currentLocation,
    String? selectedCategory,
    bool? isLoading,
  }) {
    return MapState(
      allPlaces: allPlaces ?? this.allPlaces,
      places: places ?? this.places,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      currentLocation: currentLocation ?? this.currentLocation,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(const MapState());

  Future<void> loadPlaces() async {
    state = state.copyWith(isLoading: true);

    try {
      final jsonString = await rootBundle.loadString('assets/data/hue_places_seed.json');
      final List<dynamic> decoded = json.decode(jsonString);

      state = state.copyWith(
        allPlaces: decoded,
        places: decoded,
        isLoading: false,
        currentLocation: const LatLng(16.4637, 107.5909),
      );
    } catch (e) {
      // Fallback default list if asset fails
      final fallback = [
        {
          'id': '1',
          'name': 'Huế Imperial City',
          'category': 'attraction',
          'latitude': 16.4637,
          'longitude': 107.5909,
          'address': 'Thuận Thành, Huế',
          'rating': 4.8,
        },
        {
          'id': '2',
          'name': 'Thiên Mụ Pagoda',
          'category': 'temple',
          'latitude': 16.4439,
          'longitude': 107.5833,
          'address': 'Hương Long, Huế',
          'rating': 4.7,
        },
      ];

      state = state.copyWith(
        allPlaces: fallback,
        places: fallback,
        isLoading: false,
        currentLocation: const LatLng(16.4637, 107.5909),
      );
    }
  }

  void selectPlace(dynamic place) {
    state = state.copyWith(selectedPlace: place);
  }

  void clearSelection() {
    state = state.copyWith(selectedPlace: null);
  }

  void filterByCategory(String? category) {
    if (category == null || category == 'all') {
      state = state.copyWith(
        selectedCategory: null,
        places: state.allPlaces,
      );
    } else {
      final filtered = state.allPlaces.where((p) {
        final cat = (p['category'] as String?)?.toLowerCase() ?? '';
        return cat == category.toLowerCase();
      }).toList();

      state = state.copyWith(
        selectedCategory: category,
        places: filtered,
      );
    }
  }

  void setCurrentLocation(LatLng location) {
    state = state.copyWith(currentLocation: location);
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});