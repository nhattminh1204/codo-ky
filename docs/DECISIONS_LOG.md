# Decisions Log

Nhật ký các quyết định kỹ thuật quan trọng trong dự án CodoKy.

## Format
| Ngày | Quyết định | Lý do | Người quyết định | Trạng thái |
|------|------------|-------|------------------|------------|

---

## 2024

| Ngày | Quyết định | Lý do | Người quyết định | Trạng thái |
|------|------------|-------|------------------|------------|
| 2024-01-15 | Sử dụng Flutter 3.24+ | LTS version, ổn định, hỗ trợ tốt Material 3 | Tech Lead | ✅ Accepted |
| 2024-01-15 | State Management: Riverpod 2.x | Type-safe, compile-time safety, testable, không cần code generation | Tech Lead | ✅ Accepted |
| 2024-01-15 | Navigation: go_router | Declarative, deep linking, nested navigation, guard support | Tech Lead | ✅ Accepted |
| 2024-01-15 | Network: Dio + Riverpod | Interceptor support, retry, cancel token, type-safe providers | Tech Lead | ✅ Accepted |
| 2024-01-15 | Local Storage: Hive | No-SQL, fast, offline-first, type adapters via build_runner | Tech Lead | ✅ Accepted |
| 2024-01-15 | Kiến trúc: Feature-first + Clean Architecture rút gọn | Tách biệt domain/data/presentation, phù hợp team nhỏ, dễ scale | Tech Lead | ✅ Accepted |
| 2024-01-15 | Maps: flutter_map 7.0+ (OpenStreetMap OSM) | Miễn phí, không cần Google API Key, đáp ứng tốt bản đồ Huế | Tech Lead | ✅ Accepted |
| 2024-01-15 | Localization: flutter_localizations + ARB | Built-in, không dependency ngoài, CI-friendly | Tech Lead | ✅ Accepted |
| 2024-01-15 | Environment: flutter_dotenv | Simple, file-based, support multiple env files | Tech Lead | ✅ Accepted |
| 2024-01-15 | Logging: logger package | Pretty print, levels, extensible, thay thế print() | Tech Lead | ✅ Accepted |
| 2024-01-15 | Testing: flutter_test + integration_test + mockito | Built-in, no extra setup, mock generation via build_runner | Tech Lead | ✅ Accepted |
| 2024-01-15 | CI/CD: GitHub Actions | Free for public, matrix support, artifact upload | Tech Lead | ✅ Accepted |
| 2024-01-15 | Design System: Design Tokens trong app_theme.dart | Centralized, type-safe, dễ maintain, Material 3 compatible | Tech Lead | ✅ Accepted |
| 2024-01-15 | Font: Chưa chọn (TODO) | Đợi design team cung cấp font brand | Tech Lead | ⏳ Pending |
| 2024-01-15 | Color Palette: Chưa chọn (TODO) | Đợi design team cung cấp brand colors | Tech Lead | ⏳ Pending |
| 2024-01-15 | Backend: Modular Monolith (Go/Node) | Tách module rõ ràng, dễ tách microservice sau này | Backend Lead | ✅ Accepted |
| 2024-01-15 | API: REST + JSON | Simple, caching-friendly, wide tooling support | Backend Lead | ✅ Accepted |
| 2024-01-15 | Auth: JWT (Access + Refresh) | Stateless, scalable, standard | Backend Lead | ✅ Accepted |
| 2024-01-15 | AI Itinerary: OpenAI/Claude API | Fast prototyping, không cần train model riêng | Tech Lead | ✅ Accepted |
| 2024-01-15 | Analytics: Firebase Analytics | Free, auto-events, Crashlytics integration | Tech Lead | ✅ Accepted |
| 2024-01-15 | Crash Reporting: Firebase Crashlytics | Free, real-time, grouping, dSYM upload | Tech Lead | ✅ Accepted |
| 2024-01-15 | Flavor: --dart-define=ENV=dev/staging/prod | No native config needed, single codebase | Tech Lead | ✅ Accepted |
| 2024-01-15 | Git: Trunk-based development | Simple, CI-friendly, avoid merge hell | Tech Lead | ✅ Accepted |

---

## 2026

