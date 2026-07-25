---
name: flutter-ui-refactor
description: Refactors ugly Flutter UI into a modern, polished, pixel-perfect interface with sunset gradients, glassmorphism, soft shadows, custom chips, floating dock, and exact spacing matching web/canva mockups. Trigger when user asks to polish, beautify, optimize, or fix Flutter UI/screens.
---

# SKILL: FLUTTER UI REFACTORING ENGINE

Skill này hướng dẫn Gemini 3.6 Flash nâng cấp toàn bộ màn hình Flutter UI theo đúng tỷ lệ và phong cách thiết kế cao cấp.

## Hướng dẫn từng bước thực thi (Step-by-Step Logic)

1. **Phân tích Code UI hiện tại**:
   - Nhận diện các lỗi layout: Cắt mép Bottom Dock, viền màu gắt, Avatar bị lệch, Gradient thiếu tương phản.
   - Nhận diện các widget thô (`Chip`, `ElevatedButton` mặc định, `Card` có viền cứng) để thay bằng `Container` có `BoxDecoration` tùy chỉnh.

2. **Dựng lại Cấu trúc Layout (Scaffold & Stack)**:
   - Nền chính: `Scaffold(backgroundColor: const Color(0xFFF8FAFC))`
   - Sử dụng `Stack` bao ngoài cùng để xếp lớp:
     - Layer 1: Scrollable Content (`SingleChildScrollView`) có `padding: EdgeInsets.only(bottom: 120)`
     - Layer 2: Floating Bottom Navigation Dock nằm ở `Positioned(bottom: 16, left: 16, right: 16)`

3. **Tái tạo Hero Gradient Banner & Glassmorphism Header**:
   - Dựng Banner Gradient bằng `Container(height: 180, decoration: BoxDecoration(gradient: LinearGradient(...)))`.
   - Dựng Avatar Frame tròn với viền `BoxShadow(color: Color(0xFFF97316).withOpacity(0.3), blurRadius: 20)`.

4. **Tối ưu Bảng Chỉ số (Quick Stats Row)**:
   - Tạo Row gồm 3 cột: [Lịch trình] | [Đánh giá / Sao] | [Điểm thưởng].
   - Bọc trong `Container` màu trắng bo góc 20, thêm shadow nhẹ.
   - Số điểm `TextStyle(fontSize: 18, fontWeight: FontWeight.bold)`.

5. **Nhóm các ListTile trong Container duy nhất**:
   - Không tạo các ListTile riêng lẻ biệt lập.
   - Bọc 3 mục (Lịch trình, Đánh giá, Địa điểm đã lưu) vào **1 Container duy nhất** có `BorderRadius.circular(20)`.
   - Thêm đường kẻ ngang nhẹ `Divider(height: 1, color: Color(0xFFF1F5F9))` giữa các item.

6. **Refactor thẻ Sở thích (Interest Tag Chips)**:
   - Dùng `Wrap(spacing: 8, runSpacing: 8, children: [...])`.
   - Mỗi Chip gồm Icon/Emoji + Text, có nền tinted pastel nhạt và viền mảnh $1\text{px}$.

7. **Kiểm tra Pre-Flight Code**:
   - Kiểm tra xem có sử dụng `alert()` hay không (không dùng, dùng Dialog/Toast nếu cần).
   - Đảm bảo code chạy được 100%, không thiếu import, không dùng biến chưa khai báo.