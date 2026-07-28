# CodoKy Project Rules & Context (Agent Memory)

> **ĐÃ CẬP NHẬT (28/07/2026 - Kiểm toán độc lập)**: Phần này lưu giữ NGUỒN SỰ THẬT DUY NHẤT về kiến trúc, quy tắc và trạng thái dự án.

## 🗺️ Map Architecture & Free Data Strategy
- **Client-Side Map UI**: Use `flutter_map` with OpenStreetMap (OSM) tile server (`https://tile.openstreetmap.org/{z}/{x}/{y}.png`).
- **No Google Maps Key Required**: Do not use `google_maps_flutter` or rely on client-side Google Maps API keys.
- **Coordinates & Markers**: Use `latlong2` package for GPS coordinates (`LatLng`) and custom Flutter widgets (`PlaceMarker`) for map markers.

- **Data Strategy**: Hybrid Architecture (Firebase SDK cho Auth/Review real-time, local asset JSON `hue_places_seed.json` làm dataset ban đầu, và `ApiClient` Dio làm Network Client duy nhất cho HTTP/REST API Cloud Functions & Gemini AI).
- **Network Layer**: 🟢 Hoàn thiện (`ApiClient` + `NetworkExceptions`). Nối `ApiClient` trực tiếp vào `AiRemoteService` & `itineraryProvider`, xử lý 100% exception timeout/offline/rate limit (429), bổ sung `AppLogger` interceptor và unit test `api_client_test.dart` pass 100%. Không còn dead code network layer.


## 🛠️ Project Tech Stack & Conventions
- **Framework**: Flutter 3.24+ (Dart 3.12+)
- **State Management**: `flutter_riverpod` (v2.6+)
- **Navigation**: `go_router` (v14.6+)
- **Architecture**: Feature-first + Clean Architecture

## 🎨 UI/UX Design System Enforcement & Mandatory Workflow Rules
- **Rule 1 - Mandatory Pre-UI Inspection**: Before creating, building, modifying, or refactoring ANY UI screen or component in the project, the agent MUST first read and inspect `.agents/UI_RULES.md` and `docs/UI_DESIGN_SYSTEM.md` to ensure full alignment with the 2026 Design Tokens, Typography, Spacing Grid, Component Standards, and Glassmorphism guidelines.
- **Rule 2 - Mandatory Post-Rule Audit & System-wide Alignment**: Whenever UI rules, colors, gradients, or component standards in `.agents/UI_RULES.md` or `docs/UI_DESIGN_SYSTEM.md` are updated or modified, the agent MUST immediately inspect, audit, and update ALL existing UI screens and components across the codebase (`lib/features/`, `lib/shared/`, `lib/core/widgets/`) to verify and guarantee that 100% of the app's screens fully comply with the new rules.

## 📌 Status Snapshot & Known Issues (Audit 28/07/2026)
- **Map**: 🟢 Hoàn thiện (OpenStreetMap + FilterCategorySheet chọn đa danh mục + marker filtering + Place Detail real Firestore review).
- **Explore**: 🟢 Hoàn thiện (Client-side Provider). Nối `CategoryListScreen` với `exploreProvider` & `hue_places_seed.json`, loại bỏ hoàn toàn mock data hardcoded. Unit tests pass 100%.
- **Itinerary AI**: 🟢 Hoàn thiện (Real Gemini API). Tích hợp `AiRemoteService` gọi `gemini-flash-latest`, truyền địa điểm Huế thật từ `hue_places_seed.json`, render động 100% UI. Unit test `itinerary_ai_test.dart` pass.
- **Review**: 🟢 Hoàn thiện (Real Firestore CRUD). Kết nối Firestore collection `reviews`, phân trang thật `startAfterDocument`, `toggleLikeReview` atomic, CRUD tạo/sửa/xóa bài đánh giá và chọn địa điểm thật. Unit test `review_provider_test.dart` pass 100%.
- **Auth & Profile**: 🟢 Hoàn thiện (Refactor ProfileHomeScreen xóa bỏ 100% dữ liệu hardcode giả, phân tách 3 UI states: Shimmer Loading, Guest Welcome, Authenticated User. Unit test profile_state_test.dart pass 100%).
- **Backend / Cloud Functions**: 🟢 Hoàn thiện (TypeScript v2 `generateItinerary` endpoint + Gemini server-side execution + rate limit + logging. Đã xóa code chết `codo-codoky`).
- **Network Layer**: 🟢 Hoàn thiện (`ApiClient` + `NetworkExceptions` được nối 100% vào `AiRemoteService` và `itineraryProvider`, có interceptor logging và unit tests `api_client_test.dart` pass 100%).
