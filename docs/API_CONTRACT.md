# API Contract - CodoKy

## Overview
Tài liệu này mô tả giao diện API giữa Frontend (Flutter) và Backend (Modular Monolith).
Tất cả endpoint có tiền tố `/api/v1`.

## Base URL
- Development: `https://api-dev.codoky.com/api/v1`
- Staging: `https://api-staging.codoky.com/api/v1`
- Production: `https://api.codoky.com/api/v1`

## Authentication
- JWT Bearer Token trong header `Authorization: Bearer <token>`
- Token expiry: 24h access, 30d refresh
- Refresh endpoint: `POST /auth/refresh`

---

## 1. Auth Module

### 1.1 Đăng ký
```
POST /auth/register
```
**Request:**
```json
{
  "full_name": "string",
  "email": "string",
  "phone": "string",
  "password": "string"
}
```

**Response (201):**
```json
{
  "access_token": "string",
  "refresh_token": "string",
  "user": {
    "id": "string",
    "full_name": "string",
    "email": "string",
    "phone": "string",
    "avatar_url": "string|null",
    "created_at": "ISO8601"
  }
}
```

### 1.2 Đăng nhập
```
POST /auth/login
```
**Request:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response (200):** Same as register

### 1.3 Làm mới token
```
POST /auth/refresh
```
**Request:**
```json
{
  "refresh_token": "string"
}
```

**Response (200):**
```json
{
  "access_token": "string",
  "refresh_token": "string"
}
```

### 1.4 Đăng xuất
```
POST /auth/logout
```
**Headers:** Authorization required
**Response (200):** `{ "message": "Logged out successfully" }`

### 1.5 Quên mật khẩu
```
POST /auth/forgot-password
```
**Request:** `{ "email": "string" }`

### 1.6 Đặt lại mật khẩu
```
POST /auth/reset-password
```
**Request:**
```json
{
  "token": "string",
  "password": "string",
  "password_confirmation": "string"
}
```

### 1.7 Lấy thông tin user hiện tại
```
GET /auth/me
```
**Headers:** Authorization required
**Response (200):**
```json
{
  "id": "string",
  "full_name": "string",
  "email": "string",
  "phone": "string",
  "avatar_url": "string|null",
  "created_at": "ISO8601",
  "preferences": {
    "locale": "vi|en",
    "theme": "light|dark|system",
    "notifications_enabled": true
  }
}
```

### 1.8 Cập nhật profile
```
PATCH /auth/me
```
**Headers:** Authorization required
**Request:** (All optional)
```json
{
  "full_name": "string",
  "phone": "string",
  "avatar_url": "string",
  "preferences": { ... }
}
```

---

## 2. Places Module (Địa điểm)

### 2.1 Danh sách địa điểm (có filter, search, pagination)
```
GET /places
```
**Query Parameters:**
| Param | Type | Description |
|-------|------|-------------|
| `category` | string | restaurant, attraction, temple, tomb, entertainment |
| `lat` | float | Vĩ độ user (để sort theo khoảng cách) |
| `lng` | float | Kinh độ user |
| `radius` | int | Bán kính km (default: 50) |
| `q` | string | Từ khóa tìm kiếm |
| `min_rating` | float | Lọc theo rating tối thiểu |
| `sort` | string | distance, rating, review_count, popular |
| `page` | int | Trang (default: 1) |
| `per_page` | int | Số lượng/trang (default: 20, max: 50) |

**Response (200):**
```json
{
  "data": [
    {
      "id": "string",
      "name": "string",
      "slug": "string",
      "description": "string",
      "category": "restaurant|attraction|temple|tomb|entertainment",
      "address": "string",
      "lat": 16.4637,
      "lng": 107.5909,
      "phone": "string|null",
      "website": "string|null",
      "opening_hours": "string|null",
      "images": ["string"],
      "thumbnail": "string|null",
      "rating": 4.5,
      "review_count": 120,
      "price_level": 1|2|3|4|null,
      "tags": ["string"],
      "is_favorite": false,
      "distance_km": 2.3,
      "created_at": "ISO8601",
      "updated_at": "ISO8601"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total": 150,
    "last_page": 8
  }
}
```

