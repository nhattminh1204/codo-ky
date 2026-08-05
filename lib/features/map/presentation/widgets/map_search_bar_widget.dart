import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/utils/helpers/bottom_sheet_helper.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/features/map/presentation/providers/current_weather_provider.dart';
import 'package:codoky/features/map/presentation/screens/filter_category_sheet.dart';
import 'package:codoky/features/map/presentation/widgets/weather_detail_sheet.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
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
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Search Bar Capsule with Integrated Mic & Avatar
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      onChanged: (val) {
                        ref.read(mapProvider.notifier).setSearchQuery(val);
                      },
                      decoration: InputDecoration(
                        hintText: l10n.mapSearchHint,
                        hintStyle: TextStyle(
                          fontSize: 13.5,
                          color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  if (state.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Color(0xFF8B1522),
                        ),
                      ),
                    ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.mic_rounded,
                      size: 19,
                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                    ),
                    onPressed: () {
                      // Voice search placeholder
                    },
                  ),
                  // ── Weather Badge ──────────────────────────────────────────
                  _WeatherBadge(isDark: isDark),
                  const SizedBox(width: 4),
                  Container(
                    width: 1,
                    height: 16,
                    color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                  ),
                  const SizedBox(width: 8),
                  // Profile Avatar Circle (G)
                  Builder(
                    builder: (context) {
                      final user = ref.watch(authProvider).user;
                      final fbPhotoUrl = FirebaseAuth.instance.currentUser?.photoURL;
                      final avatarUrl = (user?.avatarUrl != null && user!.avatarUrl!.trim().isNotEmpty)
                          ? user.avatarUrl!.trim()
                          : (fbPhotoUrl != null && fbPhotoUrl.trim().isNotEmpty ? fbPhotoUrl.trim() : null);

                      return GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: const Color(0xFF8B1522),
                          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                          child: avatarUrl == null
                              ? Text(
                                  (user?.name != null && user!.name.trim().isNotEmpty)
                                      ? user.name.trim()[0].toUpperCase()
                                      : 'G',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
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
                          ? LiquidGlassSettings(glassColor: AppColors.primary.withValues(alpha: 0.85)) 
                          : null,
                        child: Row(
                          children: [
                            Icon(Icons.tune_rounded, size: 16, color: state.selectedCategories.isNotEmpty ? Colors.white : AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              state.selectedCategories.isNotEmpty
                                  ? l10n.filterLabel(state.selectedCategories.length)
                                  : l10n.filterLabelNoCount,
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: state.selectedCategories.isNotEmpty ? Colors.white : AppColors.primary),
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
                _buildFilterChip('featured', l10n.featured, state, isDark),
                const SizedBox(width: 8),
                  _buildFilterChip('saved', l10n.savedCountLabel(state.savedPlaceIds.length), state, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('all', l10n.all, state, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('restaurant', l10n.restaurant, state, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('attraction', l10n.place, state, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('tomb', l10n.tomb, state, isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('temple', l10n.temple, state, isDark),
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
    final isSavedChip = categoryId == 'saved';

    return GestureDetector(
      onTap: () {
        ref.read(mapProvider.notifier).filterByCategory(categoryId);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0F172A))
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSavedChip) ...[
              Icon(
                Icons.bookmark_rounded,
                size: 13,
                color: isSelected
                    ? (isDark ? Colors.black : const Color(0xFFF59E0B))
                    : const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? Colors.white70 : const Color(0xFF334155)),
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

// ── Weather Badge ──────────────────────────────────────────────────────────────
/// Badge nhỏ hiển thị icon + nhiệt độ hiện tại trong Search Bar.
/// Chỉ hiện khi đã có dữ liệu; tap → mở [WeatherDetailSheet].
class _WeatherBadge extends ConsumerWidget {
  final bool isDark;
  const _WeatherBadge({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(currentWeatherProvider);
    return weatherState.currentWeather.maybeWhen(
      data: (w) => GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const WeatherDetailSheet(),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : const Color(0xFFBFDBFE),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(w.weatherIcon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 3),
              Text(
                '${w.temperature.round()}°',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1D4ED8),
                ),
              ),
            ],
          ),
        ),
      ),
      orElse: () => const SizedBox.shrink(),
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
