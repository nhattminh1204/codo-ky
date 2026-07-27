import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';

class CategoryListScreen extends ConsumerStatefulWidget {
  final String categoryId;

  const CategoryListScreen({
    super.key,
    required this.categoryId,
  });

  @override
  ConsumerState<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends ConsumerState<CategoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _categoryPlaces = [];
  bool _isLoading = true;
  String _activeSort = 'rating'; // 'rating' | 'name'

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategoryData() async {
    // 1. Try from mapProvider state
    final mapState = ref.read(mapProvider);
    final allFromState = mapState.allPlaces;

    List<Map<String, dynamic>> filtered = [];

    if (allFromState.isNotEmpty) {
      filtered = allFromState
          .whereType<Map<String, dynamic>>()
          .where((p) => _matchesCategory(p['category']?.toString(), widget.categoryId))
          .toList();
    }

    // 2. If empty, load seed data asset
    if (filtered.isEmpty) {
      try {
        final jsonString = await rootBundle.loadString('assets/data/hue_places_seed.json');
        final List<dynamic> decoded = json.decode(jsonString);
        filtered = decoded
            .whereType<Map<String, dynamic>>()
            .where((p) => _matchesCategory(p['category']?.toString(), widget.categoryId))
            .toList();
      } catch (_) {}
    }

    // 3. Fallback mock list if empty
    if (filtered.isEmpty) {
      filtered = _getMockCategoryPlaces(widget.categoryId);
    }

    setState(() {
      _categoryPlaces = filtered;
      _isLoading = false;
    });
  }

  bool _matchesCategory(String? placeCategory, String targetCategory) {
    if (placeCategory == null) return false;
    final cat = placeCategory.toLowerCase();
    final target = targetCategory.toLowerCase();

    if (target == 'attraction') {
      return cat.contains('attraction') || cat.contains('tomb') || cat.contains('di tích') || cat.contains('lịch sử');
    }
    if (target == 'food') {
      return cat.contains('food') || cat.contains('restaurant') || cat.contains('ẩm thực') || cat.contains('ăn');
    }
    if (target == 'temple') {
      return cat.contains('temple') || cat.contains('chùa') || cat.contains('tâm linh');
    }
    if (target == 'cafe') {
      return cat.contains('cafe') || cat.contains('cà phê');
    }
    if (target == 'shopping') {
      return cat.contains('shop') || cat.contains('mua sắm') || cat.contains('chợ');
    }
    if (target == 'culture') {
      return cat.contains('culture') || cat.contains('nghệ thuật') || cat.contains('nhạc');
    }
    return cat == target;
  }

  List<Map<String, dynamic>> _getMockCategoryPlaces(String categoryId) {
    if (categoryId == 'food') {
      return [
        {
          'id': 'f1',
          'name': 'Bún Bò Huế Mụ Rớt',
          'category': 'food',
          'rating': 4.9,
          'address': '22 Kim Long, Hương Long, TP. Huế',
          'image_url': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&auto=format&fit=crop&q=80',
          'ticket_price': '35.000đ - 55.000đ / Tô',
          'tag': '🍜 Chuẩn vị Huế',
        },
        {
          'id': 'f2',
          'name': 'Quán Cơm Hến Hoa Đông',
          'category': 'food',
          'rating': 4.8,
          'address': 'Vĩ Dạ, Thành phố Huế',
          'image_url': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&auto=format&fit=crop&q=80',
          'ticket_price': '20.000đ - 35.000đ / Tô',
          'tag': '🐚 Cơm Hến Vĩ Dạ',
        },
        {
          'id': 'f3',
          'name': 'Bánh Bèo Nậm Lọc O Thủy',
          'category': 'food',
          'rating': 4.7,
          'address': '27 Nguyễn Trãi, Thuận Hòa, Huế',
          'image_url': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&auto=format&fit=crop&q=80',
          'ticket_price': '30.000đ - 60.000đ / Đĩa',
          'tag': '🥟 Bánh Huế Truyền Thống',
        },
      ];
    }

    if (categoryId == 'temple') {
      return [
        {
          'id': 't1',
          'name': 'Chùa Thiên Mụ (Linh Mụ)',
          'category': 'temple',
          'rating': 4.9,
          'address': 'Đường Nguyễn Phúc Nguyên, Hương Long, Huế',
          'image_url': 'https://images.unsplash.com/photo-1548013146-72479768bada?w=800&auto=format&fit=crop&q=80',
          'ticket_price': 'Miễn phí tham quan',
          'tag': '⛩️ Tháp Phước Duyên',
        },
        {
          'id': 't2',
          'name': 'Chùa Từ Hiếu',
          'category': 'temple',
          'rating': 4.8,
          'address': 'Dương Xuân Thượng, Thủy Xuân, Huế',
          'image_url': 'https://images.unsplash.com/photo-1596436889106-be35e843f974?w=800&auto=format&fit=crop&q=80',
          'ticket_price': 'Miễn phí tham quan',
          'tag': '🌿 Chùa Cổ Thanh Tịnh',
        },
      ];
    }

    return [
      {
        'id': '1',
        'name': 'Đại Nội Huế (Hoàng Thành)',
        'category': 'attraction',
        'rating': 4.9,
        'address': 'Thuận Thành, TP. Huế',
        'image_url': 'https://images.unsplash.com/photo-1596436889106-be35e843f974?w=800&auto=format&fit=crop&q=80',
        'ticket_price': '200.000đ / Vé',
        'tag': '🏰 Di sản UNESCO',
      },
      {
        'id': 'a2',
        'name': 'Lăng Khải Định (Ứng Lăng)',
        'category': 'attraction',
        'rating': 4.8,
        'address': 'Thủy Bằng, Hương Thủy, Huế',
        'image_url': 'https://images.unsplash.com/photo-1548013146-72479768bada?w=800&auto=format&fit=crop&q=80',
        'ticket_price': '150.000đ / Vé',
        'tag': '🏛️ Kiến trúc Độc đáo',
      },
    ];
  }

