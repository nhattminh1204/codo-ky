import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/shared/widgets/travel_mode_picker.dart';
import 'package:codoky/features/review/data/models/review_model.dart';
import 'package:codoky/features/review/presentation/providers/review_provider.dart';
import 'package:codoky/features/review/presentation/widgets/review_card.dart';
import 'package:codoky/features/review/presentation/widgets/write_review_bottom_sheet.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/core/utils/helpers/bottom_sheet_helper.dart';

class MapBottomSheet extends ConsumerStatefulWidget {
  final dynamic place;
  final VoidCallback onClose;
  final VoidCallback onNavigate;
  final VoidCallback? onDetail;

  const MapBottomSheet({
    super.key,
    required this.place,
    required this.onClose,
    required this.onNavigate,
    this.onDetail,
  });

  @override
  ConsumerState<MapBottomSheet> createState() => _MapBottomSheetState();
}

class _MapBottomSheetState extends ConsumerState<MapBottomSheet> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      try {
        final placeId = _getPlaceId(widget.place);
        ref.read(reviewProvider.notifier).loadAllReviews(placeId: placeId, refresh: true);
      } catch (_) {}
    });
  }

  @override
  void didUpdateWidget(covariant MapBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_getPlaceId(oldWidget.place) != _getPlaceId(widget.place)) {
      setState(() {
        _isExpanded = false;
      });
      try {
        final placeId = _getPlaceId(widget.place);
        ref.read(reviewProvider.notifier).loadAllReviews(placeId: placeId, refresh: true);
      } catch (_) {}
    }
  }

  String _getPlaceId(dynamic p) {
    if (p is Map) return p['id']?.toString() ?? '1';
    return p.id?.toString() ?? '1';
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded && widget.onDetail != null) {
      widget.onDetail!();
    }
  }

  void _expand() {
    if (!_isExpanded) {
      setState(() {
        _isExpanded = true;
      });
      if (widget.onDetail != null) {
        widget.onDetail!();
      }
    }
  }

  void _collapse() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
      });
    }
  }

  Map<String, dynamic> _parsePlace(dynamic place) {
    if (place is Map<String, dynamic>) return place;
    if (place is Map) return Map<String, dynamic>.from(place);
    return {
      'id': place.id?.toString() ?? '1',
      'name': place.name?.toString() ?? '',
      'address': place.address?.toString() ?? 'Thừa Thiên Huế',
      'category': place.category?.toString() ?? 'attraction',
      'rating': (place.rating as num?)?.toDouble() ?? 4.8,
      'review_count': (place.reviewCount as num?)?.toInt() ?? 128,
      'latitude': (place.latitude as num?)?.toDouble() ?? 16.4637,
      'longitude': (place.longitude as num?)?.toDouble() ?? 107.5909,
      'description': place.description?.toString(),
      'open_hours': place.openHours?.toString() ?? place.openingHours?.toString(),
      'ticket_price': place.ticketPrice?.toString() ?? place.price?.toString(),
      'phone': place.phone?.toString(),
      'image_url': place.imageUrl?.toString(),
    };
  }

  String _getImageUrl(Map<String, dynamic> p) {
    final url = p['image_url']?.toString();
    if (url != null) return url;
    return '';
  }

  String _getDescription(Map<String, dynamic> p) {
    final desc = p['description']?.toString();
    if (desc != null && desc.isNotEmpty) return desc;
    return 'Quần thể di sản và điểm đến nổi tiếng hàng đầu tại Cố đô Huế. Nơi đây lưu giữ nét đẹp văn hóa, kiến trúc lịch sử đặc sắc của triều đại nhà Nguyễn cùng không gian thơ mộng bên dòng sông Hương.';
  }

  Future<void> _makePhoneCall(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openExternalMap(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsedPlace = _parsePlace(widget.place);
    final placeId = parsedPlace['id']?.toString() ?? '1';
    final name = parsedPlace['name']?.toString() ?? '';
    final address = parsedPlace['address']?.toString() ?? 'Thừa Thiên Huế';
    final category = parsedPlace['category']?.toString() ?? 'attraction';
    final rating = (parsedPlace['rating'] as num?)?.toDouble() ?? 4.8;
    final reviewCount = (parsedPlace['review_count'] as num?)?.toInt() ?? 128;
    final lat = (parsedPlace['latitude'] as num?)?.toDouble() ?? 16.4637;
    final lng = (parsedPlace['longitude'] as num?)?.toDouble() ?? 107.5909;
    final openHours = parsedPlace['open_hours']?.toString() ?? '07:30 - 17:30 (Hằng ngày)';
    final ticketPrice = parsedPlace['ticket_price']?.toString() ?? 'Miễn phí / Vé tham quan di tích';
    final phone = parsedPlace['phone']?.toString() ?? '0234 3523 237';
    final imageUrl = _getImageUrl(parsedPlace);
    final description = _getDescription(parsedPlace);

    final config = _getCategoryConfig(category);
    final mapState = ref.watch(mapProvider);
    final isSaved = mapState.savedPlaceIds.contains(placeId);
    final activeRoute = mapState.activeRoute;
    final isFetchingRoute = mapState.isFetchingRoute;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final expandedMaxHeight = (screenHeight * 0.78).clamp(460.0, 720.0);

    final reviewState = ref.watch(reviewProvider);
    final placeReviews = reviewState.allReviews;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < -150) {
          _expand();
        } else if (details.primaryVelocity! > 150) {
          if (_isExpanded) {
            _collapse();
          } else {
            widget.onClose();
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        constraints: _isExpanded
            ? BoxConstraints(maxHeight: expandedMaxHeight, minHeight: expandedMaxHeight)
            : const BoxConstraints(maxHeight: 380),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.40) : Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: _isExpanded ? MainAxisSize.max : MainAxisSize.min,
          children: [
            // Handle Top Header Bar with drag gesture & expand indicator
            GestureDetector(
              onTap: _toggleExpand,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white30 : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isExpanded ? 'Vuốt xuống để thu gọn' : 'Vuốt lên để xem chi tiết',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Content Area (Compact vs Expanded)
            if (_isExpanded)
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: _buildExpandedContent(
                    context,
                    ref,
                    parsedPlace,
                    placeId,
                    name,
                    address,
                    category,
                    rating,
                    reviewCount,
                    openHours,
                    ticketPrice,
                    phone,
                    imageUrl,
                    description,
                    lat,
                    lng,
                    config,
                    isSaved,
                    isDark,
                    placeReviews,
                  ),
                ),
              )
            else
              _buildCompactContent(
                context,
                ref,
                name,
                address,
                rating,
                config,
                isSaved,
                isDark,
                mapState,
                activeRoute,
                isFetchingRoute,
                placeId,
              ),

            // Bottom Fixed Action Bar when Expanded
            if (_isExpanded)
              _buildExpandedBottomActionBar(context, ref, mapState, isFetchingRoute, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactContent(
    BuildContext context,
    WidgetRef ref,
    String name,
    String address,
    double rating,
    _CategoryConfig config,
    bool isSaved,
    bool isDark,
    MapState mapState,
    dynamic activeRoute,
    bool isFetchingRoute,
    String placeId,
  ) {
    return Padding(
      key: const ValueKey('compact_content'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: (mapState.isNavigating || activeRoute != null)
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.navigation_rounded, color: Color(0xFF2563EB), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Đang di chuyển đến điểm này • $address',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header: Title + Close Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Subtitle: Category • Address
                Text(
                  '${config.label} • $address',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // Rating & Status Row
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '(128)',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                    ),
                    const Text(
                      'Đang mở cửa',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Travel Mode Selector Box
                _buildTravelModeSelector(context, ref, mapState.travelMode, activeRoute?.formattedDuration),
                const SizedBox(height: 6),
                _buildAlternativeRoutesSelector(ref, mapState),
                const SizedBox(height: 12),

                // Action Row: Bookmark Square Button + CTA Button
                Row(
                  children: [
                    _FavoriteBookmarkButton(
                      isSaved: isSaved,
                      onTap: () => ref.read(mapProvider.notifier).toggleSavePlace(placeId),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: isFetchingRoute ? null : widget.onNavigate,
                          icon: isFetchingRoute
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(
                                  Icons.directions_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                          label: Text(
                            isFetchingRoute
                                ? 'Đang tính...'
                                : (activeRoute != null
                                    ? 'Bắt đầu di chuyển'
                                    : 'Đường đi'),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            disabledBackgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildExpandedContent(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> parsedPlace,
    String placeId,
    String name,
    String address,
    String category,
    double rating,
    int reviewCount,
    String openHours,
    String ticketPrice,
    String phone,
    String imageUrl,
    String description,
    double lat,
    double lng,
    _CategoryConfig config,
    bool isSaved,
    bool isDark,
    List<dynamic> placeReviews,
  ) {
    return SingleChildScrollView(
      key: const ValueKey('expanded_content'),
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Image Banner
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: imageUrl.isEmpty
                      ? Container(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          child: const Center(
                            child: Icon(Icons.place_rounded, size: 44, color: AppColors.primary),
                          ),
                        )
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                            child: const Center(
                              child: Icon(Icons.place_rounded, size: 44, color: AppColors.primary),
                            ),
                          ),
                        ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.50),
                      ],
                    ),
                  ),
                ),
              ),
              // Category Chip Badge
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(config.icon, color: Colors.white, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        config.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Rating Badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 15),
                      const SizedBox(width: 3),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Title & Quick Metadata Header
          Text(
            name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
          ),
          const SizedBox(height: 6),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
              const SizedBox(width: 4),
              Text(
                '$rating ($reviewCount đánh giá)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
              ),
              const Text(
                'Đang mở cửa',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Quick Action Shortcuts Bar (Call, Google Maps, Share, Favorite)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickActionButton(
                  icon: Icons.phone_rounded,
                  label: 'Gọi điện',
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                  onTap: () => _makePhoneCall(phone),
                ),
                const SizedBox(width: 14),
                _buildQuickActionButton(
                  icon: Icons.map_rounded,
                  label: 'Bản đồ ngoài',
                  color: const Color(0xFF2563EB),
                  isDark: isDark,
                  onTap: () => _openExternalMap(lat, lng),
                ),
                const SizedBox(width: 14),
                _buildQuickActionButton(
                  icon: Icons.share_rounded,
                  label: 'Chia sẻ',
                  color: const Color(0xFF8B5CF6),
                  isDark: isDark,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã sao chép liên kết địa điểm "$name"')),
                    );
                  },
                ),
                const SizedBox(width: 14),
                _buildQuickActionButton(
                  icon: isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  label: isSaved ? 'Đã lưu' : 'Lưu',
                  color: const Color(0xFFF59E0B),
                  isDark: isDark,
                  onTap: () => ref.read(mapProvider.notifier).toggleSavePlace(placeId),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Detailed Info Cards
          _buildInfoRow(Icons.location_on_outlined, 'Địa chỉ', address, isDark),
          _buildInfoRow(Icons.access_time_rounded, 'Giờ mở cửa', openHours, isDark),
          _buildInfoRow(Icons.confirmation_number_outlined, 'Giá vé / Phí tham quan', ticketPrice, isDark),
          _buildInfoRow(Icons.call_outlined, 'Liên hệ hotline', phone, isDark),

          const SizedBox(height: 16),

          // Heritage Description / Overview
          Text(
            'Giới thiệu & Lịch sử',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),

          const SizedBox(height: 12),

          // Tags Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _TagChip(label: '🏰 Di sản Cố Đô'),
              _TagChip(label: '📸 Check-in đẹp'),
              _TagChip(label: '🏛️ Kiến trúc Triều Nguyễn'),
              _TagChip(label: '🌿 Không gian thơ mộng'),
            ],
          ),

          const SizedBox(height: 20),

          // Reviews Section Header & Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Đánh giá & Trải nghiệm',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  showAppBottomSheet(
                    context: context,
                    builder: (ctx) => WriteReviewBottomSheet(
                      initialPlaceId: placeId,
                      initialPlaceName: name,
                    ),
                  );
                },
                icon: const Icon(Icons.rate_review_outlined, size: 16, color: AppColors.primary),
                label: const Text(
                  'Viết đánh giá',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Reviews List
          if (placeReviews.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Chưa có bài đánh giá nào. Hãy là người đầu tiên chia sẻ cảm nhận!',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Column(
              children: placeReviews.take(3).map((r) {
                final ReviewModel model = r is ReviewModel
                    ? r
                    : ReviewModel.fromJson(r is Map<String, dynamic> ? r : Map<String, dynamic>.from(r as Map));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ReviewCard(review: model),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedBottomActionBar(
    BuildContext context,
    WidgetRef ref,
    MapState mapState,
    bool isFetchingRoute,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.06),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Travel Mode Picker
          _buildTravelModeSelector(context, ref, mapState.travelMode, mapState.activeRoute?.formattedDuration),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: isFetchingRoute ? null : widget.onNavigate,
                    icon: isFetchingRoute
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(
                            Icons.directions_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                    label: Text(
                      isFetchingRoute
                          ? 'Đang tính toán...'
                          : (mapState.activeRoute != null
                              ? 'Bắt đầu di chuyển ngay'
                              : 'Chỉ đường OSRM'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _collapse,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.18 : 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelModeSelector(BuildContext context, WidgetRef ref, String currentMode, [String? durationText]) {
    TravelMode initialMode = TravelMode.motorbike;
    if (currentMode == 'driving') {
      initialMode = TravelMode.driving;
    } else if (currentMode == 'walking') {
      initialMode = TravelMode.walking;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        TravelModePicker(
          initialMode: initialMode,
          height: 48.0,
          onChanged: (selectedMode) {
            String modeStr = 'motorbike';
            if (selectedMode == TravelMode.driving) {
              modeStr = 'driving';
            } else if (selectedMode == TravelMode.walking) {
              modeStr = 'walking';
            }
            if (modeStr != currentMode) {
              ref.read(mapProvider.notifier).setTravelMode(modeStr);
            }
          },
        ),
        if (durationText != null && durationText.isNotEmpty)
          Positioned(
            top: -6,
            right: 14,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  durationText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAlternativeRoutesSelector(WidgetRef ref, MapState state) {
    if (state.alternativeRoutes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn tuyến đường:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: state.alternativeRoutes.asMap().entries.map((entry) {
              final idx = entry.key;
              final route = entry.value;
              final isSelected = idx == state.selectedRouteIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    'Tuyến ${idx + 1}: ${route.formattedDistance} (${route.formattedDuration})',
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : const Color(0xFFCBD5E1),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  onSelected: (_) {
                    ref.read(mapProvider.notifier).selectRouteIndex(idx);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  _CategoryConfig _getCategoryConfig(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return _CategoryConfig(label: 'Quán ăn Huế', color: const Color(0xFF8B1522), icon: Icons.restaurant);
      case 'attraction':
        return _CategoryConfig(label: 'Địa điểm di sản', color: const Color(0xFF8B1522), icon: Icons.place);
      case 'temple':
        return _CategoryConfig(label: 'Chùa chiền', color: const Color(0xFF8B1522), icon: Icons.church);
      case 'tomb':
        return _CategoryConfig(label: 'Lăng tẩm', color: const Color(0xFF8B1522), icon: Icons.account_balance);
      default:
        return _CategoryConfig(label: 'Tham quan', color: const Color(0xFF8B1522), icon: Icons.tour);
    }
  }
}

class _CategoryConfig {
  final String label;
  final Color color;
  final IconData icon;

  _CategoryConfig({required this.label, required this.color, required this.icon});
}

class _FavoriteBookmarkButton extends StatelessWidget {
  final bool isSaved;
  final VoidCallback onTap;
  final bool isDark;

  const _FavoriteBookmarkButton({
    required this.isSaved,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) {
          final scale = Tween<double>(begin: 0.65, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          );
          return ScaleTransition(scale: scale, child: child);
        },
        child: Container(
          key: ValueKey(isSaved),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSaved
                ? (isDark ? const Color(0x40F59E0B) : const Color(0xFFFEF3C7))
                : (isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSaved
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.transparent),
              width: 1.0,
            ),
          ),
          child: Icon(
            isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            size: 22,
            color: isSaved
                ? const Color(0xFFD97706)
                : (isDark ? Colors.white70 : const Color(0xFF334155)),
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
        ),
      ),
    );
  }
}