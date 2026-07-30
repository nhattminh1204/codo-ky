# Bộ Quy Tắc Thiết Kế Giao Diện (UI Rules & Design System 2026)
## Định Hướng Minimalist Heritage (Gen Z Minimalist) — CodoKy

---

### 1. Định Hướng Phong Cách (Design Philosophy)
* **Tối giản & Di sản (Minimalist Heritage)**: Sử dụng bảng màu Crimson Huế cổ kính kết hợp Nắng Hương ấm áp trên nền Kem Đất Nung nhã nhặn.
* **Không nhiễu thị giác (Zero Visual Noise)**: Loại bỏ 100% màu neon chói, dải màu gradient đa sắc và hiệu ứng bóng đổ dạ quang.
* **Năng lượng từ chuyển động & Bố cục**: Nút bấm nhún tức thì `scale(0.96)`, tiêu đề **Plus Jakarta Sans** đậm tự tin, nội dung **Be Vietnam Pro** tinh gọn.

---

### 2. Bảng Màu & Design Tokens (Color Palette)

| Thành phần Token | Giá trị HEX | Mô tả & Ý nghĩa |
| :--- | :--- | :--- |
| **Primary Brand** | `#8B1E2F` | Crimson Huế (Màu đỏ sơn son di sản Cố đô, sang trọng & đầm ấm) |
| **Secondary Accent** | `#E07A5F` | Nắng Hương (Màu hoàng hôn sông Hương ấm áp, dùng cho CTA) |
| **App Background** | `#F4F1DE` | Kem Đất Nung (Nền di sản ấm áp, thay thế xám công nghiệp) |
| **Card Surface** | `#FFFFFF` | Thẻ trắng tinh khôi viền mỏng `#E2E8F0` |
| **Active Capsule** | `rgba(139, 30, 47, 0.10)` | Nền capsule nhạt bọc icon active trên thanh điều hướng |
| **Text Primary** | `#1E293B` | Chữ tiêu đề chính (Slate 900) |
| **Text Secondary** | `#64748B` | Chữ phụ & chú thích (Slate 500) |

---

### 3. Quy Tắc Kiểu Chữ (Typography)
* **Font Tiêu đề (Headings)**: **Plus Jakarta Sans** (Phông sans-serif hình học hiện đại, 20px-24px Bold 700).
* **Font Nội dung (Body/UI)**: **Be Vietnam Pro** (Phông tối ưu hiển thị tiếng Việt, 12px-14px Medium 500).

---

### 4. Hệ Thống Bo Góc & Khoảng Cách (Radii & Spacing Grid)
* **Shell Dock**: `20px` (`rounded-2xl`)
* **Thẻ lớn Container Card**: `16px` (`AppRadius.card`)
* **Thẻ con / Input Field / Nút bấm**: `12px` (`AppRadius.button`)
* **Tag / Badges / Avatar**: `9999px` (`AppRadius.chip`)
* **Spacing Grid**: Outer padding `16px`, Inter-card gap `12px`.

---

### 5. Micro-interactions & Microcopy
* **Chuyển động**: `AppMotion.pressScale = 0.96`, animation 200ms `Curves.easeOutCubic`.
* **Microcopy**: Trực tiếp, ngắn gọn, gần gũi ("Lưu chuyến đi", "Khám phá Huế ngay", "Lịch trình của bạn").
