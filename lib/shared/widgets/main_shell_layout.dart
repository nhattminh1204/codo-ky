import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';

class _NavItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
  final int branchIndex;
  final bool hasBadge;

  const _NavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
    required this.branchIndex,
    this.hasBadge = false,
  });
}

class MainShellLayout extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellLayout({super.key, required this.navigationShell});

  @override
  ConsumerState<MainShellLayout> createState() => _MainShellLayoutState();
}

class _MainShellLayoutState extends ConsumerState<MainShellLayout> {
  void _onItemTapped(int index, BuildContext context) {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      try {
        HapticFeedback.lightImpact();
      } catch (_) {}
    }
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  int _getActiveTabColumn(int currentIndex) {
    switch (currentIndex) {
      case 0: return 0; // Map
      case 1: return 1; // Explore
      case 2: return 2; // Camera
      case 3: return 3; // Itinerary
      case 4: return 4; // Profile
      default: return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = widget.navigationShell.currentIndex;
    final activeColumn = _getActiveTabColumn(selectedIndex);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLiveNavigating = (ref.watch(mapProvider).isNavigating || ref.watch(mapProvider).activeRoute != null) && selectedIndex == 0;

    final navTabs = [
      _NavItemData(icon: Icons.map_outlined, selectedIcon: Icons.map_rounded, label: context.l10n.navMap, route: '/map', branchIndex: 0),
      _NavItemData(icon: Icons.explore_outlined, selectedIcon: Icons.explore_rounded, label: context.l10n.navExplore, route: '/explore', branchIndex: 1),
      _NavItemData(icon: Icons.camera_alt_outlined, selectedIcon: Icons.camera_alt_rounded, label: context.l10n.navCamera, route: '/camera', branchIndex: 2),
      _NavItemData(icon: Icons.calendar_today_outlined, selectedIcon: Icons.calendar_today_rounded, label: context.l10n.navItinerary, route: '/itinerary', branchIndex: 3, hasBadge: true),
      _NavItemData(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: context.l10n.navProfile, route: '/profile', branchIndex: 4),
    ];

    const double navHeight = 52;

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: widget.navigationShell,
      bottomNavigationBar: isLiveNavigating
          ? const SizedBox.shrink()
          : SafeArea(
              bottom: true,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0, left: 14.0, right: 14.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9999),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.40)
                      : Colors.black.withValues(alpha: 0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CustomPaint(
              foregroundPainter: _GradientBorderPainter(
                borderRadius: 9999,
                borderWidth: 1.5,
                isDark: isDark,
              ),
              child: GlassContainer(
              useOwnLayer: true,
              quality: GlassQuality.premium,
              shape: const LiquidRoundedRectangle(borderRadius: 9999),
              settings: LiquidGlassSettings(
                glassColor: isDark ? const Color(0x33000000) : const Color(0x33FFFFFF),
              ),
              padding: const EdgeInsets.all(4),
              child: SizedBox(
                height: navHeight,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final columnWidth = constraints.maxWidth / 5;

                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Active Pill Indicator
                        if (activeColumn != -1)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300), // AppMotion.standard
                            curve: const Cubic(0.34, 1.20, 0.64, 1.0), // Spring curve
                            left: activeColumn * columnWidth,
                            top: 0,
                            bottom: 0,
                            width: columnWidth,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              child: CustomPaint(
                                foregroundPainter: _GradientBorderPainter(
                                  borderRadius: 9999,
                                  borderWidth: 1.2,
                                  isDark: isDark,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.18)
                                        : Colors.black.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                ),
                              ),
                            ),
                          ),

                      // Tabs
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: navTabs.map((item) {
                          return Expanded(
                            child: _NavItemButton(
                              item: item,
                              isSelected: selectedIndex == item.branchIndex,
                              isDark: isDark,
                              onTap: () => _onItemTapped(item.branchIndex, context),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);
  }
}

class _NavItemButton extends StatelessWidget {
  final _NavItemData item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItemButton({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? Colors.white : Colors.black87;
    final inactiveColor = isDark ? Colors.white54 : Colors.black54;

    final isCamera = item.branchIndex == 2;
    final iconSize = isCamera ? (isSelected ? 27.0 : 25.0) : (isSelected ? 25.0 : 23.0);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: Icon(
                isSelected ? item.selectedIcon : item.icon,
                size: iconSize,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            if (item.hasBadge)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : const Color(0xFF8B1522),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
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
