import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class MainShellLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellLayout({
    super.key,
    required this.navigationShell,
  });

  @override
  State<MainShellLayout> createState() => _MainShellLayoutState();
}

class _NavItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;
  final int branchIndex;

  const _NavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
    required this.branchIndex,
  });
}

class _MainShellLayoutState extends State<MainShellLayout> {
  int? _pressedIndex;

  void _onItemTapped(int index, BuildContext context) {
    HapticFeedback.lightImpact();
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  int _getActiveTabIndex(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 3:
        return 2;
      case 4:
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = widget.navigationShell.currentIndex;
    final activeIndex = _getActiveTabIndex(selectedIndex);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final aquaItems = const [
      _NavItemData(icon: Icons.map_outlined, selectedIcon: Icons.map_rounded, label: 'Bản đồ', route: '/map', branchIndex: 0),
      _NavItemData(icon: Icons.explore_outlined, selectedIcon: Icons.explore_rounded, label: 'Khám phá', route: '/explore', branchIndex: 1),
      _NavItemData(icon: Icons.calendar_today_outlined, selectedIcon: Icons.calendar_today_rounded, label: 'Lịch trình', route: '/itinerary', branchIndex: 3),
      _NavItemData(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Hồ sơ', route: '/profile', branchIndex: 4),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: widget.navigationShell,
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
          child: Row(
            children: [
              // 1. Thanh kính chính (Main Frost Glass Bar) - [backdrop-filter:blur(28px)_saturate(180%)]
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E222A).withValues(alpha: 0.40)
                            : Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.20)
                              : Colors.white.withValues(alpha: 0.50),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.45)
                                : const Color(0xFF475569).withValues(alpha: 0.20),
                            blurRadius: 40,
                            offset: const Offset(0, 12),
                            spreadRadius: -12,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(aquaItems.length, (i) {
                          final item = aquaItems[i];
                          final on = i == activeIndex;
                          final isPressed = _pressedIndex == item.branchIndex;

                          return GestureDetector(
                            onTapDown: (_) => setState(() => _pressedIndex = item.branchIndex),
                            onTapUp: (_) => setState(() => _pressedIndex = null),
                            onTapCancel: () => setState(() => _pressedIndex = null),
                            onTap: () => _onItemTapped(item.branchIndex, context),
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedScale(
                              scale: isPressed ? 0.90 : 1.0,
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.easeOutCubic,
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Layer A: Quầng sáng tỏa ra (Glow Aura blur-xl)
                                    AnimatedOpacity(
                                      opacity: on ? 0.45 : 0.0,
                                      duration: const Duration(milliseconds: 500),
                                      child: AnimatedScale(
                                        scale: on ? 1.0 : 0.5,
                                        duration: const Duration(milliseconds: 500),
                                        child: Container(
                                          width: 56,
                                          height: 56,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xFF2DD4BF), // Aqua blur-xl
                                                blurRadius: 28,
                                                spreadRadius: 8,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Layer B: Ô active kính aqua (Spring cubic-bezier(0.34, 1.3, 0.64, 1))
                                    AnimatedOpacity(
                                      opacity: on ? 1.0 : 0.0,
                                      duration: const Duration(milliseconds: 400),
                                      curve: const Cubic(0.34, 1.3, 0.64, 1.0),
                                      child: AnimatedScale(
                                        scale: on ? 1.0 : 0.75,
                                        duration: const Duration(milliseconds: 400),
                                        curve: const Cubic(0.34, 1.3, 0.64, 1.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(19), // rounded-[1.2rem]
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                            child: Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2DD4BF).withValues(alpha: 0.55), // bg-aqua/55
                                                borderRadius: BorderRadius.circular(19),
                                                border: Border.all(
                                                  color: Colors.white.withValues(alpha: 0.50),
                                                  width: 1.2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(0xFF2DD4BF).withValues(alpha: 0.75),
                                                    blurRadius: 28,
                                                    offset: const Offset(0, 8),
                                                    spreadRadius: -2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Layer C: Icon (Lucide Icon 22px)
                                    Icon(
                                      on ? item.selectedIcon : item.icon,
                                      size: 22,
                                      color: on
                                          ? Colors.white
                                          : (isDark ? Colors.white70 : const Color(0xFF475569)),
                                    ),

                                    // Notification badge dot
                                    if (item.label == 'Khám phá' && !on)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFEF4444),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 2. Nút phụ tách riêng (Sparkles AI Button - 64x64px h-16 w-16 shrink-0 place-items-center rounded-full)
              GestureDetector(
                onTapDown: (_) => setState(() => _pressedIndex = 2),
                onTapUp: (_) => setState(() => _pressedIndex = null),
                onTapCancel: () => setState(() => _pressedIndex = null),
                onTap: () => _onItemTapped(2, context),
                child: AnimatedScale(
                  scale: _pressedIndex == 2 ? 0.92 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutCubic,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9999),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF1E222A).withValues(alpha: 0.40)
                              : Colors.white.withValues(alpha: 0.25),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.20)
                                : Colors.white.withValues(alpha: 0.50),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.45)
                                  : const Color(0xFF475569).withValues(alpha: 0.20),
                              blurRadius: 40,
                              offset: const Offset(0, 12),
                              spreadRadius: -12,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 24,
                            color: isDark ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
