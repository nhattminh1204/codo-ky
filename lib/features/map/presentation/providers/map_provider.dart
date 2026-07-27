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
  final Set<String> selectedCategories;
  final String searchQuery;
  final bool isLoading;

  const MapState({
    this.allPlaces = const [],
    this.places = const [],
    this.selectedPlace,
    this.currentLocation,
    this.selectedCategory,
    this.selectedCategories = const {},
    this.searchQuery = '',
    this.isLoading = false,
  });

  MapState copyWith({
    List<dynamic>? allPlaces,
    List<dynamic>? places,
    dynamic selectedPlace,
    LatLng? currentLocation,
    String? selectedCategory,
    Set<String>? selectedCategories,
    bool clearCategory = false,
    String? searchQuery,
    bool? isLoading,
  }) {
    return MapState(
      allPlaces: allPlaces ?? this.allPlaces,
      places: places ?? this.places,
      selectedPlace: selectedPlace ?? this.selectedPlace,
      currentLocation: currentLocation ?? this.currentLocation,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedCategories: selectedCategories ?? this.selectedCategories,
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
    state = state.copyWith(selectedCategory: cat, selectedCategories: {}, clearCategory: cat == null);
    _applyFilters();
  }

  void filterByCategories(Set<String> categories) {
    state = state.copyWith(selectedCategories: categories, clearCategory: true);
    _applyFilters();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void _applyFilters() {
    final categories = state.selectedCategories;
    final singleCategory = state.selectedCategory;
    final query = state.searchQuery.trim().toLowerCase();

    final filtered = state.allPlaces.where((p) {
      final pCat = (p['category'] as String?)?.toLowerCase() ?? '';

      bool catMatch = true;
      if (categories.isNotEmpty) {
        catMatch = categories.any((cat) => _matchesCategory(pCat, cat));
      } else if (singleCategory != null && singleCategory != 'all') {
        catMatch = _matchesCategory(pCat, singleCategory);
      }

      final name = (p['name'] as String?)?.toLowerCase() ?? '';
      final address = (p['address'] as String?)?.toLowerCase() ?? '';
      final queryMatch = query.isEmpty || name.contains(query) || address.contains(query);

      return catMatch && queryMatch;
    }).toList();

    state = state.copyWith(places: filtered);
  }

  static bool _matchesCategory(String placeCategory, String targetCategory) {
    final cat = placeCategory.toLowerCase();
    final target = targetCategory.toLowerCase();

    if (target == 'attraction') {
      return cat.contains('attraction') || cat.contains('di tích') || cat.contains('lịch sử');
    }
    if (target == 'food' || target == 'restaurant') {
      return cat.contains('food') || cat.contains('restaurant') || cat.contains('ẩm thực') || cat.contains('ăn');
    }
    if (target == 'temple') {
      return cat.contains('temple') || cat.contains('chùa') || cat.contains('tâm linh');
    }
    if (target == 'tomb') {
      return cat.contains('tomb') || cat.contains('lăng');
    }
    if (target == 'cafe') {
      return cat.contains('cafe') || cat.contains('cà phê');
    }
    if (target == 'shopping') {
      return cat.contains('shop') || cat.contains('mua sắm') || cat.contains('chợ');
    }
    if (target == 'culture') {
      return cat.contains('culture') || cat.contains('nghệ thuật');
    }
    return cat == target;
  }

  void setCurrentLocation(LatLng location) {
    state = state.copyWith(currentLocation: location);
  }
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  return MapNotifier();
});