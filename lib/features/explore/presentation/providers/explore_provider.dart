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
    this.searchQuery,
  });

  List<dynamic> get places {
    List<dynamic> baseList;
    switch (selectedCategory) {
      case 'restaurant':
      case 'food':
        baseList = restaurants;
        break;
      case 'attraction':
        baseList = attractions;
        break;
      case 'temple':
        baseList = temples;
        break;
      case 'tomb':
        baseList = tombs;
        break;
      default:
        baseList = allPlaces;
        break;
    }

    if (searchQuery != null && searchQuery!.isNotEmpty) {
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

    state = state.copyWith(isLoading: true);

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
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
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