### 2.2 Chi tiết địa điểm
```
GET /places/{id}
```
**Response (200):** Single place object (same as list item but with more fields)
- Thêm: `gallery`, `amenities`, `reviews_summary`, `itineraries_count`

### 2.3 Địa điểm gần đây
```
GET /places/nearby
```
**Query:** `lat`, `lng`, `radius` (km), `category?`, `limit?`
**Response:** Array of places sorted by distance

### 2.4 Phổ biến
```
GET /places/popular
```
**Query:** `category?`, `limit?`, `timeframe?` (day|week|month)
**Response:** Array of places sorted by review_count/views

### 2.5 Tìm kiếm gợi ý (autocomplete)
```
GET /places/suggestions
```
**Query:** `q` (min 2 chars), `limit?` (default: 10)
**Response:** Array of `{ id, name, category, address }`

### 2.6 Danh mục
```
GET /places/categories
```
**Response:**
```json
[
  { "id": "restaurant", "name": "Nhà hàng", "icon": "restaurant", "count": 45 },
  { "id": "attraction", "name": "Địa điểm", "icon": "place", "count": 30 },
  { "id": "temple", "name": "Chùa", "icon": "temple", "count": 15 },
  { "id": "tomb", "name": "Lăng tẩm", "icon": "monument", "count": 8 },
  { "id": "entertainment", "name": "Giải trí", "icon": "games", "count": 12 }
]
```

---

## 3. Itinerary Module (Lộ trình)

### 3.1 Danh sách lộ trình của user
```
GET /itineraries
```
**Headers:** Authorization required
**Query:** `page`, `per_page`, `status` (draft|published|archived)
**Response:** Paginated list

### 3.2 Tạo lộ trình mới
```
POST /itineraries
```
**Headers:** Authorization required
**Request:**
```json
{
  "title": "string",
  "description": "string",
  "duration_days": 3,
  "estimated_budget": 2000000,
  "interests": ["culture", "food", "history"],
  "start_date": "2024-01-15|null",
  "is_ai_generated": false
}
```

### 3.3 Chi tiết lộ trình
```
GET /itineraries/{id}
```
**Headers:** Authorization required (owner or public)
**Response:**
```json
{
  "id": "string",
  "user_id": "string",
  "title": "string",
  "description": "string",
  "duration_days": 3,
  "estimated_budget": 2000000,
  "actual_budget": 1850000,
  "interests": ["culture", "food"],
  "start_date": "2024-01-15|null",
  "end_date": "2024-01-17|null",
  "status": "published",
  "is_ai_generated": false,
  "thumbnail": "string|null",
  "rating": 4.8,
  "review_count": 15,
  "view_count": 1200,
  "days": [
    {
      "day_number": 1,
      "title": "Khám phá Cidad Imperial",
      "description": "Ngày đầu tiên...",
      "activities": [
        {
          "id": "string",
          "place_id": "string",
          "place_name": "string",
          "place_category": "attraction",
          "lat": 16.4637,
          "lng": 107.5909,
          "start_time": "08:00",
          "end_time": "10:30",
          "type": "visit",
          "notes": "Mua vé combo",
          "estimated_cost": 150000,
          "transport_mode": "walk|bike|car|taxi",
          "order": 1
        }
      ],
      "total_estimated_cost": 500000,
      "total_distance_km": 15.5
    }
  ],
  "created_at": "ISO8601",
  "updated_at": "ISO8601"
}
```

### 3.4 Cập nhật lộ trình
```
PATCH /itineraries/{id}
```

### 3.5 Xóa lộ trình
```
DELETE /itineraries/{id}
```

### 3.6 Tạo lộ trình bằng AI
```
POST /itineraries/ai-generate
```
**Headers:** Authorization required
**Request:**
```json
{
  "duration_days": 3,
  "budget_vnd": 2000000,
  "interests": ["culture", "food", "history", "photo"],
  "travel_style": "relaxed|balanced|packed",
  "accommodation_type": "homestay|hotel|resort",
  "group_size": 2,
  "special_requirements": "string|null"
}
```
**Response (202 - Async):**
```json
{
  "task_id": "string",
  "status": "processing",
  "estimated_time_seconds": 30
}
```

