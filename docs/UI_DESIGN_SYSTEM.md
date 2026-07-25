# Bộ Quy Tắc Thiết Kế Giao Diện (UI Rules & Design System 2026)
## Dành cho Hồ sơ cá nhân & Hệ sinh thái Ứng dụng Du lịch - Khám phá CodoKy

---

### 1. Định Hướng Phong Cách (Design Philosophy)
* **Trẻ trung & Năng động (Vibrant & Energetic)**: Sử dụng các gam màu gradient ấm áp, rực rỡ kết hợp bề mặt bo tròn mềm mại.
* **Đơn giản & Nhẹ nhàng (Clean & Modern)**: Phân tầng thông tin rõ ràng bằng khoảng trắng (white space) hợp lý, hạn chế đường viền cứng nhắc.
* **Chiều sâu & Bề mặt (Depth & Glassmorphism)**: Kết hợp hiệu ứng đổ bóng mờ (soft glow shadow) và kính trong suốt (glassmorphism backdrop blur) giúp giao diện có chiều sâu sống động.
* **Ưu tiên di động (Mobile-First & Touch-Friendly)**: Mọi khu vực bấm/chạm phải đảm bảo kích thước tối thiểu, phản hồi tức thì với thao tác vuốt/chạm.

---

### 2. Bảng Màu & Design Tokens (Color Palette)

#### 2.1. Chủ đề màu chính (Dynamic Accent Themes)
Giao diện hỗ trợ 3 linh hồn màu sắc có thể tùy biến linh hoạt:

1. **Cam Hoàng Hôn (Sunset Amber - Mặc định)**:
   * **Primary Gradient**: `linear-gradient(135deg, #ff5e62, #ff9966)` / `AppGradients.sunsetGradient`
   * **Accent Color**: `#f97316` (Tailwind `orange-500` / `AppColors.secondary`)
   * **Glow Shadow**: `rgba(249, 115, 22, 0.35)`
   * **Ý nghĩa**: Ấm áp, tràn đầy năng lượng, phù hợp với hành trình và khám phá Huế.

2. **Tím Cyber (Cyber Purple)**:
   * **Primary Gradient**: `linear-gradient(135deg, #8e2de2, #4a00e0)`
   * **Accent Color**: `#a855f7` (Tailwind `purple-500`)
   * **Glow Shadow**: `rgba(168, 85, 247, 0.35)`
   * **Ý nghĩa**: Hiện đại, công nghệ, trẻ trung và sáng tạo.

3. **Xanh Neon (Teal Emerald)**:
   * **Primary Gradient**: `linear-gradient(135deg, #00b09b, #96c93d)`
   * **Accent Color**: `#10b981` (Tailwind `emerald-500`)
   * **Glow Shadow**: `rgba(16, 185, 129, 0.35)`
   * **Ý nghĩa**: Tươi mát, thiên nhiên, tự do.

#### 2.2. Nền & Bề mặt (Background & Surface Tokens)

| Thành phần | Light Mode | Dark Mode | Chức năng |
| :--- | :--- | :--- | :--- |
| **App Background** | `#f8fafc` (slate-100 / `#F9F6F0`) | `#020617` (slate-950) | Nền tổng thể mềm mại |
| **Card Surface** | `#ffffff` | `#1e293b` (slate-800/80) | Thẻ chứa thông tin |
| **Glass Card** | `rgba(255,255,255, 0.85)` | `rgba(30,41,59, 0.85)` | Thẻ kính phủ hiệu ứng mờ |
| **Border Soft** | `#f1f5f9` (slate-100) | `rgba(255,255,255, 0.08)` | Viền chia thẻ nhẹ nhàng |
| **Text Primary** | `#0f172a` (slate-900) | `#f8fafc` (slate-50) | Tiêu đề, chữ chính |
| **Text Muted** | `#64748b` (slate-500) | `#94a3b8` (slate-400) | Chú thích, label |

---