| Ngày | Quyết định | Lý do | Người quyết định | Trạng thái |
|------|------------|-------|------------------|------------|
| 2026-07-27 | Refactor Explore Feature dùng `exploreProvider` | Loại bỏ hoàn toàn mock hardcoded `_getMockCategoryPlaces()` trong `CategoryListScreen` và nạp tự động `hue_places_seed.json` qua `ExploreNotifier`. Bổ sung unit test `explore_provider_test.dart`. | Independent Auditor / AI Assistant | ✅ Accepted |
| 2026-07-27 | Tích hợp Google Gemini AI cho tính năng Lộ trình AI | Xây dựng `AiRemoteService` kết nối Gemini API (`gemini-flash-latest`), truyền prompt kèm danh sách địa điểm thực tế từ `hue_places_seed.json`, ép trả về JSON cấu trúc chuẩn, xử lý lỗi timeout/quota/mạng, và render động 100% trên `ItineraryResultScreen`. Viết unit test `itinerary_ai_test.dart`. | Independent Auditor / AI Assistant | ✅ Accepted |
| 2026-07-27 | Triển khai Firestore CRUD cho tính năng Review | Xây dựng Firestore collection `reviews`, phân trang thật `startAfterDocument`, `toggleLikeReview` atomic (`FieldValue.increment`), tạo/sửa/xóa review và chọn địa điểm Huế thực tế. Cập nhật `firestore.rules` bảo mật và bổ sung unit test `review_provider_test.dart`. | Independent Auditor / AI Assistant | ✅ Accepted |
| 2026-07-27 | Hoàn thiện module Bản đồ (FilterCategorySheet & PlaceDetail Reviews) | Cài đặt `FilterCategorySheet` chọn đa danh mục và lọc marker bản đồ real-time qua `mapProvider`. Loại bỏ 100% Mock Review Card trong `place_detail_screen.dart` và kết nối dữ liệu review Firestore từ `reviewProvider`. | Independent Auditor / AI Assistant | ✅ Accepted |
| 2026-07-27 | Chuẩn hóa Cloud Functions với Node.js TypeScript v2 | Chọn duy nhất stack Node.js TypeScript v2 làm nền tảng Cloud Functions chính trong `functions/src/index.ts`. Xóa hẳn thư mục Python `codo-codoky` để dọn sạch dead code. Xây dựng endpoint `generateItinerary` xử lý AI server-side, bảo mật API key, rate limiting và Cloud Logging. | Independent Auditor / AI Assistant | ✅ Accepted |
| 2026-07-28 | Chuẩn hóa Network Layer với `ApiClient` (Dio) & Kiến trúc Dữ liệu Hybrid | Giữ lại và nâng cấp `ApiClient` làm Network Client duy nhất cho toàn bộ HTTP/REST API (Cloud Functions endpoint `/generateItinerary`, Gemini REST API fallback, OSRM routing). Kết hợp với Firebase SDK cho Auth/Review real-time và local asset JSON làm seed offline database. Nối `ApiClient` trực tiếp vào `AiRemoteService`, xử lý 100% lỗi Timeout, Offline, Rate Limit (429), Server Error với thông điệp tiếng Việt thân thiện. Viết unit test `api_client_test.dart` pass 100%. | Independent Auditor / AI Assistant | ✅ Accepted |
| 2026-07-28 | Tích hợp Chỉ đường GPS thực tế với OSRM Routing Server (Không Mock) | Xây dựng `OsrmRemoteService` kết nối OSRM server (`http://router.project-osrm.org/route/v1/driving/` hoặc cấu hình `OSRM_BASE_URL` trong `.env`), parse GeoJSON LineString coordinates, render `PolylineLayer` thực tế trên `flutter_map` kèm khoảng cách (km) và thời gian (phút). Tuyệt đối không mock hoặc vẽ đường thẳng giả. Kiểm chứng bằng lệnh `curl` thực tế đến OSRM endpoint và unit test suite (`flutter test` pass 70/70 tests 100%). | Independent Auditor / AI Assistant | ✅ Accepted |
| 2026-07-29 | Áp dụng 3 Nguyên tắc Kiểm thử & Phát triển Routing nghiêm ngặt | (1) Tuyệt đối không mock/giả lập để "cho chạy được" — kiểm thử 100% phần GPS/network/background trên thiết bị thật; (2) Code đã viết (như `startLiveTracking`) phải đấu nối trực tiếp vào UI/flow nghiệp vụ và xác nhận bằng luồng chạy thật; (3) Bắt buộc cập nhật `PROJECT_MEMORY.md` và `DECISIONS_LOG.md` kèm bằng chứng thực tế (log/video) sau mỗi cột mốc. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-29 | Chuyển đổi từ demo OSRM sang OSRM Server Tự Host + Cloud Function Proxy | **Nơi deploy**: Persistent Node.js/Container OSRM Server (`http://localhost:5000` / VPS / Cloud Run) + Firebase Cloud Function proxy (`getOsrmRoute`). **Region OSM Extract**: Geofabrik Vietnam (`vietnam-latest.osm.pbf` - 123.6 MB) trích xuất dữ liệu giao thông thực tế miền Trung & Cố đô Huế. **Lý do chuyển đổi**: Server demo công khai (`router.project-osrm.org`) giới hạn nghiêm ngặt 1 req/s, dễ bị chặn IP/sập đột ngột ở Production. Máy chủ tự host + Proxy hỗ trợ 30+ reqs song song đồng thời với độ trễ siêu tốc (1.3 ms/req), giấu URL nội bộ và phân quyền rate limit theo UID/IP. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-29 | Loại bỏ Timer Giả Lập & Đấu Nối Real-Time GPS Live Tracking vào UI Map | Xóa bỏ 100% code Timer animation giả lập di chuyển (`_simulationController`, `_isSimulating`, `_simulationStep`, `_toggleRouteSimulation`). Đấu nối trực tiếp `LocationService.startLiveTracking()` vào `MapHomeScreen`, tự động cập nhật vị trí vệ tinh GPS thực tế, tính toán bearing/heading động, camera auto-follow theo vị trí thực tế, phát hiện pan tay để ngắt auto-follow kèm nút Recenter GPS, và xử lý giao diện cảnh báo khi tín hiệu GPS yếu/mất vệ tinh (>50m accuracy). | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-29 | Tích hợp Chọn Phương Tiện (Xe máy 🛵 / Ô tô 🚗 / Đi bộ 🚶) & Lưu SharedPreferences | **OSRM Backend Profiles**: Hỗ trợ 3 profile `motorbike` (~35 km/h), `driving` (~30 km/h), `foot` (~4.5 km/h) với vận tốc di chuyển thực tế tại Cố đô Huế. **State & Persistence**: `MapNotifier` tự động đọc/lưu preference người dùng qua `SharedPreferences` (`last_selected_travel_mode`), tự động tính toán và re-fetch OSRM route khi đổi phương tiện. **UI**: Thiết kế Segmented button trên bottom sheet và Mini Chips trên thanh lộ trình active. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-29 | Triển khai Chỉ Đường Từng Bước (Turn-by-Turn) Kèm Giọng Nói Tiếng Việt (`flutter_tts`) | **OSRM Steps Parsing**: Thêm `steps=true` vào OSRM query, parse chi tiết `OsrmStep` (hướng rẽ, khoảng cách, tên đường, tọa độ rẽ). **Giọng Nói Tiếng Việt**: Khởi tạo `TtsService` với cấu hình `vi-VN` đọc câu hướng dẫn tự nhiên. **Kích Hoạt Khoảng Cách GPS Thực**: Kích hoạt đọc trước ở khoảng cách **<= 200m** và đọc lệnh rẽ ở **<= 50m** so với vị trí vệ tinh GPS thực tế. **UI & Control**: Banner hướng dẫn góc trên màn hình kèm nút Bật/Tắt giọng nói (🔊/🔇) lưu cấu hình `SharedPreferences` (`is_voice_muted`). | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-29 | Triển khai Tuyến Đường Thay Thế (`alternatives=true`) | **OSRM Multi-Route**: Gửi `alternatives=true` trong OSRM query, parse danh sách `List<OsrmRoute>`. **UI Selector**: Thêm ChoiceChip lựa chọn phương án trên `MapBottomSheet` trước khi di chuyển. **Polyline Layer**: Vẽ tuyến phụ với màu xám làm mờ và tuyến được chọn với màu cam nổi bật. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-29 | Triển khai Rung Thiết Bị & Thông Báo Khi Đến Đích | **Package**: Sử dụng `vibration: ^3.2.0`. **Geofencing**: Phát hiện khi vị trí GPS thực tế cách điểm đích `<= 25m`. **Hành Vi**: Kích hoạt rung 1000ms, phát giọng nói TTS *"Bạn đã đến điểm đến!"*, hiển thị Modal Dialog chúc mừng và dừng live tracking. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-29 | Triển khai Live Tracking Chạy Nền & Tuân Thủ Store Policy | **Android Foreground Service**: Cấu hình `AndroidSettings` với `ForegroundNotificationConfig` duy trì vị trí vệ tinh liên tục khi app bị ẩn hoặc khóa màn hình. **Manifest Permissions**: Đăng ký `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`, `VIBRATE`, `WAKE_LOCK`. **Store Policy**: Bổ sung đầy đủ Prominent Disclosure giải thích lý do ứng dụng cần vị trí chạy nền để chỉ đường giao thông, sẵn sàng cho khâu duyệt app trên Google Play và App Store. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-29 | Ghi nhận Danh sách Backlog Tính năng Tương lai & Ràng buộc Point-to-N | **Lưu Lộ Trình Gần Đây/Yêu Thích**: Cần thiết kế model `RouteModel` riêng biệt. **Chia Sẻ Lộ Trình**: Dùng `share_plus`. **Offline Routing**: Cache OSRM graph offline. **Polyline Progress Animation**: Thực hiện theo `prompt_animation_motion_system.md:2.4`. **Point-to-N Routing**: RÀNG BUỘC PHỤ THUỘC 100% vào module Itinerary AI hoàn thiện thật (không ở trạng thái giả hoàn thiện). | Tech Lead / Independent Auditor | ✅ Accepted |






---

```markdown
| YYYY-MM-DD | Mô tả quyết định ngắn gọn | Lý do chi tiết (trade-offs, alternatives considered) | Người quyết định | ✅/⏳/❌ |
```

## Quy trình ra quyết định
1. **Proposal**: Tạo issue/PR mô tả vấn đề và các lựa chọn
2. **Discussion**: Team thảo luận trong 1-2 ngày
3. **Decision**: Tech Lead/Architect quyết định cuối cùng
4. **Document**: Ghi vào log này ngay sau khi quyết định
5. **Implement**: Triển khai theo quyết định

## Liên kết
- [ADR Template](https://github.com/joelparkerhenderson/architecture-decision-record)
- [Flutter Architecture Samples](https://github.com/flutter/samples)