import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/shared/widgets/vehicle_wheel_picker.dart';

class MapBottomSheet extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final placeId = place is Map ? (place['id']?.toString() ?? '1') : (place.id?.toString() ?? '1');
    final name = place is Map ? (place['name'] as String? ?? '') : (place.name as String? ?? '');
    final address = place is Map ? (place['address'] as String? ?? 'Thừa Thiên Huế') : (place.address as String? ?? '');
    final category = place is Map ? (place['category'] as String? ?? 'attraction') : (place.category as String? ?? '');
    final rating = place is Map ? ((place['rating'] as num?)?.toDouble() ?? 4.8) : ((place.rating as double?) ?? 4.8);
    final config = _getCategoryConfig(category);

    final mapState = ref.watch(mapProvider);
    final isSaved = mapState.savedPlaceIds.contains(placeId);
    final activeRoute = mapState.activeRoute;
    final isFetchingRoute = mapState.isFetchingRoute;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, animValue, child) {
        return Transform.translate(
          offset: Offset(0, 24 * (1 - animValue)),
          child: Opacity(
            opacity: animValue.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Title + Close Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: onClose,
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
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // Rating & Status Row: ⭐ 4.5 (128) • Đang mở cửa
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
                const SizedBox(height: 14),

                // Travel Mode Selector Box
                _buildTravelModeSelector(context, ref, mapState.travelMode, activeRoute?.formattedDuration),
                const SizedBox(height: 6),
                _buildAlternativeRoutesSelector(ref, mapState),
                const SizedBox(height: 14),

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
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: isFetchingRoute ? null : onNavigate,
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
                                    ? 'Đường đi (${activeRoute.formattedDuration})'
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
          ),
        ],
      ),
    ),
  );
}


  Widget _buildTravelModeSelector(BuildContext context, WidgetRef ref, String currentMode, [String? durationText]) {
    final vehicleItems = const [
      VehicleOption(id: 'motorbike', label: 'Xe máy', icon: Icons.two_wheeler_rounded),
      VehicleOption(id: 'driving', label: 'Ô tô', icon: Icons.directions_car_rounded),
      VehicleOption(id: 'walking', label: 'Đi bộ', icon: Icons.directions_walk_rounded),
    ];

    final initialOption = vehicleItems.firstWhere(
      (opt) => opt.id == currentMode,
      orElse: () => vehicleItems[0],
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        VehicleWheelPicker(
          items: vehicleItems,
          initialSelection: initialOption,
          height: 68.0,
          viewportFraction: 0.32,
          accentColor: const Color(0xFF2563EB),
          onChanged: (selectedVehicle) {
            if (selectedVehicle.id != currentMode) {
              ref.read(mapProvider.notifier).setTravelMode(selectedVehicle.id);
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
                  selectedColor: const Color(0xFF9B1B30),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF9B1B30) : const Color(0xFFCBD5E1),
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

/// Favorite/Bookmark button với pop animation dùng AnimatedSwitcher.
/// Không dùng AnimationController/Ticker để tránh lifecycle conflict trnên Windows.
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
          width: 50,
          height: 50,
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