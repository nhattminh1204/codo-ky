import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/utils/helpers/bottom_sheet_helper.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/features/map/presentation/widgets/place_marker.dart';

class MapToolbarWidget extends ConsumerWidget {
  final bool isAutoFollowUser;
  final VoidCallback onRecenterGps;
  final VoidCallback onLocateUser;

  const MapToolbarWidget({
    super.key,
    required this.isAutoFollowUser,
    required this.onRecenterGps,
    required this.onLocateUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.08),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Theme Palette
          _buildControlIconButton(
            context: context,
            icon: Icons.palette_outlined,
            tooltip: l10n.mapStyleTooltip,
            iconColor: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF2563EB),
            onPressed: () => _showIconStyleDrawer(context, ref),
          ),
          _buildControlDivider(isDark),

          // 2. Recenter GPS (Active Route & panned map)
          if (state.activeRoute != null && !isAutoFollowUser) ...[
            _buildControlIconButton(
              context: context,
              icon: Icons.gps_fixed_rounded,
              tooltip: l10n.recenterTooltip,
              iconColor: const Color(0xFF2563EB),
              onPressed: onRecenterGps,
            ),
            _buildControlDivider(isDark),
          ],

          // 3. Locate User GPS
          _buildControlIconButton(
            context: context,
            icon: Icons.my_location_rounded,
            tooltip: l10n.myLocationTooltip,
            iconColor: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF2563EB),
            onPressed: onLocateUser,
          ),
        ],
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
