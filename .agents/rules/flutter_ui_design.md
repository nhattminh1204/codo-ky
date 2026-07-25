---
description: Quy chuẩn thiết kế UI/UX Flutter hiện đại (2026 Modern Aesthetic)
activation: glob
globs: "lib/presentation/**/*.dart, lib/views/**/*.dart, lib/widgets/**/*.dart, lib/screens/**/*.dart"
---

# RULES CHUẨN UI/UX FLUTTER DÀNH CHO GEMINI 3.6 FLASH

Khi viết hoặc refactor bất kỳ widget Flutter UI nào, bạn BẮT BUỘC tuân thủ các quy tắc thiết kế sau:

## 1. Gradient & Depth (Màu sắc & Chiều sâu)
- **Hero Background**: Sử dụng `Container` kết hợp `BoxDecoration(gradient: LinearGradient(...))` với màu sáng chuyển mượt (Cam Sunset: `0xFFFF5E62` -> `0xFFFF9966`).
- **Nền thẻ (Cards)**: Dùng màu xám nhạt trung tính `0xFFF8FAFC` hoặc màu trắng `Colors.white` phủ bóng mờ `BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: Offset(0, 6))`.
- **Tuyệt đối KHÔNG** xài màu nổi gắt thuần 100% (như `Colors.red`, `Colors.orange` nguyên bản) cho border/background. Dùng tint 10% opacity (`color.withOpacity(0.1)`).

## 2. Modern Rounded Corners & Spacing
- Bán kính bo góc (BorderRadius):
  - Card chính: `BorderRadius.circular(24)`
  - Card nhỏ / Input / ListTile: `BorderRadius.circular(16)`
  - Chip / Tag: `BorderRadius.circular(12)`
  - Avatar & Badges: `BorderRadius.circular(999)` hoặc `BoxShape.circle`
- Padding: Giữ khoảng cách lề màn hình tối thiểu `EdgeInsets.symmetric(horizontal: 20)`.

## 3. Positioned Badges & Avatars
- Avatar phải sử dụng `Stack` kèm `Alignment.center`.
- Khi đặt Huy hiệu (Level Badge) đè lên Avatar: Sử dụng `Positioned(top: -10, ...)` kết hợp `Clip.none` ở Stack cha.
- Nút Edit Camera: Sử dụng `Positioned(bottom: 0, right: 0)`.

## 4. Anti-Clipping & Scroll Padding
- Khi màn hình có **Floating Bottom Navigation Bar**, BẮT BUỘC bọc nội dung trong `SingleChildScrollView` và thêm `padding: EdgeInsets.only(bottom: 110)`.
- Không để các thẻ Chips/Tags bị khuất đè lên nhau hoặc trôi xuống dưới Bottom Bar.

## 5. Clean Custom Chips
- Thẻ sở thích/nhãn phải bọc trong `Wrap(spacing: 8, runSpacing: 8)`.
- Thiết kế Chip nhẹ nhàng:
  - `color`: `color.withOpacity(0.08)`
  - `border`: `Border.all(color: color.withOpacity(0.3), width: 1)`
  - `borderRadius`: `BorderRadius.circular(12)`
  - Inner padding: `EdgeInsets.symmetric(horizontal: 12, vertical: 6)`