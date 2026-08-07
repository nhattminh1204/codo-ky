import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/utils/helpers/bottom_sheet_helper.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/features/map/presentation/widgets/place_marker.dart';

class MapToolbarWidget extends ConsumerWidget {
  final bool isAutoFollowUser;
  final bool is3dPerspective;
  final VoidCallback onRecenterGps;
  final VoidCallback onLocateUser;
  final VoidCallback? onFitRouteOverview;
  final VoidCallback? onToggle3dPerspective;
  final VoidCallback? onToggleLayers;
  final bool isLayerPanelOpen;

  const MapToolbarWidget({
    super.key,
    required this.isAutoFollowUser,
    this.is3dPerspective = true,
    required this.onRecenterGps,
    required this.onLocateUser,
    this.onFitRouteOverview,
    this.onToggle3dPerspective,
    this.onToggleLayers,
    this.isLayerPanelOpen = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    final bool isNavigatingActive = state.activeRoute != null;

    if (isNavigatingActive) {
      // Khi đang dẫn đường trực tiếp:
      // 1. Nút Tái định tâm / Zoom cận cảnh vị trí xe của tôi (Recenter GPS)
      // 2. Nút Chuyển đổi Góc nhìn 3D theo hướng xe (Heading-Up) vs 2D hướng Bắc (North-Up)
      // 3. Nút Zoom ra xem toàn cảnh tổng thể tuyến đường (Route Overview Fit Bounds)
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Nút Zoom đến vị trí bản thân / Tái định tâm GPS (Sáng xanh Cyan khi đang bám xe)
          _buildCircularFloatingButton(
            context: context,
            icon: isAutoFollowUser ? Icons.gps_fixed_rounded : Icons.location_searching_rounded,
            tooltip: l10n.recenterTooltip,
            iconColor: isAutoFollowUser
                ? const Color(0xFF38BDF8)
                : (isDark ? Colors.white70 : const Color(0xFF64748B)),
            onPressed: onRecenterGps,
          ),

          const SizedBox(height: 12),

          // 2. Nút Góc nhìn 3D theo hướng xe (Heading-Up) vs 2D hướng Bắc (North-Up)
          _buildCircularFloatingButton(
            context: context,
            icon: is3dPerspective ? Icons.explore_rounded : Icons.explore_off_rounded,
            tooltip: is3dPerspective ? l10n.perspective3dTooltip : l10n.perspective2dTooltip,
            iconColor: is3dPerspective
                ? const Color(0xFF818CF8) // Tím Indigo / Lavender năng động
                : (isDark ? Colors.white70 : const Color(0xFF64748B)),
            onPressed: onToggle3dPerspective ?? onRecenterGps,
          ),

          const SizedBox(height: 12),

          // 3. Nút Zoom ra xem toàn cảnh tuyến đường đi (Route Overview)
          _buildCircularFloatingButton(
            context: context,
            icon: Icons.route_rounded,
            tooltip: l10n.routeOverviewTooltip,
            iconColor: const Color(0xFF10B981),
            onPressed: onFitRouteOverview ?? onRecenterGps,
          ),
        ],
      );
    }

    // Khi ở chế độ xem bản đồ tự do (Browsing mode)
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Tùy chỉnh phong cách Icon
        _buildCircularFloatingButton(
          context: context,
          icon: Icons.palette_outlined,
          tooltip: l10n.mapStyleTooltip,
          iconColor: isDark ? Colors.white70 : const Color(0xFF2563EB),
          onPressed: () => _showIconStyleDrawer(context, ref),
        ),

        const SizedBox(height: 12),

        // 2. Định vị vị trí hiện tại
        _buildCircularFloatingButton(
          context: context,
          icon: Icons.my_location_rounded,
          tooltip: l10n.myLocationTooltip,
          iconColor: isDark ? Colors.white : const Color(0xFF1E293B),
          onPressed: onLocateUser,
        ),

        const SizedBox(height: 12),

        // 3. Lớp bản đồ POI & Di tích
        _buildCircularFloatingButton(
          context: context,
          icon: isLayerPanelOpen ? Icons.layers_rounded : Icons.layers_outlined,
          tooltip: l10n.layersTooltip,
          iconColor: isLayerPanelOpen
              ? const Color(0xFF38BDF8)
              : (isDark ? Colors.white70 : const Color(0xFF64748B)),
          onPressed: onToggleLayers ?? () => _showIconStyleDrawer(context, ref),
        ),
      ],
    );
  }

  Widget _buildCircularFloatingButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.white : const Color(0xFF1E222A);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222D) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Tooltip(
            message: tooltip ?? '',
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? defaultColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.white : const Color(0xFF1E222A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Tooltip(
          message: tooltip ?? '',
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? defaultColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlDivider(bool isDark) {
    return Container(
      width: 20,
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
    );
  }

  void _showIconStyleDrawer(BuildContext context, WidgetRef ref) {
    final currentStyle = ref.read(mapProvider).markerStyle;
    final l10n = context.l10n;

    showAppBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).padding.bottom;
        return Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 28),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5E36).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFF5E36), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.iconStyleTitle,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              l10n.iconStyleSubtitle,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStyleOptionCard(
                  context: context,
                  ref: ref,
                  style: MapMarkerStyle.gradientVibrantGlow,
                  title: l10n.styleGlowTitle,
                  subtitle: l10n.styleGlowSubtitle,
                  icon: Icons.bolt_rounded,
                  color: const Color(0xFFFF5E36),
                  isSelected: currentStyle == MapMarkerStyle.gradientVibrantGlow,
                ),
                const SizedBox(height: 12),
                _buildStyleOptionCard(
                  context: context,
                  ref: ref,
                  style: MapMarkerStyle.glassmorphicDuotone,
                  title: l10n.styleDuotoneTitle,
                  subtitle: l10n.styleDuotoneSubtitle,
                  icon: Icons.layers_rounded,
                  color: const Color(0xFF06B6D4),
                  isSelected: currentStyle == MapMarkerStyle.glassmorphicDuotone,
                ),
                const SizedBox(height: 12),
                _buildStyleOptionCard(
                  context: context,
                  ref: ref,
                  style: MapMarkerStyle.playfulPop3D,
                  title: l10n.style3dTitle,
                  subtitle: l10n.style3dSubtitle,
                  icon: Icons.sentiment_very_satisfied_rounded,
                  color: const Color(0xFF8B5CF6),
                  isSelected: currentStyle == MapMarkerStyle.playfulPop3D,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStyleOptionCard({
    required BuildContext context,
    required WidgetRef ref,
    required MapMarkerStyle style,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        ref.read(mapProvider.notifier).setMarkerStyle(style);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? color : Colors.white30,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
