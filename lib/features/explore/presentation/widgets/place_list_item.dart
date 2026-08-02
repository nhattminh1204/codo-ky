import 'package:flutter/material.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:animations/animations.dart';
import 'package:codoky/core/theme/motion.dart';
import 'package:codoky/features/map/presentation/screens/place_detail_screen.dart';

class PlaceListItem extends StatelessWidget {
  final dynamic place;
  final VoidCallback? onTap;
  final bool enableContainerTransform;

  const PlaceListItem({
    super.key,
    required this.place,
    this.onTap,
    this.enableContainerTransform = true,
  });

  @override
  Widget build(BuildContext context) {
    final placeId = (place is Map ? place['id'] : place?.id)?.toString() ?? '1';

    if (enableContainerTransform) {
      return OpenContainer(
        transitionDuration: AppMotion.emphasized,
        transitionType: ContainerTransitionType.fade,
        closedElevation: 0,
        openElevation: 0,
        closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        closedColor: Colors.transparent,
        openColor: const Color(0xFFF8FAFC),
        openBuilder: (context, _) => PlaceDetailScreen(id: placeId),
        closedBuilder: (context, openContainer) {
          return _buildCardContent(context, () {
            if (onTap != null) onTap!();
            openContainer();
          });
        },
      );
    }

    return _buildCardContent(context, onTap ?? () {});
  }

  Widget _buildCardContent(BuildContext context, VoidCallback handleTap) {
    final name = place is Map ? (place['name'] as String? ?? 'Địa điểm Huế') : (place?.name as String? ?? 'Địa điểm Huế');
    final address = place is Map ? (place['address'] as String? ?? 'Thừa Thiên Huế') : (place?.address as String? ?? 'Thừa Thiên Huế');
    final category = place is Map ? (place['category'] as String? ?? 'attraction') : (place?.category as String? ?? 'attraction');
    final rating = place is Map ? ((place['rating'] as num?)?.toDouble() ?? 4.8) : ((place?.rating as num?)?.toDouble() ?? 4.8);

    final config = _getCategoryConfig(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: handleTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Travel Image Placeholder / Hero Thumbnail
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            config.color.withValues(alpha: 0.8),
                            config.color,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        config.icon,
                        size: 38,
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 12, color: Color(0xFFFFD700)),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 10,
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
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: config.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              config.label,
                              style: TextStyle(
                                color: config.color,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.bookmark_border_rounded),
                            color: Colors.grey.shade400,
                            iconSize: 22,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }

  _CategoryConfig _getCategoryConfig(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return _CategoryConfig(label: 'Quán ăn', color: const Color(0xFFE65100), icon: Icons.restaurant);
      case 'attraction':
        return _CategoryConfig(label: 'Địa điểm', color: const Color(0xFF0277BD), icon: Icons.photo_camera_rounded);
      case 'temple':
        return _CategoryConfig(label: 'Chùa chiền', color: const Color(0xFF6A1B9A), icon: Icons.temple_buddhist);
      case 'tomb':
        return _CategoryConfig(label: 'Lăng tẩm', color: AppColors.primary, icon: Icons.account_balance);
      default:
        return _CategoryConfig(label: 'Tham quan', color: const Color(0xFF2E7D32), icon: Icons.explore_rounded);
    }
  }
}

class _CategoryConfig {
  final String label;
  final Color color;
  final IconData icon;

  _CategoryConfig({required this.label, required this.color, required this.icon});
}