import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/utils/helpers/bottom_sheet_helper.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/features/map/presentation/screens/filter_category_sheet.dart';
import 'package:codoky/shared/widgets/glass_container.dart';

class MapSearchBarWidget extends ConsumerStatefulWidget {
  const MapSearchBarWidget({super.key});

  @override
  ConsumerState<MapSearchBarWidget> createState() => _MapSearchBarWidgetState();
}

class _MapSearchBarWidgetState extends ConsumerState<MapSearchBarWidget> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // 1. Glassmorphism Search Capsule
                Expanded(
                  child: AppLiquidGlassContainer(
                    blur: 20,
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.35),
                      width: 1.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            onChanged: (val) {
                              ref.read(mapProvider.notifier).setSearchQuery(val);
                            },
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm địa điểm Huế...',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              filled: false,
                              isDense: true,
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: isDark ? Colors.white : Colors.black,
                                size: 22,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        size: 18,
                                        color: isDark ? Colors.white60 : Colors.black54,
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        ref.read(mapProvider.notifier).setSearchQuery('');
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        if (state.isLoading)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // 2. Separate Profile Avatar Button (Glassmorphism)
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: AppLiquidGlassContainer(
                    blur: 20,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.35),
                      width: 1.0,
                    ),
                    padding: const EdgeInsets.all(3),
                    child: CircleAvatar(
                      radius: 19,
                      backgroundColor: Colors.transparent,
                      backgroundImage: ref.watch(authProvider).user?.avatarUrl != null
                          ? NetworkImage(ref.watch(authProvider).user!.avatarUrl!)
                          : null,
                      child: ref.watch(authProvider).user?.avatarUrl == null
                          ? Icon(Icons.person, size: 20, color: isDark ? Colors.white : Colors.black87)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showAppBottomSheet(
                        context: context,
                        vsync: this,
                        builder: (_) => const FilterCategorySheet(),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: AppLiquidGlassContainer(
                        blur: 16,
                        borderRadius: BorderRadius.circular(20),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        color: state.selectedCategories.isNotEmpty 
                            ? const Color(0xFF9B1B30).withValues(alpha: 0.55) 
                            : null,
                        border: Border.all(
                          color: state.selectedCategories.isNotEmpty
                              ? const Color(0xFF9B1B30).withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: isDark ? 0.12 : 0.35),
                          width: 1.0,
                        ),
                      child: Row(
                        children: [
                          Icon(Icons.tune_rounded, size: 16, color: state.selectedCategories.isNotEmpty ? Colors.white : const Color(0xFF9B1B30)),
                          const SizedBox(width: 4),
                          Text(
                            state.selectedCategories.isNotEmpty ? 'Lọc (${state.selectedCategories.length})' : 'Bộ lọc',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: state.selectedCategories.isNotEmpty ? Colors.white : const Color(0xFF9B1B30)),
                          ),
                          if (state.selectedCategories.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                ref.read(mapProvider.notifier).filterByCategories({});
                              },
                              child: const Icon(Icons.cancel_rounded, size: 16, color: Colors.white70),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                _buildFilterChip('featured', 'Nổi bật', state, isDark),
                const SizedBox(width: 8),
                  _buildFilterChip('saved', 'Đã lưu (${state.savedPlaceIds.length})', state, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('all', 'Tất cả', state, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('restaurant', 'Quán ăn', state, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('attraction', 'Địa điểm', state, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('tomb', 'Lăng tẩm', state, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('temple', 'Chùa', state, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String categoryId, String label, MapState state, bool isDark) {
    final isSelected = (state.selectedCategory == categoryId) ||
        (state.selectedCategory == null && categoryId == 'all');

    return GestureDetector(
      onTap: () {
        ref.read(mapProvider.notifier).filterByCategory(categoryId);
      },
      child: AppLiquidGlassContainer(
        blur: 16,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        color: isSelected
            ? const Color(0xFF9B1B30).withValues(alpha: 0.55)
            : null,
        border: Border.all(
          color: isSelected
              ? const Color(0xFF9B1B30).withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: isDark ? 0.12 : 0.35),
          width: 1.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
