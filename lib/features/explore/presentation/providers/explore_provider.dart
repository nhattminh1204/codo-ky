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
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ExploreNotifier extends StateNotifier<ExploreState> {
  ExploreNotifier() : super(const ExploreState());

  Future<void> loadPlaces({bool refresh = false}) async {
    state = state.copyWith(isLoading: true);

    try {
      final jsonString = await rootBundle.loadString('assets/data/hue_places_seed.json');
      final List<dynamic> places = json.decode(jsonString);

      final categories = [
        {'id': 'all', 'name': 'Tất cả'},
        {'id': 'restaurant', 'name': 'Nhà hàng'},
        {'id': 'attraction', 'name': 'Địa điểm'},
        {'id': 'temple', 'name': 'Chùa'},
        {'id': 'tomb', 'name': 'Lăng tẩm'},
      ];

      state = state.copyWith(
        allPlaces: places,
        restaurants: places.where((p) => p['category'] == 'restaurant').toList(),
        attractions: places.where((p) => p['category'] == 'attraction').toList(),
        temples: places.where((p) => p['category'] == 'temple').toList(),
        tombs: places.where((p) => p['category'] == 'tomb').toList(),
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadCategories() async {}

  void selectCategory(String? categoryId) {
    if (categoryId == 'all') {
      state = state.copyWith(selectedCategory: null);
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