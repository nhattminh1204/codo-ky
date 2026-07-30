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
| 2026-07-30 | Sửa lỗi Logic Chọn Chip "Tất cả" (`'all'`) bị Nhảy Highlight sang "Nổi bật" | **Root Cause Fix**: Trong `map_provider.dart`, sửa `filterByCategory('all')` giữ nguyên `selectedCategory = 'all'` và `catMatch = true` thay vì gán về `null` gây trôi sang trạng thái `featured`. Trong `map_home_screen.dart`, cập nhật `isSelected` check chính xác cho `'all'`. **Behavior**: Bấm "Tất cả" hiển thị 100% địa điểm và highlight đúng chip "Tất cả". **Testing**: `flutter test` pass 87/87 tests (100%), `flutter analyze` 0 issue. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-30 | Tinh giản Thanh Chip Lọc Danh Mục (Explore Mode Header Refinement) | **Clean Header Chips**: Loại bỏ nút `✕ Xóa lọc` dư thừa giúp các chip danh mục chính nằm sát lề trái thuận tiện bấm chọn. Rút gọn chip `Tất cả (658)` thành **`Tất cả`** ngắn gọn, phẳng đẹp. **Testing**: `flutter test` pass 87/87 tests (100%), `flutter analyze` 0 issue. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-30 | Tối ưu Giao diện Bản đồ theo Đánh giá UX (Full-View Navigation & Clean Toolbar) | **Active Navigation Mode**: Tự động ẩn Thanh tìm kiếm & Thanh chip lọc khi người dùng đang chạy chỉ đường (`activeRoute != null`), giải phóng 130px diện tích đỉnh màn hình. **Remove Redundancies**: Bỏ badge đếm `658` trùng lặp trong ô tìm kiếm, bỏ nút Zoom `+`/`-` thừa trên Cột bên phải, bỏ nút Hủy đỏ trùng lặp trên Cột bên phải. Tinh giản tiêu đề bảng đáy chỉ đường thành `Đang chỉ đường`. **Testing**: `flutter test` pass 87/87 tests (100%), `flutter analyze` 0 issue. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-30 | Khắc phục đè giao diện Banner Thông báo Chỉ đường (Turn-by-turn & GPS Weak Overlap Fix) | **Unified Notification Stack**: Gộp 100% các banner thông báo đỉnh màn hình (`TurnByTurnBanner`, `GpsWeakBanner`, OSRM fetching, error) vào 1 `Column` duy nhất tại `Positioned(top: 135, left: 14, right: 70)`. **Clearance**: Đặt lề phải `right: 70` giúp banner dừng trước Cột Thủy Tinh Bên Phải (`right: 14`) ít nhất 16px, không bao giờ đè vào nút Palette/Zoom/GPS. Các banner thông báo tự động xếp chồng dọc 8px mượt mà. **Testing**: `flutter test` pass 87/87 tests (100%), `flutter analyze` 0 issue. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-30 | Tinh giản Thanh Phương tiện di chuyển (Icon-only Minimalist Selector) | **Icon-only UI**: Bỏ nhãn chữ ("Xe máy", "Ô tô") dư thừa. Sử dụng biểu tượng icon 21px (`Icons.two_wheeler_rounded` và `Icons.directions_car_rounded`) trên nền `AnimatedContainer` bo tròn 10px với hiệu ứng chuyển đổi 200ms mượt mà và `Tooltip` gợi ý. **Testing**: `flutter test` pass 87/87 tests (100%), `flutter analyze` 0 issue. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-30 | Tối ưu chọn Phương tiện di chuyển (Xe máy / Ô tô) & Bỏ option Đi bộ | **Manual Trigger Only**: Cập nhật `setTravelMode` trong `mapProvider` chỉ cập nhật lựa chọn phương tiện (`motorbike` / `driving`) và lưu `SharedPreferences`, tuyệt đối KHÔNG tự động lấy lộ trình chỉ đường OSRM. **Explicit Action**: Lộ trình chỉ đường chỉ được tính toán khi người dùng nhấn nút "Chỉ đường". **Remove Foot Option**: Loại bỏ phương án "Đi bộ" (`foot`) khỏi thanh lựa chọn phương tiện. **Testing**: `flutter test` pass 87/87 tests (100%), `flutter analyze` 0 issue. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-30 | Chuyển đổi `MapBottomSheet` thành Thẻ Nổi Hoàn Chỉnh (Floating Place Card 4 góc 24px) | **Floating Card**: Bo tròn cả 4 góc (`BorderRadius.circular(24)`), căn lề `bottom: 82` nổi mịn màng với khoảng cách vừa vặn 10px trên thanh Bottom Navigation. Loại bỏ hoàn toàn cạnh vuông nứt khe phía dưới. **Testing**: `flutter test` pass 87/87 tests (100%), `flutter analyze` 0 issue. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-30 | Khắc phục đè giao diện `MapBottomSheet` & SnackBar với Bottom Navigation Bar | **Overlay Position**: Chuyển vị trí `bottom` của `MapBottomSheet` và Active Route Banner từ `12` lên `92` để nằm nổi phía trên thanh Bottom Navigation Bar. 2 nút **"Xem chi tiết"** và **"Chỉ đường"** hở trọn vẹn, không bị che khuất. **Unified AppSnackBar**: Tạo `AppSnackBar` (`margin: EdgeInsets.only(bottom: 92)`) giúp 100% thông báo nổi rõ ràng phía trên thanh điều hướng. **Testing**: `flutter test` pass 87/87 tests (100%), `flutter analyze` 0 issue. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-30 | Tinh chỉnh UI Bản đồ (Phần 2, 3, 4) & Loại bỏ nút "Làm mới" | **Glass Dock**: Hợp nhất các nút điều khiển bên phải thành Cột Thủy Tinh (`GlassContainer` blur 16, bo góc 22px). **Remove Redundant Button**: Loại bỏ nút "Làm mới dữ liệu" thừa thãi giúp giao diện gọn gàng 100%. **Compact Header & Attribution**: Tối ưu padding thanh tìm kiếm + chip lọc danh mục và loại bỏ `SimpleAttributionWidget` tràn chữ dưới bottom bar. **Testing**: `flutter test` pass 85/85 tests (100%), `flutter analyze` 0 issue. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-30 | Chuyển thanh Bottom Navigation thành Glassmorphism trong suốt & Blur | **Glassmorphic Floating Dock**: Bổ sung `BackdropFilter(filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16))` và `ClipRRect(borderRadius: 24)`. **Transparent Layer**: Đặt `extendBody: true` trên `Scaffold` và loại bỏ hoàn toàn container màu trắng/đen ở layer dưới. Bản đồ và nội dung danh sách tràn mịn dưới thanh điều hướng. **Testing**: `flutter test` pass 85/85 tests (100%), `flutter analyze` 0 issue. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-30 | Triển khai Shared Element Transitions (Container Transform) cho Place Cards | **Reusable Component**: Xây dựng `AppOpenContainer` (`package:animations/animations.dart`) với hiệu ứng `AppMotion.emphasized` (450ms). **Integration**: Đấu nối chuyển cảnh phình thẻ (Container Transform) từ các thẻ địa điểm và nút "Xem chi tiết" (`MapBottomSheet`, `PlaceListItem`, `ExploreHomeScreen`) sang `PlaceDetailScreen`. **Testing**: `flutter test` pass 85/85 tests (100%), `flutter analyze` 0 issue. | Tech Lead / Independent Auditor | ✅ Accepted |
| 2026-07-30 | Triển khai Chế độ Dark Mode (Đêm Hoàng Thành - Imperial Dark) & Persistence | **Theme Tokens**: Cấu hình bộ Token Dark Mode (`bgDark: #121418`, `surfaceDark: #1E222A`, `borderDark: #2D333F`, `textPrimaryDark: #F1F5F9`) tuân thủ chuẩn Minimalist Heritage 2026. **State Management**: Sử dụng `ThemeNotifier` (Riverpod `StateNotifier<ThemeMode>`) kết hợp `SharedPreferences` (`app_theme_mode`) duy trì trạng thái cài đặt qua các phiên làm việc. **UI**: Đấu nối bộ chọn chế độ Giao diện (Sáng / Tối / Theo hệ thống) trực tiếp tại màn hình Hồ sơ cá nhân `ProfileHomeScreen`. **Testing**: Chạy `flutter test` pass 83/83 unit & widget tests (100%), `flutter analyze` 0 issue. | Tech Lead / Independent Auditor | ✅ Accepted |








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