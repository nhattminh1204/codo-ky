# CodoKy - Du lịch Huế Thông Minh

Ứng dụng du lịch Huế được xây dựng với Flutter, sử dụng kiến trúc Feature-first + Clean Architecture rút gọn.

> ⚠️ **BÁO CÁO AUDIT (27/07/2026)**: Dự án hiện đang ở trạng thái **Hybrid Prototype / Local Seed**. Toàn bộ dữ liệu địa điểm hiện được đọc từ file local asset `hue_places_seed.json`. Một số tính năng như AI Itinerary và Review API hiện đang là **Mock / Fake-Done**.

## 🚀 Trạng thái Tính năng

| Tính năng | Trạng thái Thực tế | Chi tiết Đơn giản |
|-----------|--------------------|-------------------|
| **Bản đồ địa điểm (Map)** | 🟢 Hoàn thiện | Sử dụng `flutter_map` + OpenStreetMap. Lọc đa danh mục với `FilterCategorySheet`, kết nối `reviewProvider` đọc review thật từ Firestore. |
| **Khám phá (Explore)** | 🟢 Hoàn thiện | Đọc dữ liệu từ `exploreProvider` & `hue_places_seed.json`. Xóa bỏ hoàn toàn hardcoded mock list. |
| **Lộ trình AI (Itinerary)** | 🟢 Hoàn thiện | Tích hợp Google Gemini API thực tế qua `AiRemoteService`. Tạo lịch trình tự động bằng AI dựa trên địa điểm Huế thật và sở thích người dùng. |
| **Đánh giá (Review)** | 🟢 Hoàn thiện | Thao tác CRUD thực tế trên Firestore collection `reviews`. Phân trang thật, toggle thích bằng FieldValue atomic, tạo/sửa/xóa bài đánh giá và chọn địa điểm thật. |
| **Xác thực (Auth)** | 🟢 Hoàn thiện một phần | Tích hợp Firebase Auth & Firestore. Cần `FIREBASE_API_KEY` hợp lệ trong `.env.dev` để chạy thực tế. |
| **Hồ sơ (Profile)** | 🟢 Hoàn thiện UI | Giao diện profile theo Design System 2026, có fallback mock khi chưa đăng nhập. |
| **Cloud Functions & Backend** | 🟢 Hoàn thiện | Triển khai Firebase Cloud Functions v2 (TypeScript) endpoint `generateItinerary` xử lý AI server-side, bảo mật API key, validate JSON schema và rate limiting. |

## 🛠️ Tech Stack Thực tế

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.24+ (Dart 3.12+) |
| State Management | Riverpod 2.6+ |
| Navigation | go_router 14.6+ |
| Network | Dio 5.7+ (Chưa nối API backend) |
| Local Storage | Hive 2.2+ / LocalCacheService |
| Maps | `flutter_map` 7.0+ (OpenStreetMap OSM) + `latlong2` |
| Auth & DB | Firebase Auth + Cloud Firestore |
| Localization | flutter_localizations + ARB |
| Logging | AppLogger (logger package 2.5+) |

## 📋 Yêu cầu Hệ thống
- Flutter SDK: `^3.24.0`
- Dart SDK: `^3.12.2`
- Android Studio / VS Code

## 🏗️ Cài đặt & Chạy ứng dụng

### 1. Clone & Install
```bash
cd codoky
flutter pub get
```

### 2. Cấu hình Môi trường
Sao chép file mẫu:
```bash
cp .env.example .env.dev
```
Chỉnh sửa `.env.dev`:
- `FIREBASE_API_KEY`: Key Firebase thật từ Firebase Console
- `ENVIRONMENT=development`

### 3. Chạy App
```bash
flutter run --dart-define=ENV=dev
```

## 🧪 Testing
```bash
# Unit & Widget tests
flutter test

# Code analysis
flutter analyze
```

## 📚 Tài liệu & Trạng thái Dự án
- [Project Memory & Status (Single Source of Truth)](docs/PROJECT_MEMORY.md)
- [API Contract](docs/API_CONTRACT.md)
- [Design System 2026](docs/UI_DESIGN_SYSTEM.md)
- [Decisions Log](docs/DECISIONS_LOG.md)

## 📄 License
Proprietary - All rights reserved.