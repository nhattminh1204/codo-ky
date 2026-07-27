import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';

class MyReviewsScreen extends ConsumerStatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  ConsumerState<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends ConsumerState<MyReviewsScreen> {
  final List<Map<String, dynamic>> _myReviewsList = [
    {
      'id': 'mr1',
      'placeName': 'Đại Nội Huế (Hoàng Thành)',
      'placeImage': 'https://images.unsplash.com/photo-1596436889106-be35e843f974?w=400&auto=format&fit=crop&q=80',
      'rating': 5.0,
      'date': '24/07/2026',
      'comment': 'Không gian trang nghiêm cổ kính tuyệt vời. Khuyên các bạn nên ghé tham quan vào buổi sáng sớm!',
      'likes': 24,
    },
    {
      'id': 'mr2',
      'placeName': 'Bún Bò Huế Mụ Rớt',
      'placeImage': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&auto=format&fit=crop&q=80',
      'rating': 4.8,
      'date': '20/07/2026',
      'comment': 'Tô bún bò đậm đà thơm mùi sả mắm ruốc chuẩn Huế. Giá cả rất phải chăng.',
      'likes': 18,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Đánh giá của tôi',
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
              context.go('/profile');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            // 1. STATS SUMMARY CARD
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5E62).withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryStatItem('${_myReviewsList.length}', 'Đã viết'),
                    ),
                    Container(height: 30, width: 1, color: Colors.white.withValues(alpha: 0.3)),
                    Expanded(
                      child: _buildSummaryStatItem('42', 'Lượt thích'),
                    ),
                    Container(height: 30, width: 1, color: Colors.white.withValues(alpha: 0.3)),
                    Expanded(
                      child: _buildSummaryStatItem('+960đ', 'Xu thưởng'),
                    ),
                  ],
                ),
              ),
            ),

            // 2. MY REVIEWS LIST
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'DANH SÁCH NHẬN XẾT ĐÃ ĐĂNG',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/reviews/write'),
                        child: const Row(
                          children: [
                            Icon(Icons.add, size: 14, color: Color(0xFFFF7A00)),
                            SizedBox(width: 2),
                            Text('Viết mới', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_myReviewsList.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.rate_review_outlined, size: 48, color: Color(0xFFCBD5E1)),
                            SizedBox(height: 8),
                            Text('Bạn chưa có bài đánh giá nào.', style: TextStyle(color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _myReviewsList.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
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
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        item['placeImage'] as String,
                                        width: 46,
                                        height: 46,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['placeName'] as String,
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            item['date'] as String,
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${item['rating']}',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                Text(
                                  item['comment'] as String,
                                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155), height: 1.35),
                                ),
                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '👍 ${item['likes']} người thấy hữu ích',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                    Row(
                                      children: [
                                        TextButton(
                                          onPressed: () => context.push('/reviews/write'),
                                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                          child: const Text('Sửa', style: TextStyle(fontSize: 12, color: Color(0xFFFF7A00))),
                                        ),
                                        const SizedBox(width: 12),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              _myReviewsList.removeWhere((r) => r['id'] == item['id']);
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Đã xóa bài đánh giá.')),
                                            );
                                          },
                                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                                          child: const Text('Xóa', style: TextStyle(fontSize: 12, color: AppColors.error)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.9)),
        ),
      ],
    );
  }
}
