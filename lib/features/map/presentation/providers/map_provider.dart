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
  final String searchQuery;
  final bool isLoading;

  const MapState({
    this.allPlaces = const [],
    this.places = const [],
    this.selectedPlace,
    this.currentLocation,
    this.selectedCategory,
    this.searchQuery = '',
    this.isLoading = false,
  });

  MapState copyWith({
    List<dynamic>? allPlaces,
    List<dynamic>? places,
    dynamic selectedPlace,
    LatLng? currentLocation,
    String? selectedCategory,
    String? searchQuery,
    bool? isLoading,
  }) {
    return MapState(
      allPlaces: allPlaces ?? this.allPlaces,
      places: places ?? this.places,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      currentLocation: currentLocation ?? this.currentLocation,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
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
      _applyFilters();
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
        },
        {
          'id': '2',
          'name': 'Thiên Mụ Pagoda',
          'category': 'temple',
          'latitude': 16.4439,
          'longitude': 107.5833,
          'address': 'Hương Long, Huế',
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
    final cat = (category == null || category == 'all') ? null : category;
    state = state.copyWith(selectedCategory: cat);
    _applyFilters();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void _applyFilters() {
    final category = state.selectedCategory;
    final query = state.searchQuery.trim().toLowerCase();

    final filtered = state.allPlaces.where((p) {
      final catMatch = category == null ||
          ((p['category'] as String?)?.toLowerCase() == category.toLowerCase());

      final name = (p['name'] as String?)?.toLowerCase() ?? '';
      final address = (p['address'] as String?)?.toLowerCase() ?? '';
      final queryMatch = query.isEmpty ||
          name.contains(query) ||
          address.contains(query);

      return catMatch && queryMatch;
    }).toList();

    state = state.copyWith(places: filtered);
  }

  void setCurrentLocation(LatLng location) {
    state = state.copyWith(currentLocation: location);
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});