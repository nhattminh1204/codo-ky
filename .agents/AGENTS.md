# CodoKy Project Rules & Context (Agent Memory)

> **ĐÃ CẬP NHẬT (27/07/2026 - Kiểm toán độc lập)**: Phần này lưu giữ NGUỒN SỰ THẬT DUY NHẤT về kiến trúc, quy tắc và trạng thái dự án.

## 🗺️ Map Architecture & Free Data Strategy
- **Client-Side Map UI**: Use `flutter_map` with OpenStreetMap (OSM) tile server (`https://tile.openstreetmap.org/{z}/{x}/{y}.png`).
- **No Google Maps Key Required**: Do not use `google_maps_flutter` or rely on client-side Google Maps API keys.
- **Coordinates & Markers**: Use `latlong2` package for GPS coordinates (`LatLng`) and custom Flutter widgets (`PlaceMarker`) for map markers.

## 📊 Data Strategy
- **Initial Seed Data**: Loaded from local asset `assets/data/hue_places_seed.json` (generated via `scripts/fetch_hue_places.py`).
- **Database & User Experience**: Backend stores places data and expands via user experience submissions over time. Currently, `api_client.dart` is not invoked; features read from local asset JSON or in-memory state.

## 🛠️ Project Tech Stack & Conventions
- **Framework**: Flutter 3.24+ (Dart 3.12+)
- **State Management**: `flutter_riverpod` (v2.6+)
- **Navigation**: `go_router` (v14.6+)
- **Architecture**: Feature-first + Clean Architecture

## 📌 Status Snapshot & Known Issues (Audit 27/07/2026)
- **Map**: 🟢 Hoàn thiện (OpenStreetMap + FilterCategorySheet chọn đa danh mục + marker filtering + Place Detail real Firestore review).
- **Explore**: 🟢 Hoàn thiện (Client-side Provider). Nối `CategoryListScreen` với `exploreProvider` & `hue_places_seed.json`, xóa hoàn toàn mock hardcoded list. Unit tests pass 100%.
- **Itinerary AI**: 🟢 Hoàn thiện (Real Gemini API). Tích hợp `AiRemoteService` gọi `gemini-flash-latest`, truyền địa điểm Huế thật từ `hue_places_seed.json`, render động 100% UI. Unit test `itinerary_ai_test.dart` pass.
- **Review**: 🟢 Hoàn thiện (Real Firestore CRUD). Kết nối Firestore collection `reviews`, phân trang thật `startAfterDocument`, `toggleLikeReview` atomic, CRUD tạo/sửa/xóa bài đánh giá và chọn địa điểm thật. Unit test `review_provider_test.dart` pass 100%.
- **Auth**: 🟢 Firebase Auth + Firestore logic ready.
- **Backend / Cloud Functions**: 🟢 Hoàn thiện (TypeScript v2 `generateItinerary` endpoint + Gemini server-side execution + rate limit + logging. Đã xóa code chết `codo-codoky`).
