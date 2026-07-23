# Observability Plan

## Overview
This document outlines the observability strategy for CodoKy, including error tracking, analytics, and monitoring.

## Tools Selection

### Error Tracking & Crash Reporting
**Primary: Firebase Crashlytics**
- Free tier with generous limits
- Native Flutter support via `firebase_crashlytics`
- Automatic crash grouping and deduplication
- Integration with Firebase Console
- Supports custom keys, logs, and non-fatal errors

**Alternative: Sentry**
- More detailed context capture
- Better release tracking
- Paid tiers for higher volume
- Consider if Crashlytics limitations are hit

### Analytics
**Primary: Firebase Analytics**
- Free and unlimited events
- Automatic event collection (screen views, user engagement)
- Custom events for feature tracking
- Audience segmentation
- Integration with Crashlytics and Remote Config

**Alternative: Mixpanel / Amplitude**
- More advanced funnel analysis
- Better user journey visualization
- Paid for higher event volumes

### Performance Monitoring
**Firebase Performance Monitoring**
- Automatic HTTP/S network request monitoring
- Custom traces for critical user flows
- App startup time tracking
- Screen rendering performance

## Implementation Plan

### Phase 1: MVP (Current)
- [x] Add `firebase_crashlytics` dependency placeholder
- [x] Add `firebase_analytics` dependency placeholder
- [x] Add TODO comments in `main.dart` for initialization
- [x] Create `AppLogger` wrapper to replace `print()`
- [ ] Configure `firebase_crashlytics` with `flutterfire configure`
- [ ] Configure `firebase_analytics` with `flutterfire configure`
- [ ] Initialize Crashlytics in `main.dart`
- [ ] Initialize Analytics in `main.dart`

### Phase 2: Enhanced Tracking
- [ ] Add custom Crashlytics keys (user_id, feature flags, etc.)
- [ ] Log non-fatal errors with `FirebaseCrashlytics.instance.recordError()`
- [ ] Add breadcrumbs for user actions
- [ ] Define custom Analytics events for key flows:
  - `itinerary_created`
  - `place_reviewed`
  - `ai_suggestion_generated`
  - `map_search_performed`
  - `filter_applied`
- [ ] Add user properties (locale, theme, app_version)

### Phase 3: Advanced Monitoring
- [ ] Set up Firebase Performance Monitoring
- [ ] Add custom traces for:
  - API call latency
  - Map load time
  - AI suggestion generation time
- [ ] Configure alerts for crash rate spikes
- [ ] Set up dashboard for key metrics

## Event Taxonomy

### Screen Views (Auto-collected)
- `screen_view` - Firebase auto-collects

### Custom Events
| Event Name | Parameters | Description |
|------------|------------|-------------|
| `itinerary_created` | `duration_days`, `budget`, `is_ai_generated` | User creates new itinerary |
| `itinerary_shared` | `itinerary_id`, `share_method` | User shares itinerary |
| `place_reviewed` | `place_id`, `rating`, `has_media` | User submits review |
| `ai_suggestion_generated` | `duration_days`, `budget`, `interests_count` | AI generates itinerary |
| `ai_suggestion_accepted` | `suggestion_id` | User accepts AI suggestion |
| `map_search` | `query`, `results_count` | User searches on map |
| `filter_applied` | `category`, `count` | User filters places |
| `place_favorited` | `place_id` | User favorites a place |
| `language_changed` | `locale` | User changes language |
| `theme_changed` | `theme_mode` | User changes theme |

### User Properties
| Property | Type | Description |
|----------|------|-------------|
| `locale` | string | `vi` or `en` |
| `theme_mode` | string | `light`, `dark`, `system` |
| `app_version` | string | e.g., `1.0.0+1` |
| `is_authenticated` | boolean | User logged in |
| `total_itineraries` | int | Count of user itineraries |
| `total_reviews` | int | Count of user reviews |

## Crashlytics Best Practices
1. Always include context: `recordError(error, stack, reason: 'context', fatal: false)`
2. Set custom keys for debugging: `setCustomKey('user_id', userId)`
3. Log breadcrumbs: `log('User tapped create itinerary')`
4. Use non-fatal for handled exceptions
5. Opt-in for user feedback on crashes

## Analytics Best Practices
1. Use consistent naming: `snake_case` for events, `snake_case` for params
2. Limit event params to 25 per event (Firebase limit)
3. Don't log PII in events
4. Use user properties for segmentation
5. Test with DebugView before release

## Release Process
1. Run `flutterfire configure` for each flavor (dev/staging/prod)
2. Upload dSYMs (iOS) / ProGuard mappings (Android) to Crashlytics
3. Verify in Firebase Console:
   - Crashlytics: Test crash appears
   - Analytics: DebugView shows events
   - Performance: Traces appear

## References
- [Firebase Crashlytics Flutter](https://firebase.flutter.dev/docs/crashlytics/overview)
- [Firebase Analytics Flutter](https://firebase.flutter.dev/docs/analytics/overview)
- [Firebase Performance Flutter](https://firebase.flutter.dev/docs/performance/overview)
- [Sentry Flutter](https://docs.sentry.io/platforms/flutter/)