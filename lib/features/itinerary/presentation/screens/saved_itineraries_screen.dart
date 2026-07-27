import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';

class SavedItinerariesScreen extends StatefulWidget {
  const SavedItinerariesScreen({super.key});

  @override
  State<SavedItinerariesScreen> createState() => _SavedItinerariesScreenState();
}

class _SavedItinerariesScreenState extends State<SavedItinerariesScreen> {
  final List<Map<String, dynamic>> _savedTrips = [
    {
      'id': 'st1',
      'title': 'Hành Trình Khám Phá Cố Đô 3D2N',
      'subtitle': '12 Điểm dừng • Tối ưu cặp đôi • Di sản & Ẩm thực',
      'date': '25/07/2026',
      'status': 'Đang diễn ra (80%)',
      'statusColor': const Color(0xFF00B87C),
      'image': 'https://images.unsplash.com/photo-1596436889106-be35e843f974?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 'st2',
      'title': 'Tour Ẩm Thực Huế & Cafe Muối 1D',
      'subtitle': '6 Điểm dừng • Bún bò, Cơm hến & Trà đình',
      'date': '20/07/2026',
      'status': 'Đã hoàn thành ✅',
      'statusColor': const Color(0xFF64748B),
      'image': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&auto=format&fit=crop&q=80',
    },
    {
      'id': 'st3',
      'title': 'Hành Trình Lăng Tẩm & Chùa Cổ 2D1N',
      'subtitle': '8 Điểm dừng • Lăng Khải Định, Chùa Thiên Mụ',
      'date': '15/07/2026',
      'status': 'Đã lưu',
      'statusColor': const Color(0xFFFF7A00),
      'image': 'https://images.unsplash.com/photo-1548013146-72479768bada?w=400&auto=format&fit=crop&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Lịch trình đã lưu',
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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_savedTrips.length} CHUYẾN ĐI ĐÃ LƯU',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/itinerary/setup'),
                    child: const Row(
                      children: [
                        Icon(Icons.add, size: 16, color: Color(0xFFFF7A00)),
                        SizedBox(width: 2),
                        Text('Tạo mới AI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // TRIPS LIST
              if (_savedTrips.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Icon(Icons.map_outlined, size: 54, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 12),
                        Text('Chưa có lịch trình du lịch nào được lưu.', style: TextStyle(color: Color(0xFF64748B))),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: _savedTrips.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GestureDetector(
                        onTap: () => context.push('/itinerary/result'),
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
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  item['image'] as String,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item['date'] as String,
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: (item['statusColor'] as Color).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item['status'] as String,
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: item['statusColor'] as Color),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['title'] as String,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['subtitle'] as String,
                                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF94A3B8)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
