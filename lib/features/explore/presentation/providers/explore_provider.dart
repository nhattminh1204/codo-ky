import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExploreState {
  final List<dynamic> allPlaces;
  final List<dynamic> restaurants;
  final List<dynamic> attractions;
  final List<dynamic> temples;
  final List<dynamic> tombs;
  final List<dynamic> categories;
  final String? selectedCategory;
  final bool isLoading;
  final bool isRefreshing;
  final String? searchQuery;

  const ExploreState({
    this.allPlaces = const [],
    this.restaurants = const [],
    this.attractions = const [],
    this.temples = const [],
    this.tombs = const [],
    this.categories = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.isRefreshing = false,
    this.searchQuery,
  });

  List<dynamic> get places => filteredPlaces;

  List<dynamic> get filteredPlaces {
    List<dynamic> baseList;
    if (selectedCategory == null || selectedCategory == 'all') {
      baseList = allPlaces;
    } else if (selectedCategory == 'restaurant') {
      baseList = restaurants;
    } else if (selectedCategory == 'attraction') {
      baseList = attractions;
    } else if (selectedCategory == 'temple') {
      baseList = temples;
    } else if (selectedCategory == 'tomb') {
      baseList = tombs;
    } else {
      baseList = allPlaces;
    }

    if (searchQuery != null && searchQuery!.trim().isNotEmpty) {
      return baseList.where((p) {
        final name = (p['name'] as String?)?.toLowerCase() ?? '';
        final address = (p['address'] as String?)?.toLowerCase() ?? '';
        final q = searchQuery!.toLowerCase();
        return name.contains(q) || address.contains(q);
      }).toList();
    }
    return baseList;
  }

  ExploreState copyWith({
    List<dynamic>? allPlaces,
    List<dynamic>? restaurants,
    List<dynamic>? attractions,
    List<dynamic>? temples,
    List<dynamic>? tombs,
    List<dynamic>? categories,
    String? selectedCategory,
    bool clearCategory = false,
    bool? isLoading,
    bool? isRefreshing,
    String? searchQuery,
  }) {
    return ExploreState(
      allPlaces: allPlaces ?? this.allPlaces,
      restaurants: restaurants ?? this.restaurants,
      attractions: attractions ?? this.attractions,
      temples: temples ?? this.temples,
      tombs: tombs ?? this.tombs,
      categories: categories ?? this.categories,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ExploreNotifier extends StateNotifier<ExploreState> {
  ExploreNotifier() : super(const ExploreState()) {
    loadPlaces();
  }

  Future<void> loadPlaces({bool refresh = false}) async {
    if (state.allPlaces.isNotEmpty && !refresh) return;

    final hasExistingPlaces = state.allPlaces.isNotEmpty;
    if (hasExistingPlaces && refresh) {
      state = state.copyWith(isRefreshing: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/hue_places_seed.json');
      final List<dynamic> places = json.decode(jsonString);

      final restaurants = places.where((p) {
        final cat = p['category']?.toString().toLowerCase() ?? '';
        return cat == 'restaurant' || cat == 'food';
      }).toList();

      final attractions = places.where((p) {
        final cat = p['category']?.toString().toLowerCase() ?? '';
        return cat == 'attraction';
      }).toList();

      final temples = places.where((p) {
        final cat = p['category']?.toString().toLowerCase() ?? '';
        return cat == 'temple';
      }).toList();

      final tombs = places.where((p) {
        final cat = p['category']?.toString().toLowerCase() ?? '';
        return cat == 'tomb';
      }).toList();

      final categories = [
        {'id': 'all', 'name': 'Tất cả', 'count': places.length},
        {'id': 'attraction', 'name': 'Địa điểm', 'count': attractions.length},
        {'id': 'restaurant', 'name': 'Nhà hàng & Ẩm thực', 'count': restaurants.length},
        {'id': 'temple', 'name': 'Chùa', 'count': temples.length},
        {'id': 'tomb', 'name': 'Lăng tẩm', 'count': tombs.length},
      ];

      state = state.copyWith(
        allPlaces: places,
        restaurants: restaurants,
        attractions: attractions,
        temples: temples,
        tombs: tombs,
        categories: categories,
        isLoading: false,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isRefreshing: false);
    }
  }

  Future<void> loadCategories() async {
    if (state.allPlaces.isEmpty) {
      await loadPlaces();
    }
  }

  void selectCategory(String? categoryId) {
    if (categoryId == 'all' || categoryId == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: categoryId);
    }
  }

  void searchPlaces(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> refresh() async {
    await loadPlaces(refresh: true);
  }
}

final exploreProvider = StateNotifierProvider<ExploreNotifier, ExploreState>((ref) {
  return ExploreNotifier();
});