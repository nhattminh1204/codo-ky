import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/utils/helpers/bottom_sheet_helper.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/features/map/presentation/screens/filter_category_sheet.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

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
                  child: _buildGradientGlassContainer(
                    borderRadius: 20,
                    isDark: isDark,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
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
                Builder(
                  builder: (context) {
                    final user = ref.watch(authProvider).user;
                    final fbPhotoUrl = FirebaseAuth.instance.currentUser?.photoURL;
                    final avatarUrl = (user?.avatarUrl != null && user!.avatarUrl!.trim().isNotEmpty)
                        ? user.avatarUrl!.trim()
                        : (fbPhotoUrl != null && fbPhotoUrl.trim().isNotEmpty ? fbPhotoUrl.trim() : null);

                    return GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: _buildGradientGlassContainer(
                        borderRadius: 24,
                        isDark: isDark,
                        padding: const EdgeInsets.all(3),
                        child: CircleAvatar(
                          radius: 19,
                          backgroundColor: Colors.transparent,
                          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                          child: avatarUrl == null
                              ? (user?.name != null && user!.name.trim().isNotEmpty
                                  ? Text(
                                      user.name.trim()[0].toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDark ? Colors.white : const Color(0xFF8B1522),
                                      ),
                                    )
                                  : Icon(Icons.person_rounded, size: 20, color: isDark ? Colors.white : Colors.black87))
                              : null,
                        ),
                      ),
                    );
                  },
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
                      child: _buildGradientGlassContainer(
                        borderRadius: 20,
                        isDark: isDark,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        settings: state.selectedCategories.isNotEmpty 
                          ? const LiquidGlassSettings(glassColor: Color(0x8C9B1B30)) 
                          : null,
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
      child: _buildGradientGlassContainer(
        borderRadius: 20,
        isDark: isDark,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        settings: isSelected 
          ? const LiquidGlassSettings(glassColor: Color(0x8C9B1B30)) 
          : null,
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

  Widget _buildGradientGlassContainer({
    required Widget child,
    required double borderRadius,
    required bool isDark,
    EdgeInsetsGeometry? padding,
    LiquidGlassSettings? settings,
  }) {
    final defaultGlassColor = isDark ? const Color(0x33000000) : const Color(0x33FFFFFF);
    final effectiveSettings = settings ?? LiquidGlassSettings(glassColor: defaultGlassColor);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: _GradientBorderPainter(
          borderRadius: borderRadius,
          borderWidth: 1.2,
          isDark: isDark,
        ),
        child: GlassContainer(
          useOwnLayer: true,
          quality: GlassQuality.standard,
          shape: LiquidRoundedRectangle(borderRadius: borderRadius),
          padding: padding,
          settings: effectiveSettings,
          child: child,
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;
  final bool isDark;

  const _GradientBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      borderWidth / 2,
      borderWidth / 2,
      size.width - borderWidth,
      size.height - borderWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final grayColor = isDark
        ? const Color(0xFF94A3B8).withValues(alpha: 0.85)
        : const Color(0xFF64748B).withValues(alpha: 0.90);
    final brightColor = isDark
        ? Colors.white.withValues(alpha: 0.95)
        : Colors.white;

    final midBlend = Color.lerp(grayColor, brightColor, 0.5)!;

    final gradient = SweepGradient(
      center: Alignment.center,
      startAngle: 0.0,
      endAngle: 2 * math.pi,
      colors: [
        midBlend,    // 0° (Right)
        grayColor,   // 45° (Bottom-Right corner)
        brightColor, // 135° (Bottom-Left corner)
        grayColor,   // 225° (Top-Left corner)
        brightColor, // 315° (Top-Right corner)
        midBlend,    // 360° (Right)
      ],
      stops: const [0.0, 0.125, 0.375, 0.625, 0.875, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.isDark != isDark;
  }
}
