import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/utils/helpers/bottom_sheet_helper.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/features/review/presentation/providers/review_provider.dart';
import 'package:codoky/features/review/presentation/widgets/review_card.dart';
import 'package:codoky/features/review/presentation/widgets/write_review_bottom_sheet.dart';

class PlaceDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const PlaceDetailScreen({
    super.key,
    required this.id,
  });

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? _placeData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaceDetails();
    Future.microtask(() {
      ref.read(reviewProvider.notifier).loadAllReviews(placeId: widget.id, refresh: true);
    });
  }

  Future<void> _loadPlaceDetails() async {
    // 1. Try to find from mapProvider state
    final mapState = ref.read(mapProvider);
    final existing = mapState.allPlaces.firstWhere(
      (p) => p['id']?.toString() == widget.id || p['place_id']?.toString() == widget.id,
      orElse: () => null,
    );

    if (existing != null && existing is Map<String, dynamic>) {
      setState(() {
        _placeData = _formatPlaceData(existing);
        _isLoading = false;
      });
      return;
    }

    // 2. Try loading from assets seed file if not in state
    try {
      final jsonString = await rootBundle.loadString('assets/data/hue_places_seed.json');
      final List<dynamic> decoded = json.decode(jsonString);
      final found = decoded.firstWhere(
        (p) => p['id']?.toString() == widget.id,
        orElse: () => null,
      );

      if (found != null && found is Map<String, dynamic>) {
        setState(() {
          _placeData = _formatPlaceData(found);
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    // 3. Fallback rich mock place data for preview
    setState(() {
      _placeData = _getFallbackPlaceData(widget.id);
      _isLoading = false;
    });
  }

  Map<String, dynamic> _formatPlaceData(Map<String, dynamic> raw) {
    final name = raw['name']?.toString() ?? 'Địa điểm du lịch Huế';
    final category = raw['category']?.toString() ?? 'attraction';
    final lat = double.tryParse(raw['latitude']?.toString() ?? '16.4637') ?? 16.4637;
    final lng = double.tryParse(raw['longitude']?.toString() ?? '107.5909') ?? 107.5909;

    return {
      'id': widget.id,
      'name': name,
      'category': category,
      'rating': double.tryParse(raw['rating']?.toString() ?? '4.8') ?? 4.8,
      'review_count': int.tryParse(raw['review_count']?.toString() ?? '128') ?? 128,
      'latitude': lat,
      'longitude': lng,
      'address': raw['address']?.toString() ?? 'Thành phố Huế, Thừa Thiên Huế',
      'open_hours': raw['open_hours']?.toString() ?? raw['opening_hours']?.toString() ?? '07:30 - 17:30 (Thứ 2 - Chủ Nhật)',
      'ticket_price': raw['ticket_price']?.toString() ?? raw['price']?.toString() ?? 'Miễn phí / Hoặc vé tham quan di tích',
      'phone': raw['phone']?.toString() ?? '0234 3523 237',
      'image_url': raw['image_url']?.toString() ?? _getCategoryDefaultImage(category),
      'description': raw['description']?.toString() ??
          'Quần thể di sản và điểm đến nổi tiếng hàng đầu tại Cố đô Huế. Nơi đây lưu giữ nét đẹp văn hóa, kiến trúc lịch sử đặc sắc của triều đại nhà Nguyễn cùng không gian thơ mộng bên dòng sông Hương.',
      'tags': (raw['tags'] is List)
          ? List<String>.from(raw['tags'])
          : ['🏰 Di sản Huế', '📸 Check-in đẹp', '🏛️ Kiến trúc Cố đô', '🌿 Cảnh quan thơ mộng'],
    };
  }

  Map<String, dynamic> _getFallbackPlaceData(String id) {
    return {
      'id': id,
      'name': 'Đại Nội Huế (Hoàng Thành Huế)',
      'category': 'attraction',
      'rating': 4.9,
      'review_count': 342,
      'latitude': 16.4637,
      'longitude': 107.5909,
      'address': 'Đường 23/8, Phường Thuận Hòa, Thành phố Huế',
      'open_hours': '07:00 - 17:30 (Thứ 2 - Chủ Nhật)',
      'ticket_price': '200.000 VNĐ / Người lớn • 40.000 VNĐ / Trẻ em',
      'phone': '0234 3523 237',
      'image_url': 'https://images.unsplash.com/photo-1596436889106-be35e843f974?w=800&auto=format&fit=crop&q=80',
      'description':
          'Đại Nội Huế là quần thể di tích Hoàng thành và Tử Cấm thành thuộc Quần thể di tích Cố đô Huế, được UNESCO công nhận là Di sản Văn hóa Thế giới năm 1993.\n\nNơi đây từng là trung tâm chính trị, văn hóa của triều đại nhà Nguyễn trong suốt 143 năm (1802 - 1945). Công trình nổi bật với Ngọ Môn, Điện Thái Hòa, Thế Miếu và cung Điện Thọ Kính mang kiến trúc phong thủy phương Đông đặc sắc.',
      'tags': ['🏰 Di sản UNESCO', '👑 Hoàng thành', '📸 Check-in Huế', '🏛️ Triều Nguyễn'],
    };
  }

  String _getCategoryDefaultImage(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('food') || cat.contains('ẩm thực') || cat.contains('restaurant')) {
      return 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&auto=format&fit=crop&q=80';
    }
    if (cat.contains('temple') || cat.contains('chùa')) {
      return 'https://images.unsplash.com/photo-1548013146-72479768bada?w=800&auto=format&fit=crop&q=80';
    }
    if (cat.contains('cafe') || cat.contains('cà phê')) {
      return 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800&auto=format&fit=crop&q=80';
    }
    return 'https://images.unsplash.com/photo-1596436889106-be35e843f974?w=800&auto=format&fit=crop&q=80';
  }

  Future<void> _openNavigationMap(double lat, double lng, String name) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở bản đồ chỉ đường.')),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _placeData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7A00)),
          ),
        ),
      );
    }

    final reviewState = ref.watch(reviewProvider);
    final placeReviews = reviewState.allReviews;

    final place = _placeData!;
    final name = place['name'] as String;
    final category = place['category'] as String;
    final rating = place['rating'] as double;
    final reviewCount = place['review_count'] as int;
    final lat = place['latitude'] as double;
    final lng = place['longitude'] as double;
    final address = place['address'] as String;
    final openHours = place['open_hours'] as String;
    final ticketPrice = place['ticket_price'] as String;
    final phone = place['phone'] as String;
    final imageUrl = place['image_url'] as String;
    final description = place['description'] as String;
    final tags = place['tags'] as List<String>;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // MAIN SCROLL CONTENT
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HERO IMAGE BANNER & GRADIENT OVERLAY
                Stack(
                  children: [
                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B),
                      ),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF334155),
                            child: const Center(
                              child: Icon(Icons.image_not_supported_rounded, size: 48, color: Colors.white54),
                            ),
                          );
                        },
                      ),
                    ),

                    // Dark Gradient Shadow Shader
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Floating Category Badge
                    Positioned(
                      bottom: 16,
                      left: AppSpacing.lg,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7A00),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.place_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              _getCategoryLabel(category),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // 2. MAIN HEADER CONTENT CARD
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E1E1E),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Rating & Review Stats Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB800)),
                                const SizedBox(width: 4),
                                Text(
                                  '$rating',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '($reviewCount Đánh giá từ du khách)',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Address Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFFFF7A00)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              address,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF475569),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 3. QUICK ACTION BUTTONS BAR (4 ACTIONS)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.near_me_rounded,
                                label: 'Chỉ đường',
                                color: const Color(0xFFFF7A00),
                                onTap: () => _openNavigationMap(lat, lng, name),
                              ),
                            ),
                            Container(height: 28, width: 1, color: const Color(0xFFF1F5F9)),
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.phone_in_talk_rounded,
                                label: 'Liên hệ',
                                color: const Color(0xFF00B87C),
                                onTap: () => _makePhoneCall(phone),
                              ),
                            ),
                            Container(height: 28, width: 1, color: const Color(0xFFF1F5F9)),
                            Expanded(
                              child: Consumer(
                                builder: (context, ref, _) {
                                  final isSaved = ref.watch(mapProvider).savedPlaceIds.contains(widget.id);
                                  return _buildActionButton(
                                    icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                                    label: isSaved ? 'Đã lưu' : 'Lưu lại',
                                    color: isSaved ? const Color(0xFFFF5E62) : const Color(0xFF64748B),
                                    onTap: () {
                                      ref.read(mapProvider.notifier).toggleSavePlace(widget.id);
                                      final newSaved = !isSaved;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(newSaved ? 'Đã lưu địa điểm vào mục yêu thích!' : 'Đã xóa khỏi danh sách lưu.'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            Container(height: 28, width: 1, color: const Color(0xFFF1F5F9)),
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.add_to_photos_rounded,
                                label: '+ Lịch trình',
                                color: const Color(0xFF9333EA),
                                onTap: () {
                                  context.push('/itinerary/setup');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 4. THÔNG TIN CHI TIẾT CARD
                      Container(
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
                        child: Column(
                          children: [
                            // Giờ mở cửa
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF4EB),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.access_time_rounded, color: Color(0xFFFF7A00), size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Giờ mở cửa', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                                      Text(
                                        openHours,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F9F3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'ĐANG MỞ CỬA',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00B87C)),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20, thickness: 1, color: Color(0xFFF1F5F9)),

                            // Giá vé
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0F3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.confirmation_number_outlined, color: Color(0xFFFF5E62), size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Giá vé / Chi phí', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                                      Text(
                                        ticketPrice,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 5. GIỚI THIỆU & LỊCH SỬ
                      const Text(
                        'GIỚI THIỆU & LỊCH SỬ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
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
                        child: Text(
                          description,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF334155),
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Pastel Tag Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags.map((t) => _buildPastelTagChip(t)).toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 6. BẢN ĐỒ MINI CỤC BỘ (INTERACTIVE MINI MAP PREVIEW)
                      const Text(
                        'VỊ TRÍ TRÊN BẢN ĐỒ HUẾ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 180,
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Stack(
                          children: [
                            FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(lat, lng),
                                initialZoom: 15.0,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.codoky.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(lat, lng),
                                      width: 44,
                                      height: 44,
                                      rotate: true,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF7A00),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2.5),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFF7A00).withValues(alpha: 0.4),
                                              blurRadius: 10,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.place_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Overlay button to open Google Maps
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: ElevatedButton.icon(
                                onPressed: () => _openNavigationMap(lat, lng, name),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E1C22),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 4,
                                ),
                                icon: const Icon(Icons.navigation_rounded, size: 14, color: Color(0xFFFF7A00)),
                                label: const Text('Mở chỉ đường', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 7. ĐÁNH GIÁ TỪ DU KHÁCH (REVIEWS SECTION)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ĐÁNH GIÁ TỪ DU KHÁCH',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showAppBottomSheet(
                                context: context,
                                vsync: this,
                                builder: (ctx) => WriteReviewBottomSheet(
                                  initialPlaceId: widget.id,
                                  initialPlaceName: name,
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.rate_review_outlined, size: 14, color: Color(0xFFFF7A00)),
                                SizedBox(width: 4),
                                Text(
                                  'Viết đánh giá',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF7A00)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (reviewState.isLoadingAll && placeReviews.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFFF7A00)))),
                        )
                      else if (placeReviews.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.rate_review_outlined, size: 36, color: Color(0xFF94A3B8)),
                              const SizedBox(height: 8),
                              const Text(
                                'Chưa có đánh giá nào cho địa điểm này.',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Hãy là người đầu tiên chia sẻ cảm nhận!',
                                style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  showAppBottomSheet(
                                    context: context,
                                    vsync: this,
                                    builder: (ctx) => WriteReviewBottomSheet(
                                      initialPlaceId: widget.id,
                                      initialPlaceName: name,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                                label: const Text('Viết Đánh Giá Ngay', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF7A00),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: placeReviews.map((rev) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ReviewCard(
                                review: rev,
                                onDelete: () => ref.read(reviewProvider.notifier).deleteReview(rev.id),
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

          // FLOATING TOP BAR OVERLAY
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/map');
                      }
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),

                  // Action Buttons Right (Save & Share)
                  Row(
                    children: [
                      Consumer(
                        builder: (context, ref, _) {
                          final isSaved = ref.watch(mapProvider).savedPlaceIds.contains(widget.id);
                          return GestureDetector(
                            onTap: () {
                              ref.read(mapProvider.notifier).toggleSavePlace(widget.id);
                              final newSaved = !isSaved;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(newSaved ? 'Đã lưu địa điểm!' : 'Đã bỏ lưu địa điểm.'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Icon(
                                isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                                color: isSaved ? const Color(0xFFFF5E62) : Colors.white,
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: 'Khám phá $name cùng ứng dụng du lịch Huế CodoKy!'));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã sao chép liên kết địa điểm!')),
                          );
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.share_outlined, color: Colors.white, size: 19),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // FLOATING BOTTOM CTA BAR
          Positioned(
            bottom: 16,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5E62).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _openNavigationMap(lat, lng, name),
                  borderRadius: BorderRadius.circular(16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.near_me_rounded, size: 22, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Chỉ đường tới đây ngay',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastelTagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFEAD8)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFFF7A00),
        ),
      ),
    );
  }

  String _getCategoryLabel(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('attraction') || lower.contains('di tích') || lower.contains('lịch sử')) {
      return '🏰 Di tích & Di sản Lịch sử';
    }
    if (lower.contains('food') || lower.contains('ẩm thực') || lower.contains('restaurant')) {
      return '🍜 Ẩm thực Cố đô Huế';
    }
    if (lower.contains('temple') || lower.contains('chùa')) {
      return '⛩️ Tâm linh & Chùa Huế';
    }
    if (lower.contains('cafe') || lower.contains('cà phê')) {
      return '☕ Cafe & Đời sống Huế';
    }
    return '📍 Địa điểm du lịch Huế';
  }
}
