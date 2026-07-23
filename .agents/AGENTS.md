# CodoKy Project Rules & Context (Agent Memory)

## 🗺️ Map Architecture & Free Data Strategy
- **Client-Side Map UI**: Use `flutter_map` with OpenStreetMap (OSM) tile server (`https://tile.openstreetmap.org/{z}/{x}/{y}.png`).
- **No Google Maps Key Required**: Do not use `google_maps_flutter` or rely on client-side Google Maps API keys.
- **Coordinates & Markers**: Use `latlong2` package for GPS coordinates (`LatLng`) and custom Flutter widgets (`PlaceMarker`) for map markers.

## 📊 Data Strategy
- **Initial Seed Data**: Generated via Overpass API script (`scripts/fetch_hue_places.py`) saving to `scripts/hue_places_seed.json`.
- **Database & User Experience**: Backend stores places data and expands via user experience submissions over time.

## 🛠️ Project Tech Stack & Conventions
- **Framework**: Flutter 3.24+ (Dart 3.12+)
- **State Management**: `flutter_riverpod` (v2.6+)
- **Navigation**: `go_router` (v14.6+)
- **Architecture**: Feature-first + Clean Architecture
