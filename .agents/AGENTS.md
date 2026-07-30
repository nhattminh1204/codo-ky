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
- **Rule 3 - Strict Anti-Mocking Policy**: Tuyệt đối không mock / giả lập để "cho chạy được" (bài học từ #6 tile: test pass không có nghĩa đúng thật). Tất cả các phần liên quan GPS, network, background, routing PHẢI được kiểm thử và xác minh trên thiết bị thật.
- **Rule 4 - Mandatory Code Wiring Verification**: Nếu 1 phần code đã tồn tại trong service/core (ví dụ `startLiveTracking`), PHẢI đấu nối trực tiếp vào UI/flow nghiệp vụ thực tế và xác nhận chạy thành công qua luồng thực thi thật, không được dừng lại ở việc gọi hàm trong unit test rồi coi như hoàn thành.
- **Rule 5 - Persistent Documentation & Evidence Log**: Bắt buộc cập nhật `PROJECT_MEMORY.md` và `DECISIONS_LOG.md` ngay sau khi hoàn thành mỗi module/cột mốc, đính kèm bằng chứng xác minh thực tế (log thực thi / kết quả kiểm thử / bằng chứng chạy thật).


## 📌 Status Snapshot & Known Issues (Audit 28/07/2026)
- **Map**: 🟢 Hoàn thiện (OpenStreetMap + FilterCategorySheet chọn đa danh mục + marker filtering + Place Detail real Firestore review + Chỉ đường GPS thực tế bằng OSRM Server Tự Host `http://localhost:5000` & Cloud Function proxy `getOsrmRoute`, dữ liệu Geofabrik Vietnam PBF, PolylineLayer động, 0% mock/vẽ đường thẳng giả).
- **Explore**: 🟢 Hoàn thiện (Client-side Provider). Nối `CategoryListScreen` với `exploreProvider` & `hue_places_seed.json`, loại bỏ hoàn toàn mock data hardcoded. Unit tests pass 100%.
- **Itinerary AI**: 🟢 Hoàn thiện (Real Gemini API). Tích hợp `AiRemoteService` gọi `gemini-flash-latest`, truyền địa điểm Huế thật từ `hue_places_seed.json`, render động 100% UI. Unit test `itinerary_ai_test.dart` pass.
- **Review**: 🟢 Hoàn thiện (Real Firestore CRUD). Kết nối Firestore collection `reviews`, phân trang thật `startAfterDocument`, `toggleLikeReview` atomic, CRUD tạo/sửa/xóa bài đánh giá và chọn địa điểm thật. Unit test `review_provider_test.dart` pass 100%.
- **Auth & Profile**: 🟢 Hoàn thiện (Refactor ProfileHomeScreen xóa bỏ 100% dữ liệu hardcode giả, phân tách 3 UI states: Shimmer Loading, Guest Welcome, Authenticated User. Unit test profile_state_test.dart pass 100%).
- **Backend / Cloud Functions**: 🟢 Hoàn thiện (TypeScript v2 `generateItinerary` endpoint + Gemini server-side execution + rate limit + logging. Đã xóa code chết `codo-codoky`).
- **Network Layer**: 🟢 Hoàn thiện (`ApiClient` + `NetworkExceptions` được nối 100% vào `AiRemoteService` và `itineraryProvider`, có interceptor logging và unit tests `api_client_test.dart` pass 100%).
- **Testing**: 🟢 Hoàn thiện (Xóa 100% test hình thức. Viết unit test suite cho 5 Notifiers chính và 3 widget/interaction tests cho các luồng thao tác người dùng chính. `flutter test` pass 87/87 tests 100%).
- **Motion System & Liquid Glass Dock**: 🟢 Hoàn thiện (Chuẩn hóa tại `lib/core/theme/motion.dart`: AppMotion.micro 150ms, AppMotion.standard 300ms, AppMotion.standardCurve, Liquid Glassmorphism Floating Dock với viền phản quang động, Active Pill nảy đàn hồi, nút AI tròn nổi và isolated press state 0.88, flutter test pass 87/87 tests 100%).
