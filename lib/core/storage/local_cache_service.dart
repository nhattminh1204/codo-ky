import 'package:hive_flutter/hive_flutter.dart';

/// Local cache service using Hive for offline-first support
///
/// Box naming convention:
/// - "places_cache" - Cached place data from explore/map
/// - "itinerary_cache" - Cached itinerary data
/// - "review_cache" - Cached review data
/// - "user_preferences" - User settings (theme, locale, etc.)
/// - "auth_tokens" - Authentication tokens (secure storage recommended for production)

class LocalCacheService {
  static LocalCacheService? _instance;
  static LocalCacheService get instance => _instance ??= LocalCacheService._();

  LocalCacheService._();

  bool _isInitialized = false;

  /// Initialize Hive and open boxes
  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register adapters if needed (run build_runner for generated adapters)
    // Hive.registerAdapter(PlaceModelAdapter());
    // Hive.registerAdapter(ItineraryModelAdapter());

    // Open boxes
    await _openBoxes();

    _isInitialized = true;
  }

  Future<void> _openBoxes() async {
    await Hive.openBox('places_cache');
    await Hive.openBox('itinerary_cache');
    await Hive.openBox('review_cache');
    await Hive.openBox('user_preferences');
    await Hive.openBox('auth_tokens');
  }

  // ==================== Places Cache ====================

  /// Get cached places
  List<dynamic> getCachedPlaces() {
    final box = Hive.box('places_cache');
    return box.get('places', defaultValue: <dynamic>[]);
  }

  /// Cache places list
  Future<void> cachePlaces(List<dynamic> places) async {
    final box = Hive.box('places_cache');
    await box.put('places', places);
    await box.put('cached_at', DateTime.now().millisecondsSinceEpoch);
  }

  /// Get cached place by ID
  dynamic getCachedPlace(String id) {
    final places = getCachedPlaces();
    try {
      return places.firstWhere((p) => p['id'].toString() == id);
    } catch (_) {
      return null;
    }
  }

  /// Clear places cache
  Future<void> clearPlacesCache() async {
    final box = Hive.box('places_cache');
    await box.clear();
  }

  // ==================== Itinerary Cache ====================

  /// Get cached itineraries
  List<dynamic> getCachedItineraries() {
    final box = Hive.box('itinerary_cache');
    return box.get('itineraries', defaultValue: <dynamic>[]);
  }

  /// Cache itineraries
  Future<void> cacheItineraries(List<dynamic> itineraries) async {
    final box = Hive.box('itinerary_cache');
    await box.put('itineraries', itineraries);
    await box.put('cached_at', DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear itinerary cache
  Future<void> clearItineraryCache() async {
    final box = Hive.box('itinerary_cache');
    await box.clear();
  }

  // ==================== Review Cache ====================

  /// Get cached reviews
  List<dynamic> getCachedReviews() {
    final box = Hive.box('review_cache');
    return box.get('reviews', defaultValue: <dynamic>[]);
  }

  /// Cache reviews
  Future<void> cacheReviews(List<dynamic> reviews) async {
    final box = Hive.box('review_cache');
    await box.put('reviews', reviews);
    await box.put('cached_at', DateTime.now().millisecondsSinceEpoch);
  }

  /// Clear review cache
  Future<void> clearReviewCache() async {
    final box = Hive.box('review_cache');
    await box.clear();
  }

  // ==================== User Preferences ====================

  /// Get user preference
  T? getPreference<T>(String key, {T? defaultValue}) {
    final box = Hive.box('user_preferences');
    return box.get(key, defaultValue: defaultValue) as T?;
  }

  /// Set user preference
  Future<void> setPreference<T>(String key, T value) async {
    final box = Hive.box('user_preferences');
    await box.put(key, value);
  }

  /// Clear all preferences
  Future<void> clearPreferences() async {
    final box = Hive.box('user_preferences');
    await box.clear();
  }

  // Predefined preference keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyOnboardingCompleted = 'onboarding_completed';

  // ==================== Auth Tokens ====================

  /// Save auth token
  Future<void> saveAuthToken(String token) async {
    final box = Hive.box('auth_tokens');
    await box.put('access_token', token);
    await box.put('token_saved_at', DateTime.now().millisecondsSinceEpoch);
  }

  /// Get auth token
  String? getAuthToken() {
    final box = Hive.box('auth_tokens');
    return box.get('access_token') as String?;
  }

  /// Clear auth tokens
  Future<void> clearAuthTokens() async {
    final box = Hive.box('auth_tokens');
    await box.clear();
  }

  // ==================== Cache Expiration ====================

  /// Check if cache is expired (default 24 hours)
  bool isCacheExpired(String boxName, {Duration maxAge = const Duration(hours: 24)}) {
    final box = Hive.box(boxName);
    final cachedAt = box.get('cached_at') as int?;
    if (cachedAt == null) return true;

    final cacheTime = DateTime.fromMillisecondsSinceEpoch(cachedAt);
    return DateTime.now().difference(cacheTime) > maxAge;
  }

  /// Clear all caches
  Future<void> clearAllCaches() async {
    await Hive.box('places_cache').clear();
    await Hive.box('itinerary_cache').clear();
    await Hive.box('review_cache').clear();
  }

  /// Close all boxes (call on app dispose)
  Future<void> close() async {
    await Hive.close();
    _isInitialized = false;
  }
}