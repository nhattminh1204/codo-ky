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