# Local Storage (Hive) - Box Naming Convention

## Overview
This document describes the Hive box naming conventions and usage patterns for offline-first caching in CodoKy.

## Box Names & Purposes

| Box Name | Purpose | TTL | Auto-clear |
|----------|---------|-----|------------|
| `places_cache` | Cached place data from Explore/Map | 24h | On login/logout |
| `itinerary_cache` | Cached user itineraries & AI suggestions | 24h | On logout |
| `review_cache` | Cached reviews for offline viewing | 24h | On logout |
| `user_preferences` | Theme, locale, onboarding flags | Forever | Never |
| `auth_tokens` | Access/refresh tokens | Session | On logout |

## Usage Patterns

### 1. Initialize Early
```dart
// In main.dart before runApp()
await LocalCacheService.instance.init();
```

### 2. Cache-aside Pattern
```dart
// Read
final places = LocalCacheService.instance.getCachedPlaces();
if (places.isEmpty || LocalCacheService.instance.isCacheExpired('places_cache')) {
  places = await api.fetchPlaces();
  await LocalCacheService.instance.cachePlaces(places);
}
```

### 3. User Preferences
```dart
// Save
await LocalCacheService.instance.setPreference(
  LocalCacheService.keyThemeMode, 
  ThemeMode.system.index,
);

// Read
final themeIndex = LocalCacheService.instance.getPreference<int>(
  LocalCacheService.keyThemeMode,
  defaultValue: ThemeMode.system.index,
);
```

### 4. Auth Tokens
```dart
// Save after login
await LocalCacheService.instance.saveAuthToken(token);

// Retrieve for API calls
final token = LocalCacheService.instance.getAuthToken();

// Clear on logout
await LocalCacheService.instance.clearAuthTokens();
```

## Cache Expiration
- Default TTL: 24 hours
- Check with `isCacheExpired('box_name')`
- Customize TTL: `isCacheExpired('box_name', maxAge: Duration(hours: 12))`

## Clearing Strategy
- **On logout**: Clear `auth_tokens`, `places_cache`, `itinerary_cache`, `review_cache`
- **On theme/locale change**: Update `user_preferences` only
- **App update**: Version check can trigger full clear

## Generated Adapters
Run `flutter pub run build_runner build` to generate type-safe adapters:
```dart
@HiveType(typeId: 0)
class PlaceModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  // ...
}
```

## Security Notes
- `auth_tokens` should use Flutter Secure Storage in production
- Never cache sensitive PII in unencrypted boxes
- Consider encrypting boxes with `hive_flutter` encryption