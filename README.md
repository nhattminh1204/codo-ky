# CodoKy - Du lịch Huế Thông Minh

Ứng dụng du lịch Huế được xây dựng với Flutter, sử dụng kiến trúc Feature-first + Clean Architecture rút gọn, phù hợp cho Modular Monolith backend.

## 🚀 Tính năng chính
- **Bản đồ địa điểm (Map)**: Hiển thị các địa điểm du lịch trên bản đồ Google Maps
- **Lộ trình AI (Itinerary)**: Đề xuất lộ trình du lịch bằng AI
- **Khám phá (Explore)**: Tìm kiếm nhà hàng, địa điểm, chùa, lăng tẩm, giải trí
- **Đăng nhập (Auth)**: Xác thực người dùng
- **Đánh giá (Review)**: Viết và xem đánh giá địa điểm

## 🛠️ Tech Stack
| Category | Technology |
|----------|------------|
| Framework | Flutter 3.24+ |
| State Management | Riverpod 2.6+ |
| Navigation | go_router 14+ |
| Network | Dio 5.7+ |
| Local Storage | Hive 2.2+ |
| Maps | Google Maps Flutter 2.10+ |
| Localization | flutter_localizations + ARB |
| Logging | logger 2.5+ |
| Dependency Injection | Riverpod |

## 📋 Yêu cầu hệ thống
- Flutter SDK: `^3.24.0`
- Dart SDK: `^3.12.2`
- Android Studio / VS Code
- Xcode (for iOS development)

## 🏗️ Cài đặt dự án

### 1. Clone repository
```bash
git clone <repository-url>
cd codoky
```

### 2. Cài đặt dependencies
```bash
flutter pub get
```

### 3. Cấu hình môi trường
Sao chép file môi trường mẫu và điền thông tin:
```bash
# Development
cp .env.example .env.dev
# Staging
cp .env.example .env.staging
# Production
cp .env.example .env.production
```

Chỉnh sửa các file `.env.*` với các giá trị thực tế:
- `API_BASE_URL`: URL API backend
- `GOOGLE_MAPS_API_KEY`: Key Google Maps
- `CLAUDE_API_KEY`: Key Anthropic Claude (cho AI itinerary)

### 4. Chạy ứng dụng

#### Development
```bash
flutter run --flavor dev --dart-define=ENV=dev
# Hoặc
flutter run --dart-define=ENV=dev
```

#### Staging
```bash
flutter run --flavor staging --dart-define=ENV=staging
```

#### Production
```bash
flutter run --flavor production --dart-define=ENV=production
```

### 5. Build release

#### Android
```bash
# Debug APK
flutter build apk --flavor dev --dart-define=ENV=dev

# Release AAB
flutter build appbundle --flavor production --dart-define=ENV=production
```

#### iOS
```bash
flutter build ios --flavor production --dart-define=ENV=production --no-codesign
```

## 🧪 Testing
```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Integration tests
flutter test integration_test/

# All tests with coverage
flutter test --coverage
```

## 📁 Cấu trúc thư mục
```
lib/
├── main.dart                 # Entry point
├── app.dart                  # MaterialApp.router config
├── core/
│   ├── config/
│   │   ├── app_config.dart   # Environment config
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   └── constants/
│   ├── di/
│   │   └── providers.dart    # Global Riverpod providers
│   ├── network/
│   │   ├── api_client.dart
│   │   └── network_exceptions.dart
│   ├── storage/
│   │   ├── local_cache_service.dart
│   │   └── README.md
│   ├── logging/
│   │   └── app_logger.dart
│   └── utils/
│       ├── extensions.dart
│       ├── helpers.dart
│       └── validators.dart
├── features/
│   ├── auth/
│   ├── map/
│   ├── itinerary/
│   ├── explore/
│   └── review/
├── shared/
│   ├── widgets/
│   ├── models/
│   └── utils/
└── l10n/
    ├── app_en.arb
    └── app_vi.arb
```

## 🌐 Đa ngôn ngữ
Hỗ trợ Tiếng Việt (mặc định) và Tiếng Anh. Thêm ngôn ngữ mới:
1. Tạo file `lib/l10n/app_<locale>.arb`
2. Chạy `flutter gen-l10n`

## 🔐 Environment & Flavors
Dự án sử dụng 3 flavor:
- **dev**: Development, trỏ về API dev
- **staging**: Staging, trỏ về API staging
- **production**: Production, trỏ về API production

Cách chạy flavor:
```bash
# Sử dụng --dart-define (khuyến nghị)
flutter run --dart-define=ENV=dev

# Sử dụng --flavor (cần cấu hình native)
flutter run --flavor dev
```

## 📦 Code Generation
```bash
# Generate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode
flutter pub run build_runner watch --delete-conflicting-outputs
```

## 🔍 Code Quality
```bash
# Analyze
flutter analyze

# Format
dart format .

# Lint
flutter analyze --no-fatal-infos
```

## 📚 Tài liệu
- [API Contract](docs/API_CONTRACT.md)
- [Observability Plan](docs/OBSERVABILITY.md)
- [Decisions Log](docs/DECISIONS_LOG.md)
- [Local Storage Guide](lib/core/storage/README.md)

## 🤝 Contributing
1. Fork repository
2. Tạo feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Mở Pull Request

## 📄 License
Proprietary - All rights reserved.