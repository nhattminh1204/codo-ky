import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:codoky/core/logging/app_logger.dart';
import 'package:codoky/core/network/network_exceptions.dart';
import 'package:codoky/features/map/data/datasources/osrm_remote_service.dart';
import 'package:codoky/features/map/data/models/osrm_route_model.dart';
import 'package:codoky/features/map/presentation/widgets/place_marker.dart';

class MapState {
  final List<dynamic> allPlaces;
  final List<dynamic> places;
  final dynamic selectedPlace;
  final LatLng? currentLocation;
  final String? selectedCategory;
  final Set<String> selectedCategories;
  final Set<String> savedPlaceIds;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final OsrmRoute? activeRoute;
  final bool isFetchingRoute;
  final String? routeErrorMessage;
  final String travelMode;
  final bool isVoiceMuted;
  final int currentStepIndex;
  final List<OsrmRoute> alternativeRoutes;
  final int selectedRouteIndex;
  final MapMarkerStyle markerStyle;
  final MapTileStyle mapTileStyle;

  const MapState({
    this.allPlaces = const [],
    this.places = const [],
    this.selectedPlace,
    this.currentLocation,
    this.selectedCategory,
    this.selectedCategories = const {},
    this.savedPlaceIds = const {'1', '1333018015'},
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
    this.activeRoute,
    this.isFetchingRoute = false,
    this.routeErrorMessage,
    this.travelMode = 'motorbike',
    this.isVoiceMuted = false,
    this.currentStepIndex = 0,
    this.alternativeRoutes = const [],
    this.selectedRouteIndex = 0,
    this.markerStyle = MapMarkerStyle.gradientVibrantGlow,
    this.mapTileStyle = MapTileStyle.osmStandard,
  });

  MapState copyWith({
    List<dynamic>? allPlaces,
    List<dynamic>? places,
    dynamic selectedPlace,
    bool clearSelectedPlace = false,
    LatLng? currentLocation,
    String? selectedCategory,
    Set<String>? selectedCategories,
    Set<String>? savedPlaceIds,
    bool clearCategory = false,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    OsrmRoute? activeRoute,
    bool clearActiveRoute = false,
    bool? isFetchingRoute,
    String? routeErrorMessage,
    bool clearRouteError = false,
    String? travelMode,
    bool? isVoiceMuted,
    int? currentStepIndex,
    List<OsrmRoute>? alternativeRoutes,
    int? selectedRouteIndex,
    MapMarkerStyle? markerStyle,
    MapTileStyle? mapTileStyle,
  }) {
    return MapState(
      allPlaces: allPlaces ?? this.allPlaces,
      places: places ?? this.places,
      selectedPlace: clearSelectedPlace ? null : (selectedPlace ?? this.selectedPlace),
      currentLocation: currentLocation ?? this.currentLocation,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedCategories: selectedCategories ?? this.selectedCategories,
      savedPlaceIds: savedPlaceIds ?? this.savedPlaceIds,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      activeRoute: clearActiveRoute ? null : (activeRoute ?? this.activeRoute),
      isFetchingRoute: isFetchingRoute ?? this.isFetchingRoute,
      routeErrorMessage: clearRouteError ? null : (routeErrorMessage ?? this.routeErrorMessage),
      travelMode: travelMode ?? this.travelMode,
      isVoiceMuted: isVoiceMuted ?? this.isVoiceMuted,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      alternativeRoutes: alternativeRoutes ?? this.alternativeRoutes,
      selectedRouteIndex: selectedRouteIndex ?? this.selectedRouteIndex,
      markerStyle: markerStyle ?? this.markerStyle,
      mapTileStyle: mapTileStyle ?? this.mapTileStyle,
    );
  }

}

class MapNotifier extends StateNotifier<MapState> {
  final OsrmRemoteService? osrmRemoteService;

  MapNotifier({this.osrmRemoteService}) : super(const MapState()) {
    _initPreferences();
  }

