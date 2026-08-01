import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/utils/helpers/app_snackbar.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/features/map/presentation/screens/place_detail_screen.dart';
import 'package:codoky/shared/widgets/app_open_container.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
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
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: config.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(config.icon, size: 14, color: config.color),
                          const SizedBox(width: 4),
                          Text(
                            config.label,
                            style: TextStyle(
                              color: config.color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (rating > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB800).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB800)),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Color(0xFFD97706),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Nút Lưu Vị Trí / Yêu Thích
                    GestureDetector(
                      onTap: () {
                        ref.read(mapProvider.notifier).toggleSavePlace(placeId);
                        final newSavedState = !isSaved;
                        AppSnackBar.show(
                          context,
                          newSavedState ? 'Đã lưu "$name" vào danh sách yêu thích!' : 'Đã xóa "$name" khỏi danh sách lưu.',
                          isSuccess: newSavedState,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isSaved ? const Color(0xFFFFF1F2) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                          size: 18,
                          color: isSaved ? const Color(0xFFE11D48) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 6),
                if (address.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFFF7A00)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 14),
                _buildTravelModeSelector(context, ref, ref.watch(mapProvider).travelMode),
                const SizedBox(height: 8),
                _buildAlternativeRoutesSelector(ref, ref.watch(mapProvider)),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppOpenContainer(
                        closedRadius: BorderRadius.circular(14),
                        openBuilder: (context, _) => PlaceDetailScreen(id: placeId),
                        closedBuilder: (context, openContainer) {
                          return OutlinedButton.icon(
                            onPressed: () {
                              if (onDetail != null) {
                                onDetail!();
                              } else {
                                openContainer();
                              }
                            },
                            icon: const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFFF7A00)),
                            label: const Text(
                              'Xem chi tiết',
                              style: TextStyle(color: Color(0xFFFF7A00), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Color(0xFFFFEAD8)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: isFetchingRoute ? null : onNavigate,
                        icon: isFetchingRoute 
                          ? const SizedBox(
                              width: 16, height: 16, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                            )
                          : Icon(
                              activeRoute != null ? Icons.directions_rounded : Icons.refresh_rounded, 
                              size: 18, 
                              color: Colors.white
                            ),
                        label: Text(
                          isFetchingRoute 
                              ? 'Đang tính...'
                              : activeRoute != null 
                                  ? 'Bắt đầu đi (${activeRoute.formattedDuration})'
                                  : 'Thử lại / Tìm đường',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A00),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          disabledBackgroundColor: const Color(0xFFFF7A00).withValues(alpha: 0.5),
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
    );
  }

  Widget _buildTravelModeSelector(BuildContext context, WidgetRef ref, String currentMode) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _buildTravelModeChip(context, ref, mode: 'motorbike', tooltip: 'Xe máy', icon: Icons.two_wheeler_rounded, isSelected: currentMode == 'motorbike'),
          _buildTravelModeChip(context, ref, mode: 'driving', tooltip: 'Ô tô', icon: Icons.directions_car_rounded, isSelected: currentMode == 'driving'),
        ],
      ),
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

  Widget _buildTravelModeChip(BuildContext context, WidgetRef ref, {required String mode, required String tooltip, required IconData icon, required bool isSelected}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: () {
            ref.read(mapProvider.notifier).setTravelMode(mode);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? const Color(0xFF334155) : Colors.white)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: isSelected
                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 6, offset: const Offset(0, 2))]
                  : null,
            ),
            child: Icon(
              icon,
              size: 21,
              color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }


  _CategoryConfig _getCategoryConfig(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return _CategoryConfig(label: 'Quán ăn Huế', color: Colors.orange[800]!, icon: Icons.restaurant);
      case 'attraction':
        return _CategoryConfig(label: 'Địa điểm di sản', color: const Color(0xFFFF7A00), icon: Icons.place);
      case 'temple':
        return _CategoryConfig(label: 'Chùa chiền', color: Colors.purple[700]!, icon: Icons.church);
      case 'tomb':
        return _CategoryConfig(label: 'Lăng tẩm', color: const Color(0xFF9B1B30), icon: Icons.account_balance);
      default:
        return _CategoryConfig(label: 'Tham quan', color: Colors.teal[700]!, icon: Icons.tour);
    }
  }
}

class _CategoryConfig {
  final String label;
  final Color color;
  final IconData icon;

  _CategoryConfig({required this.label, required this.color, required this.icon});
}