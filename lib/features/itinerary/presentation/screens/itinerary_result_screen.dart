import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';

class ItineraryResultScreen extends StatefulWidget {
  const ItineraryResultScreen({super.key});

  @override
  State<ItineraryResultScreen> createState() => _ItineraryResultScreenState();
}

class _ItineraryResultScreenState extends State<ItineraryResultScreen> {
  int _activeDay = 0;
  bool _isSaved = false;

  final List<Map<String, dynamic>> _daysData = const [
    {
      'day': 'Ngày 1',
      'title': 'Khám Phá Di Sản & Ca Huế Sông Hương',
      'stops': [
        {
          'id': '1',
          'time': '08:00 - 11:30',
          'title': 'Đại Nội Huế (Hoàng Thành)',
          'category': '🏰 Di sản',
          'address': 'Thuận Thành, Thành phố Huế',
          'image': 'https://images.unsplash.com/photo-1596436889106-be35e843f974?w=400&auto=format&fit=crop&q=80',
          'tip': 'Gợi ý: Đi buổi sáng tránh nắng, chuẩn bị mũ nón và vé gộp di tích.',
        },
        {
          'id': 'f1',
          'time': '12:00 - 13:30',
          'title': 'Bún Bò Huế Mụ Rớt',
          'category': '🍜 Ẩm thực',
          'address': '22 Kim Long, Huế',
          'image': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&auto=format&fit=crop&q=80',
          'tip': 'Thưởng thức bún bò nạm chả chuẩn vị mắm ruốc truyền thống.',
        },
        {
          'id': 'c1',
          'time': '14:30 - 16:30',
          'title': 'Cafe Muối Gốc Cố Đô',
          'category': '☕ Cafe',
          'address': '10 Nguyễn Lương Bằng, Huế',
          'image': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400&auto=format&fit=crop&q=80',
          'tip': 'Trải nghiệm ly cafe muối đằm thắm mặn ngọt nổi tiếng.',
        },
        {
          'id': 't1',
          'time': '18:30 - 21:00',
          'title': 'Ca Huế Trên Dòng Sông Hương',
          'category': '🎶 Văn hóa',
          'address': 'Bến thuyền Tòa Khâm, Huế',
          'image': 'https://images.unsplash.com/photo-1548013146-72479768bada?w=400&auto=format&fit=crop&q=80',
          'tip': 'Đi thuyền rồng ngắm cầu Tràng Tiền lên đèn và thả hoa đăng.',
        },
      ],
    },
    {
      'day': 'Ngày 2',
      'title': 'Lăng Tẩm Triều Nguyễn & Làng Nghề',
      'stops': [
        {
          'id': 'a2',
          'time': '08:30 - 11:00',
          'title': 'Lăng Khải Định (Ứng Lăng)',
          'category': '🏛️ Di sản',
          'address': 'Thủy Bằng, Hương Thủy, Huế',
          'image': 'https://images.unsplash.com/photo-1548013146-72479768bada?w=400&auto=format&fit=crop&q=80',
          'tip': 'Kiến trúc giao thoa Đông - Tây tuyệt đẹp.',
        },
        {
          'id': 'a3',
          'time': '11:30 - 13:00',
          'title': 'Cơm Hến Hoa Đông',
          'category': '🍜 Ẩm thực',
          'address': 'Vĩ Dạ, Huế',
          'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&auto=format&fit=crop&q=80',
          'tip': 'Đặc sản Cơm Hến Vĩ Dạ cay nồng khó quên.',
        },
      ],
    },
    {
      'day': 'Ngày 3',
      'title': 'Chùa Cổ Thanh Tịnh & Chợ Đông Ba',
      'stops': [
        {
          'id': 't1',
          'time': '08:00 - 10:30',
          'title': 'Chùa Thiên Mụ',
          'category': '⛩️ Tâm linh',
          'address': 'Hương Long, Huế',
          'image': 'https://images.unsplash.com/photo-1548013146-72479768bada?w=400&auto=format&fit=crop&q=80',
          'tip': 'Thắp hương cầu an và ngắm sông Hương buổi sáng.',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentDay = _daysData[_activeDay];
    final stops = currentDay['stops'] as List<Map<String, dynamic>>;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Gợi ý Lịch trình AI',
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
        actions: [
          IconButton(
            icon: Icon(_isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded, color: _isSaved ? const Color(0xFFFF5E62) : const Color(0xFF1E1E1E)),
            onPressed: () {
              setState(() => _isSaved = !_isSaved);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isSaved ? 'Đã lưu lịch trình vào danh sách của bạn!' : 'Đã bỏ lưu lịch trình.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TRIP SUMMARY OVERVIEW CARD
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF5E62).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '🌸 Lịch trình AI đề xuất',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB800)),
                            SizedBox(width: 4),
                            Text('4.9 AI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      'Hành Trình Khám Phá Cố Đô 3D2N',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tối ưu cho Cặp đôi • Di sản & Ẩm thực • Ngân sách ~1.2tr',
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _buildTripBadge('12 Điểm dừng'),
                        const SizedBox(width: 8),
                        _buildTripBadge('Tối ưu vị trí GPS'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 2. DAY TABS BAR
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: List.generate(_daysData.length, (index) {
                  final day = _daysData[index];
                  final isSelected = index == _activeDay;

                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _activeDay = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFF7A00) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFFE2E8F0),
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: const Color(0xFFFF7A00).withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Text(
                          day['day'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // DAY TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                currentDay['title'] as String,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
              ),
            ),
            const SizedBox(height: 10),

            // 3. TIMELINE STOPS LIST
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: List.generate(stops.length, (index) {
                  final stop = stops[index];
                  final isLast = index == stops.length - 1;

                  return _buildTimelineStopCard(context, stop: stop, index: index + 1, isLast: isLast);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildTimelineStopCard(
    BuildContext context, {
    required Map<String, dynamic> stop,
    required int index,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Indicator Bar
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF7A00),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFFFEAD8),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // Stop Details Card Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () => context.push('/itinerary/stop/${stop['id']}'),
                child: Container(
                  padding: const EdgeInsets.all(12),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            stop['time'] as String,
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF4EB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              stop['category'] as String,
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              stop['image'] as String,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stop['title'] as String,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                                ),
                                Text(
                                  stop['address'] as String,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          stop['tip'] as String,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