  Map<String, dynamic> _getCategoryHeaderInfo(String catId) {
    switch (catId.toLowerCase()) {
      case 'food':
        return {
          'title': 'Ẩm thực Cố đô Huế 🍜',
          'subtitle': 'Đặc sản Bún bò, Cơm hến & Bánh Huế truyền thống',
          'colors': [const Color(0xFFFF7A00), const Color(0xFFFFB800)],
        };
      case 'temple':
        return {
          'title': 'Tâm linh & Chùa Huế ⛩️',
          'subtitle': 'Khám phá các ngôi chùa cổ thanh tịnh linh thiêng',
          'colors': [const Color(0xFF9333EA), const Color(0xFFC084FC)],
        };
      case 'cafe':
        return {
          'title': 'Đời sống & Cafe Huế ☕',
          'subtitle': 'Thưởng thức Cafe muối & Trà đình thơ mộng',
          'colors': [const Color(0xFF0284C7), const Color(0xFF38BDF8)],
        };
      case 'shopping':
        return {
          'title': 'Phố đêm & Mua sắm 🛍️',
          'subtitle': 'Chợ Đông Ba & Phố đi bộ sôi động',
          'colors': [const Color(0xFF16A34A), const Color(0xFF4ADE80)],
        };
      case 'culture':
        return {
          'title': 'Nghệ thuật & Trải nghiệm 🎶',
          'subtitle': 'Ca Huế sông Hương & Làng nghề truyền thống',
          'colors': [const Color(0xFFE11D48), const Color(0xFFFB7185)],
        };
      default:
        return {
          'title': 'Di sản & Lịch sử Huế 🏰',
          'subtitle': 'Hoàng Thành, Lăng tẩm triều Nguyễn & Di tích',
          'colors': [const Color(0xFFFF5E62), const Color(0xFFFF9966)],
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final header = _getCategoryHeaderInfo(widget.categoryId);
    final List<Color> bgColors = header['colors'];

    // Filter search query
    final query = _searchController.text.trim().toLowerCase();
    final displayPlaces = _categoryPlaces.where((p) {
      if (query.isEmpty) return true;
      final name = p['name']?.toString().toLowerCase() ?? '';
      final address = p['address']?.toString().toLowerCase() ?? '';
      return name.contains(query) || address.contains(query);
    }).toList();

    if (_activeSort == 'rating') {
      displayPlaces.sort((a, b) {
        final rA = double.tryParse(a['rating']?.toString() ?? '0') ?? 0;
        final rB = double.tryParse(b['rating']?.toString() ?? '0') ?? 0;
        return rB.compareTo(rA);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // 1. CATEGORY HEADER BANNER
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: bgColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/explore');
                              }
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  header['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  header['subtitle'] as String,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Search Bar Inside Category
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: 'Tìm kiếm trong danh mục này...',
                            hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                            prefixIcon: Icon(Icons.search_rounded, size: 20, color: Color(0xFFFF7A00)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 2. SORT & STATS BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${displayPlaces.length} địa điểm được tìm thấy',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _activeSort = 'rating'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _activeSort == 'rating' ? const Color(0xFFFFEAD8) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _activeSort == 'rating' ? const Color(0xFFFF7A00) : const Color(0xFFCBD5E1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star_rounded, size: 14, color: _activeSort == 'rating' ? const Color(0xFFFF7A00) : const Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              'Đánh giá cao ★',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _activeSort == 'rating' ? const Color(0xFFFF7A00) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. PLACES LIST VIEW
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFFF7A00))))
                : displayPlaces.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                            SizedBox(height: 8),
                            Text('Không tìm thấy địa điểm phù hợp.', style: TextStyle(color: Color(0xFF64748B))),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 120),
                        itemCount: displayPlaces.length,
                        itemBuilder: (context, index) {
                          final place = displayPlaces[index];
                          final id = place['id']?.toString() ?? '$index';
                          final name = place['name']?.toString() ?? 'Địa điểm Huế';
                          final address = place['address']?.toString() ?? 'Thừa Thiên Huế';
                          final rating = double.tryParse(place['rating']?.toString() ?? '4.8') ?? 4.8;
                          final imageUrl = place['image_url']?.toString() ??
                              'https://images.unsplash.com/photo-1596436889106-be35e843f974?w=800&auto=format&fit=crop&q=80';
                          final ticketPrice = place['ticket_price']?.toString() ?? 'Tham quan di tích';
                          final tag = place['tag']?.toString() ?? '📍 Điểm đến Huế';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: GestureDetector(
                              onTap: () => context.push('/place/$id'),
                              child: Container(
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
                                    // Thumbnail Image
                                    ClipRRect(
                                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                                      child: Image.network(
                                        imageUrl,
                                        width: 110,
                                        height: 110,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 110,
                                          height: 110,
                                          color: const Color(0xFFCBD5E1),
                                          child: const Icon(Icons.place_rounded, color: Colors.white),
                                        ),
                                      ),
                                    ),

                                    // Content Body
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    name,
                                                    style: const TextStyle(
                                                      fontSize: 14.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF1E1E1E),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
                                                    const SizedBox(width: 2),
                                                    Text(
                                                      '$rating',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFFD97706),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              address,
                                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFFF4EB),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    tag,
                                                    style: const TextStyle(
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFFFF7A00),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  ticketPrice,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF475569),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