### 3. Quy Tắc Kiểu Chữ (Typography)
* **Font Family**: `Plus Jakarta Sans` hoặc `BeVietnamPro` / `Inter` (Font không chân hiện đại, tối ưu hiển thị tiếng Việt mượt mà trên màn hình độ phân giải cao).
* **Phân cấp kiểu chữ**:
  * `[Screen Title]`: `20px` / Bold (700) - *"Hồ sơ cá nhân"*
  * `[User Name]`: `20px` / ExtraBold (800) - *"Nguyễn Văn Minh Nhật"*
  * `[Section Title]`: `12px` / Bold (700) - UPPERCASE + `tracking-wider`
  * `[Card Main Text]`: `14px` / Bold (700) - *"Lịch trình của tôi"*
  * `[Sub-text/Body]`: `12px` / Medium (500) - *"nhattminh1204@gmail.com"*
  * `[Badge/Tag Text]`: `11px` / SemiBold (600) - *"✈️ Du lịch bụi"*

---

### 4. Hệ Thống Bo Góc & Khoảng Cách (Radii & Spacing Grid)

#### 4.1. Bo góc (Border Radius Rules)
* **Khung Mobile Shell**: `40px` (`rounded-[40px]`)
* **Thẻ lớn / Container Card**: `24px` (`rounded-3xl` / `rounded-2xl` / `AppRadius.lg`)
* **Thẻ con / Input Field / Nút bấm**: `16px` (`rounded-2xl` / `rounded-xl` / `AppRadius.button`)
* **Tag / Huy hiệu / Avatar**: `9999px` (`rounded-full` / `AppRadius.chip`)

#### 4.2. Khoảng cách (Spacing & Padding Rules)
* **Padding viền ngoài thiết bị**: `20px` (`px-5` / `AppSpacing.lg`)
* **Khoảng cách giữa các Section**: `16px - 20px` (`space-y-4` / `space-y-5`)
* **Gap giữa các thẻ/tag con**: `6px - 8px` (`gap-1.5` / `gap-2`)

---

### 5. Quy Chuẩn Các Thành Phần UI (Component Standards)

#### 5.1. Thẻ Avatar & Định Danh (Hero Avatar Section)
* **Avatar Container**: Khung tròn `w-28 h-28` có viền Gradient Glow dạ quang nhẹ (`shadow-theme-glow`).
* **Level Badge**: Huy hiệu nổi đè phía trên Avatar góc `top-0` (`crown icon` + màu nền `amber-400` metallic).
* **Nút đổi ảnh**: Nút tròn nằm ở góc `bottom-1 right-1` trên viền Avatar với hiệu ứng phóng to khi hover (`hover:scale-110`).

#### 5.2. Thẻ Thống Kê Nhanh (Quick Stats Bar)
* Chia làm 3 cột bằng nhau đại diện cho `[Lịch trình]` \| `[Đánh giá / Sao]` \| `[Điểm thưởng]`.
* Phông số nổi bật (`Font size 18px`, `Font weight Black - 900`).
* Nền kính mờ nhung (`bg-white/90 backdrop-blur`) nằm đè nhẹ lên góc thẻ bên dưới.

#### 5.3. Danh Sách Nhóm Chức Năng (Grouped Action List)
* Bọc toàn bộ các mục liên quan vào 1 thẻ lớn duy nhất (Tránh việc mỗi mục là 1 thẻ riêng lẻ làm nát giao diện).
* Phân cách các dòng bằng đường phân chia siêu nhẹ (`divide-y divide-slate-100`).
* Icon ở đầu dòng bọc trong ô vuông bo góc `w-10 h-10` (`rounded-xl`) có màu nền pastel tương ứng (`opacity 10%`).
* Đầu cuối mỗi dòng có icon mũi tên `chevron-right` gợi ý hành động chuyển trang.

