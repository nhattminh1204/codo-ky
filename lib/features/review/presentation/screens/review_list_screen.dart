import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';

class ReviewListScreen extends StatefulWidget {
  final String? placeId;

  const ReviewListScreen({
    super.key,
    this.placeId,
  });

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _reviews = const [
    {
      'id': 'r1',
      'userName': 'Lê Hoàng Nam',
      'userAvatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
      'rating': 5.0,
      'date': '24/07/2026',
      'comment': 'Đại Nội Huế tuyệt đẹp! Không gian mang đậm dấu ấn lịch sử triều Nguyễn. Nên đi vào buổi sáng sớm hoặc chiều muộn để tránh nắng và có ánh sáng chụp hình đẹp nhất.',
      'likes': 24,
      'isVerified': true,
      'images': [
        'https://images.unsplash.com/photo-1596436889106-be35e843f974?w=600&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1548013146-72479768bada?w=600&auto=format&fit=crop&q=80',
      ],
      'tags': ['🏰 Di sản', '📸 Phóng cảnh đẹp'],
    },
    {
      'id': 'r2',
      'userName': 'Trần Thị Thu Hà',
      'userAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
      'rating': 4.8,
      'date': '20/07/2026',
      'comment': 'Món ăn đậm đà chuẩn vị Huế. Nước dùng bún bò rất thơm nồng mùi mắm ruốc và sả. Nhân viên phục vụ nhanh nhẹn nhiệt tình!',
      'likes': 18,
      'isVerified': true,
      'images': [],
      'tags': ['🍜 Món ăn ngon', '💰 Giá hợp lý'],
    },
    {
      'id': 'r3',
      'userName': 'Nguyễn Minh Trí',
      'userAvatar': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150&auto=format&fit=crop&q=80',
      'rating': 5.0,
      'date': '15/07/2026',
      'comment': 'Không gian yên bình thanh tịnh. Ngồi ngắm tháp Phước Duyên bên bờ sông Hương thực sự mang lại cảm giác thư thái tâm hồn.',
      'likes': 15,
      'isVerified': false,
      'images': [
        'https://images.unsplash.com/photo-1548013146-72479768bada?w=600&auto=format&fit=crop&q=80',
      ],
      'tags': ['⛩️ Chùa cổ', '🌿 Cảnh quan'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Đánh giá từ du khách',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1E1E)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/map');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            // 1. RATING SUMMARY OVERVIEW CARD
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Score Column
                    Column(
                      children: [
                        const Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF7A00),
                            height: 1.1,
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB800)),
                            Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB800)),
                            Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB800)),
                            Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB800)),
                            Icon(Icons.star_half_rounded, size: 16, color: Color(0xFFFFB800)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '342 Đánh giá',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Container(height: 70, width: 1, color: const Color(0xFFF1F5F9)),
                    const SizedBox(width: 16),

                    // Progress Bars Column
                    Expanded(
                      child: Column(
                        children: [
                          _buildRatingProgressRow('5 sao', 0.85),
                          _buildRatingProgressRow('4 sao', 0.10),
                          _buildRatingProgressRow('3 sao', 0.03),
                          _buildRatingProgressRow('2 sao', 0.01),
                          _buildRatingProgressRow('1 sao', 0.01),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. WRITE REVIEW TRIGGER CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4EB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFEAD8)),
                ),
                child: Row(
                  children: [
                    const Text('🌟', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bạn đã ghé thăm nơi này?',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                          ),
                          Text(
                            'Chia sẻ trải nghiệm để nhận ngay +20 điểm thưởng',
                            style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => context.push('/reviews/write'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7A00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: const Text('Viết ngay', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

            // 3. FILTER CHIPS BAR
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
              child: Row(
                children: [
                  _buildFilterChip('all', 'Tất cả (342)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('photo', 'Có hình ảnh 📸'),
                  const SizedBox(width: 8),
                  _buildFilterChip('5star', '5 Sao ⭐'),
                  const SizedBox(width: 8),
                  _buildFilterChip('recent', 'Mới nhất 🕒'),
                ],
              ),
            ),

            // 4. REVIEWS LIST
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: _reviews.map((r) => _buildReviewCard(r)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingProgressRow(String label, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 6,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFFFB800)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String id, String label) {
    final isSelected = _selectedFilter == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF7A00) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> r) {
    final List<String> images = r['images'] as List<String>;
    final List<String> tags = r['tags'] as List<String>;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(r['userAvatar'] as String),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            r['userName'] as String,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                          ),
                          if (r['isVerified'] == true) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF00B87C)),
                          ],
                        ],
                      ),
                      Text(
                        r['date'] as String,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
                      const SizedBox(width: 2),
                      Text(
                        '${r['rating']}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Comment
            Text(
              r['comment'] as String,
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
            ),
            const SizedBox(height: 8),

            // Image Thumbnails if any
            if (images.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: images.map((img) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        img,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],

            // Tags & Like Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 6,
                  children: tags.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(t, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                    );
                  }).toList(),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã thích bài đánh giá này!'), duration: Duration(seconds: 1)),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.thumb_up_alt_outlined, size: 14, color: Color(0xFFFF7A00)),
                      const SizedBox(width: 4),
                      Text(
                        'Thích (${r['likes']})',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
