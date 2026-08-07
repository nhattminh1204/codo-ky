import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// World bounding box — used as outer polygon of the world mask.
const List<LatLng> _kWorldBoundary = [
  LatLng(-90, -180),
  LatLng(90, -180),
  LatLng(90, 180),
  LatLng(-90, 180),
  LatLng(-90, -180),
];

/// A streamlined, high-performance territory overlay widget for Vietnam.
///
/// Features:
/// 1. [World Mask Layer] — Dims non-Vietnam territory (hole cut out for mainland).
/// 2. [Bright Highlight] — Brightens Vietnam mainland and offshore islands (Hoàng Sa, Trường Sa, Phú Quốc...).
/// 3. [Border Glow Layer] — Renders crisp cyan-white border glow lines along national borders.
class VietnamTerritoryLayers extends StatelessWidget {
  const VietnamTerritoryLayers({
    super.key,
    required this.landRings,
    this.currentZoom = 5.0,
    this.maxZoomVisible = 9.5,
    this.showWorldMask = true,
  });

  /// MultiPolygon rings for Vietnam land territory + major islands.
  final List<List<LatLng>> landRings;

  /// Current map zoom level.
  final double currentZoom;

  /// Maximum zoom level at which territory overlays remain visible.
  /// Beyond this zoom level (street/city level), overlays auto-hide to prevent
  /// dark mask culling artifacts and keep street maps crystal bright.
  final double maxZoomVisible;

  /// Whether to show the world mask (dim non-Vietnam areas).
  final bool showWorldMask;

  @override
  Widget build(BuildContext context) {
    if (landRings.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainlandRing = landRings.first;

    // Only apply foreign country dimming mask when zoomed out to country/regional view (zoom < 8.5).
    // When zooming into province/city/street level (zoom >= 8.5), foreign dimming is completely disabled
    // to GUARANTEE that the Vietnam map is 100% ALWAYS BRIGHT with zero dark shadow artifacts.
    final renderWorldMask = showWorldMask && currentZoom < 8.5 && mainlandRing.isNotEmpty;

    return Stack(
      children: [
        // ──────────────────────────────────────────────
        // LAYER 1: World Mask — Phủ mờ nhẹ quốc gia ngoài VN (Chỉ khi Zoom Out xem toàn cảnh)
        // ──────────────────────────────────────────────
        if (renderWorldMask)
          IgnorePointer(
            child: PolygonLayer(
              polygonCulling: false,
              polygons: [
                Polygon(
                  points: _kWorldBoundary,
                  holePointsList: [mainlandRing],
                  color: isDark
                      ? const Color(0x66000000) // 40% black mask in dark mode
                      : const Color(0x40000000), // 25% black mask in light mode
                  borderStrokeWidth: 0,
                  disableHolesBorder: true,
                ),
              ],
            ),
          ),

        // ──────────────────────────────────────────────
        // LAYER 2: Bright Highlight — ĐẢM BẢO BẢN ĐỒ VIỆT NAM LUÔN SÁNG RỰC RỠ 100% 🇻🇳
        // ──────────────────────────────────────────────
        if (currentZoom < 11.5)
          IgnorePointer(
            child: PolygonLayer(
              polygonCulling: true,
              polygons: [
                for (final ring in landRings)
                  if (ring.length >= 4)
                    Polygon(
                      points: ring,
                      color: isDark
                          ? const Color(0x30FFFFFF) // 19% white brightening overlay in dark mode
                          : const Color(0x45FFFFFF), // 27% white brightening overlay in light mode
                      borderColor: Colors.transparent,
                      borderStrokeWidth: 0,
                    ),
              ],
            ),
          ),

        // ──────────────────────────────────────────────
        // LAYER 3: Border Glow — Đường viền biên giới quốc gia rực sáng
        // ──────────────────────────────────────────────
        if (currentZoom < 11.5)
          IgnorePointer(
            child: PolylineLayer(
              polylines: [
                // Viền tỏa sáng cyan-blue neon (Outer Glow)
                for (final ring in landRings)
                  if (ring.length >= 8)
                    Polyline(
                      points: ring,
                      strokeWidth: 4.0,
                      color: const Color(0xB30288D1),
                    ),
                // Viền lõi trắng tinh khiết (Crisp White Core)
                for (final ring in landRings)
                  if (ring.length >= 8)
                    Polyline(
                      points: ring,
                      strokeWidth: 2.0,
                      color: const Color(0xFFFFFFFF),
                    ),
              ],
            ),
          ),
      ],
    );
  }
}

/// State for controlling territory layer visibility.
class VietnamTerritoryLayerState {
  const VietnamTerritoryLayerState({
    this.showEez = true,
    this.showTerritorialSea = true,
    this.showWorldMask = true,
  });

  final bool showEez;
  final bool showTerritorialSea;
  final bool showWorldMask;

  VietnamTerritoryLayerState copyWith({
    bool? showEez,
    bool? showTerritorialSea,
    bool? showWorldMask,
  }) {
    return VietnamTerritoryLayerState(
      showEez: showEez ?? this.showEez,
      showTerritorialSea: showTerritorialSea ?? this.showTerritorialSea,
      showWorldMask: showWorldMask ?? this.showWorldMask,
    );
  }
}
