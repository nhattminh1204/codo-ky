import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'package:codoky/features/explore/presentation/providers/explore_provider.dart';

class PlacePickerBottomSheet extends ConsumerStatefulWidget {
  const PlacePickerBottomSheet({super.key});

  @override
  ConsumerState<PlacePickerBottomSheet> createState() => _PlacePickerBottomSheetState();
}

class _PlacePickerBottomSheetState extends ConsumerState<PlacePickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure places are loaded in exploreProvider
    Future.microtask(() {
      ref.read(exploreProvider.notifier).loadPlaces();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exploreState = ref.watch(exploreProvider);
    final places = exploreState.places;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chọn điểm đến Huế ✨',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Search Bar Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(exploreProvider.notifier).searchPlaces(value);
                },
                decoration: InputDecoration(
                  hintText: 'Tìm địa điểm, di sản, quán ăn...',
                  hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFF7A00)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(exploreProvider.notifier).searchPlaces('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Category Filter Chips
          if (exploreState.categories.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                scrollDirection: Axis.horizontal,
                itemCount: exploreState.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = exploreState.categories[index];
                  final catId = cat['id'] as String;
                  final catName = cat['name'] as String;
                  final isSelected = (exploreState.selectedCategory == catId) ||
                      (exploreState.selectedCategory == null && catId == 'all');

                  return GestureDetector(
                    onTap: () {
                      ref.read(exploreProvider.notifier).selectCategory(catId);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        catName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 8),

          // Places List Body
          Expanded(
            child: exploreState.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00)))
                : places.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                            SizedBox(height: 12),
                            Text(
                              'Không tìm thấy địa điểm nào',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: places.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final place = places[index];
                          final name = place['name']?.toString() ?? 'Địa điểm';
                          final address = place['address']?.toString() ?? '';
                          final category = place['category']?.toString() ?? '';
                          final imageUrl = place['image_url']?.toString();
                          final rating = place['rating']?.toString() ?? '4.8';

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.of(context).pop(place),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    // Place Thumbnail
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: imageUrl != null && imageUrl.isNotEmpty
                                          ? Image.network(
                                              imageUrl,
                                              width: 56,
                                              height: 56,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) => _buildFallbackIcon(category),
                                            )
                                          : _buildFallbackIcon(category),
                                    ),
                                    const SizedBox(width: 12),

                                    // Place Title & Address
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (address.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              address,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF64748B),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    // Rating & Add Button Indicator
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB800)),
                                            const SizedBox(width: 2),
                                            Text(
                                              rating,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            '+ Thêm',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFF7A00),
                                            ),
                                          ),
                                        ),
                                      ],
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

  Widget _buildFallbackIcon(String category) {
    IconData icon = Icons.location_on_rounded;
    if (category.contains('restaurant') || category.contains('food')) {
      icon = Icons.restaurant_rounded;
    } else if (category.contains('temple')) {
      icon = Icons.account_balance_rounded;
    }

    return Container(
      width: 56,
      height: 56,
      color: const Color(0xFFFFEAD8),
      child: Icon(icon, color: const Color(0xFFFF7A00), size: 28),
    );
  }
}