### 3.7 Kiểm tra trạng thái AI generation
```
GET /itineraries/ai-generate/{task_id}
```
**Response:**
```json
{
  "task_id": "string",
  "status": "completed|failed",
  "itinerary_id": "string|null",
  "error": "string|null"
}
```

### 3.8 Clone lộ trình công khai
```
POST /itineraries/{id}/clone
```
**Headers:** Authorization required

### 3.9 Danh sách lộ trình công khai (khám phá)
```
GET /itineraries/public
```
**Query:** `page`, `per_page`, `duration_days`, `budget_min`, `budget_max`, `sort` (popular|recent|rating)

---

## 4. Reviews Module (Đánh giá)

### 4.1 Danh sách review của một place
```
GET /places/{place_id}/reviews
```
**Query:** `page`, `per_page`, `sort` (recent|helpful|rating_high|rating_low), `rating` (1-5)
**Response:** Paginated list

### 4.2 Tạo review mới
```
POST /places/{place_id}/reviews
```
**Headers:** Authorization required
**Request:**
```json
{
  "rating": 5,
  "title": "string",
  "content": "string",
  "images": ["base64_or_url"],
  "visit_date": "2024-01-15"
}
```

### 4.3 Cập nhật review
```
PATCH /reviews/{id}
```
**Headers:** Authorization required (owner)

### 4.4 Xóa review
```
DELETE /reviews/{id}
```
**Headers:** Authorization required (owner)

### 4.5 Thích/Bỏ thích review
```
POST /reviews/{id}/like
DELETE /reviews/{id}/like
```

### 4.6 Báo cáo review
```
POST /reviews/{id}/report
```
**Request:** `{ "reason": "spam|inappropriate|fake|other", "details": "string" }`

### 4.7 Review của tôi
```
GET /reviews/mine
```
**Headers:** Authorization required
**Query:** `page`, `per_page`

---

## 5. Favorites Module (Yêu thích)

### 5.1 Danh sách yêu thích
```
GET /favorites
```
**Headers:** Authorization required
**Query:** `category?`, `page`, `per_page`

### 5.2 Thêm vào yêu thích
```
POST /favorites
```
**Request:** `{ "place_id": "string" }`

### 5.3 Xóa khỏi yêu thích
```
DELETE /favorites/{place_id}
```

### 5.4 Kiểm tra đã yêu thích
```
GET /favorites/check/{place_id}
```
**Response:** `{ "is_favorite": true }`

---

## Error Responses

### 400 Bad Request
```json
{
  "error": "validation_error",
  "message": "Validation failed",
  "details": [
    { "field": "email", "message": "Invalid email format" }
  ]
}
```

### 401 Unauthorized
```json
{
  "error": "unauthorized",
  "message": "Authentication required"
}
```

### 403 Forbidden
```json
{
  "error": "forbidden",
  "message": "Access denied"
}
```

### 404 Not Found
```json
{
  "error": "not_found",
  "message": "Resource not found"
}
```

### 422 Unprocessable Entity
```json
{
  "error": "unprocessable",
  "message": "Business logic validation failed",
  "details": [...]
}
```

### 429 Too Many Requests
```json
{
  "error": "rate_limited",
  "message": "Too many requests",
  "retry_after": 60
}
```

### 500 Internal Server Error
```json
{
  "error": "internal_error",
  "message": "An unexpected error occurred",
  "request_id": "uuid"
}
```

---

## Rate Limiting
- Auth endpoints: 10 req/min per IP
- Places read: 100 req/min per user
- Places write: 20 req/min per user
- Itinerary AI: 5 req/hour per user
- Reviews: 30 req/hour per user

Headers returned:
- `X-RateLimit-Limit`
- `X-RateLimit-Remaining`
- `X-RateLimit-Reset`

---

## Webhooks (Future)
- `place.created`
- `place.updated`
- `review.created`
- `itinerary.published`
- `user.registered`

---

## Versioning
- URL versioning: `/api/v1/`
- Deprecation: 6 months notice
- Breaking changes only in new version

---

## Changelog
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | TBD | Initial release |