  Future<void> _initPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString('last_selected_travel_mode');
      final isMuted = prefs.getBool('is_voice_muted') ?? false;
      if (savedMode != null && ['motorbike', 'driving'].contains(savedMode)) {
        state = state.copyWith(travelMode: savedMode, isVoiceMuted: isMuted);
      } else {
        state = state.copyWith(isVoiceMuted: isMuted);
      }
    } catch (e) {
      AppLogger.w('Lỗi đọc preferences từ SharedPreferences: $e');
    }
  }

  Future<void> setTravelMode(String mode) async {
    if (!['motorbike', 'driving'].contains(mode)) return;
    if (state.travelMode == mode) return;

    state = state.copyWith(travelMode: mode, currentStepIndex: 0);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_selected_travel_mode', mode);
      AppLogger.i('💾 Đã lưu travel mode mặc định: $mode');
    } catch (e) {
      AppLogger.w('Lỗi lưu travel mode vào SharedPreferences: $e');
    }
  }

  Future<void> toggleVoiceMute() async {
    final nextMute = !state.isVoiceMuted;
    state = state.copyWith(isVoiceMuted: nextMute);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_voice_muted', nextMute);
      AppLogger.i('🔊 Voice guidance muted: $nextMute');
    } catch (e) {
      AppLogger.w('Lỗi lưu voice mute vào SharedPreferences: $e');
    }
  }

  void setCurrentStepIndex(int index) {
    state = state.copyWith(currentStepIndex: index);
  }


  Future<void> loadPlaces({bool forceRefresh = false, AssetBundle? bundle}) async {
    if (!forceRefresh && state.allPlaces.isNotEmpty) {
      AppLogger.i('⚡ Places dataset already present in MapState (${state.allPlaces.length} items). Skipping redundant reload.');
      return;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final activeBundle = bundle ?? rootBundle;
      final jsonString = await activeBundle.loadString('assets/data/hue_places_seed.json');
      final List<dynamic> decoded = json.decode(jsonString);

      state = state.copyWith(
        allPlaces: decoded,
        places: decoded,
        isLoading: false,
        clearErrorMessage: true,
      );
      _applyFilters();
    } catch (e, stackTrace) {
      AppLogger.e('❌ Lỗi nạp dữ liệu địa điểm từ asset: $e', e, stackTrace);

      state = state.copyWith(
        allPlaces: const [],
        places: const [],
        isLoading: false,
        errorMessage: 'Không thể tải dữ liệu địa điểm. Vui lòng thử lại!',
      );
    }
  }

  void selectPlace(dynamic place) {
    state = state.copyWith(selectedPlace: place);
  }

  void clearSelection() {
    state = state.copyWith(clearSelectedPlace: true);
  }

  void filterByCategory(String? category) {
    final cat = category ?? 'all';
    state = state.copyWith(selectedCategory: cat, selectedCategories: {}, clearCategory: false);
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

  void toggleSavePlace(String placeId) {
    final currentSaved = Set<String>.from(state.savedPlaceIds);
    if (currentSaved.contains(placeId)) {
      currentSaved.remove(placeId);
      AppLogger.i('Bỏ lưu địa điểm: $placeId');
    } else {
      currentSaved.add(placeId);
      AppLogger.i('Lưu địa điểm: $placeId');
    }
    state = state.copyWith(savedPlaceIds: currentSaved);
    _applyFilters();
  }

  void _applyFilters() {
    final categories = state.selectedCategories;
    final singleCategory = state.selectedCategory;
    final query = state.searchQuery.trim().toLowerCase();
    final savedIds = state.savedPlaceIds;

    final filtered = state.allPlaces.where((p) {
      final pId = (p['id'] as dynamic)?.toString() ?? '';
      final pCat = (p['category'] as String?)?.toLowerCase() ?? '';
      final rating = (p['rating'] as num?)?.toDouble() ?? 0.0;
      final isFeatured = (p['is_featured'] == true) || (p['featured'] == true) || rating >= 4.5;

      bool catMatch = true;
      if (categories.isNotEmpty) {
        catMatch = categories.any((cat) => _matchesCategory(pCat, cat, isFeatured, pId, savedIds));
      } else if (singleCategory == 'all' || singleCategory == null) {
        catMatch = true;
      } else if (singleCategory == 'featured') {
        catMatch = isFeatured;
      } else if (singleCategory == 'saved') {
        catMatch = savedIds.contains(pId);
      } else {
        catMatch = _matchesCategory(pCat, singleCategory, isFeatured, pId, savedIds);
      }

      final name = (p['name'] as String?)?.toLowerCase() ?? '';
      final address = (p['address'] as String?)?.toLowerCase() ?? '';
      final queryMatch = query.isEmpty || name.contains(query) || address.contains(query);

      return catMatch && queryMatch;
    }).toList();

    state = state.copyWith(places: filtered);
  }

  static bool _matchesCategory(String placeCategory, String targetCategory, bool isFeatured, [String? placeId, Set<String>? savedPlaceIds]) {
    final cat = placeCategory.toLowerCase();
    final target = targetCategory.toLowerCase();

    if (target == 'featured') {
      return isFeatured;
    }
    if (target == 'saved' && placeId != null && savedPlaceIds != null) {
      return savedPlaceIds.contains(placeId);
    }
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

  void selectRouteIndex(int index) {
    if (index < 0 || index >= state.alternativeRoutes.length) return;
    state = state.copyWith(
      selectedRouteIndex: index,
      activeRoute: state.alternativeRoutes[index],
      currentStepIndex: 0,
    );
  }

  Future<bool> fetchRouteToPlace(dynamic destinationPlace) async {
    if (destinationPlace == null) {
      state = state.copyWith(
        clearActiveRoute: true,
        alternativeRoutes: const [],
        selectedRouteIndex: 0,
      );
      return false;
    }

    double? destLat;
    double? destLng;

    if (destinationPlace is Map) {
      destLat = (destinationPlace['latitude'] as num?)?.toDouble();
      destLng = (destinationPlace['longitude'] as num?)?.toDouble();
    } else {
      destLat = (destinationPlace.latitude as num?)?.toDouble();
      destLng = (destinationPlace.longitude as num?)?.toDouble();
    }

    if (destLat == null || destLng == null) {
      state = state.copyWith(
        routeErrorMessage: 'Tọa độ điểm đến không hợp lệ',
        clearActiveRoute: true,
        alternativeRoutes: const [],
        selectedRouteIndex: 0,
      );
      return false;
    }

    final startPos = state.currentLocation ?? const LatLng(16.4637, 107.5909);
    final endPos = LatLng(destLat, destLng);

    state = state.copyWith(
      isFetchingRoute: true,
      clearRouteError: true,
    );

    try {
      if (osrmRemoteService == null) {
        throw NetworkExceptions.custom('Dịch vụ OSRM Routing chưa được khởi tạo');
      }

      final routes = await osrmRemoteService!.getRoutes(
        start: startPos,
        end: endPos,
        profile: state.travelMode,
        alternatives: true,
      );

      state = state.copyWith(
        activeRoute: routes.first,
        alternativeRoutes: routes,
        selectedRouteIndex: 0,
        isFetchingRoute: false,
        clearRouteError: true,
      );
      return true;
    } on NetworkExceptions catch (e) {
      final message = NetworkExceptions.getErrorMessage(e);
      AppLogger.w('OSRM routing network exception: $message');
      state = state.copyWith(
        clearActiveRoute: true,
        alternativeRoutes: const [],
        selectedRouteIndex: 0,
        isFetchingRoute: false,
        routeErrorMessage: message,
      );
      return false;
    } catch (e) {
      AppLogger.e('OSRM routing unexpected exception: $e');
      state = state.copyWith(
        clearActiveRoute: true,
        alternativeRoutes: const [],
        selectedRouteIndex: 0,
        isFetchingRoute: false,
        routeErrorMessage: 'Không thể tính toán tuyến đường. Vui lòng thử lại!',
      );
      return false;
    }
  }

  /// Clears active driving route from state
  void clearRoute() {
    state = state.copyWith(
      clearActiveRoute: true,
      clearRouteError: true,
    );
  }

  /// Sets active marker design style (gradient, duotone, 3d pop)
  void setMarkerStyle(MapMarkerStyle style) {
    state = state.copyWith(markerStyle: style);
    AppLogger.i('🎨 Đã chuyển phong cách Map Marker sang: ${style.name}');
  }

  /// Sets active map tile theme style (cartoVoyager, cartoDark, cartoPositron, osmStandard)
  void setMapTileStyle(MapTileStyle style) {
    state = state.copyWith(mapTileStyle: style);
    AppLogger.i('🗺️ Đã chuyển phong cách nền bản đồ sang: ${style.name}');
  }
}

enum MapTileStyle {
  /// OpenStreetMap Standard
  osmStandard,

  /// CartoDB Voyager (Modern colorful travel basemap)
  cartoVoyager,

  /// CartoDB Dark Matter (Sleek dark basemap)
  cartoDark,

  /// CartoDB Positron (Minimalist light basemap)
  cartoPositron,
}

final mapProvider = StateNotifierProvider<MapNotifier, MapState>((ref) {
  final osrmService = ref.watch(osrmRemoteServiceProvider);
  return MapNotifier(osrmRemoteService: osrmService);
});