#### 5.4. Thẻ Nhãn Sở Thích (Interest Tags System)
* **KHÔNG** hiển thị dạng văn bản dòng *"Chưa chọn sở thích"*.
* Hiển thị dạng danh sách nhãn (Pill Badges) đa sắc:
  * Nền màu nhạt (tinted background) `opacity 10-15%`.
  * Đường viền mỏng đồng màu `opacity 40%`.
  * Kết hợp Emoji minh họa sinh động (`✈️ Du lịch`, `☕ Cà phê`, `📸 Nhiếp ảnh`).

#### 5.5. Nút Bấm Thực Thi (CTA Buttons)
* **Nút Chính (Primary Action - Chỉnh sửa hồ sơ)**:
  * Phủ Gradient thương hiệu `bg-theme-gradient`.
  * Chiều cao lớn (`py-3.5`), font chữ đậm `fontWeight: 700`.
  * Bóng đổ màu rực rỡ (`shadow-theme-glow`), hiệu ứng thu nhỏ nhẹ khi bấm (`active:scale-[0.98]`).
* **Nút Phụ / Cảnh Báo (Secondary / Logout Action)**:
  * Nền màu xám trung tính nhẹ (`slate-100` / `slate-800`).
  * Khi hover/press chuyển dần sang màu hồng/đỏ nhạt cảnh báo (`hover:bg-rose-50 hover:text-rose-600`).

#### 5.6. Thanh Điều Hướng Đáy Floating Dock (Bottom Navigation)
* Nằm lơ lửng cách mép đáy màn hình `12px` (`bottom-3 left-4 right-4`).
* Thiết kế dạng dock màu tối sang trọng (`slate-900/90 backdrop-blur-xl`) bo cong `rounded-3xl`.
* **Nút tạo mới trung tâm (Center Action)**: Thiết kế nổi trồi lên trên thanh dock với icon `plus-circle` rực rỡ.
* **Tab đang kích hoạt (Active Tab)**: Có chấm nhỏ phát sáng phía dưới (`Active Pill Dot`) và icon đổi sang màu Accent.

---

### 6. Quy Tắc Tương Tác & Phản Hồi (Interaction & Micro-Animations)
* **Hiệu ứng Chuyển cảnh (Transitions)**: Mọi trạng thái Hover, Active, Focus đều sử dụng `transition-all duration-300 ease-out`.
* **Thông báo Phản hồi (Toast System)**: **KHÔNG bao giờ** sử dụng hàm popup mặc định `alert()` hay `confirm()`. Sử dụng thẻ Toast Notification tự tạo xuất hiện nhẹ nhàng từ mép trên màn hình, tự ẩn sau 2.2 giây.
* **Cửa sổ Nổi (Modal Sheets)**: Trên thiết bị di động: Trượt từ dưới lên dạng Bottom Sheet (`translate-y-10 -> translate-y-0`) phủ lớp nền làm mờ nội dung sau lưng (`backdrop-blur-sm bg-slate-900/60`).

---

### 7. Đánh Giá Đối Chiếu UI Cũ & UI Mới (Before vs After)

| Tiêu chí | Giao diện cũ | Giao diện tối ưu mới |
| :--- | :--- | :--- |
| **Banner Đầu trang** | Trống trắc, thẻ vuông vức đơn điệu | Banner Gradient rực rỡ + Thẻ Glassmorphism bồng bềnh |
| **Chỉ số tương tác** | Không có | Bổ sung Quick Stats (Chuyến đi, Đánh giá, Điểm thưởng) |
| **Sở thích cá nhân** | Dòng chữ xám "Chưa chọn sở thích" | Hệ thống Tag Emoji bắt mắt, có nút chỉnh sửa nhanh |
| **Danh sách chức năng** | Icon đơn sắc 2D, viền chia cứng | Icon pastel nổi bật, nhóm thẻ bo tròn divide-y mềm mại |
| **Nút bấm (Buttons)** | Khung viền mỏng đỏ cứng nhắc | Nút Gradient Glow hiện đại, hỗ trợ hiệu ứng pressed state |
| **Bottom Dock** | Nút "Bản đồ" màu cam bị lệch phông | Dock đen sang trọng, nút trung tâm nổi Floating bắt mắt |
