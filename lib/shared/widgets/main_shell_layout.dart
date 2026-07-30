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
      case 2:
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

    final navTabs = const [
      _NavItemData(icon: Icons.map_outlined, selectedIcon: Icons.map_rounded, label: 'Bản đồ', route: '/map', branchIndex: 0),
      _NavItemData(icon: Icons.explore_outlined, selectedIcon: Icons.explore_rounded, label: 'Khám phá', route: '/explore', branchIndex: 1),
      _NavItemData(icon: Icons.calendar_today_outlined, selectedIcon: Icons.calendar_today_rounded, label: 'Lịch trình', route: '/itinerary', branchIndex: 3, hasBadge: true),
      _NavItemData(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Hồ sơ', route: '/profile', branchIndex: 4),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: widget.navigationShell,
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
          child: Row(
            children: [
              // 1. Floating Glass Navigation Container (.glass-container h-[62px])
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  clipBehavior: Clip.antiAlias,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                    child: Container(
                      height: 62,
                      clipBehavior: Clip.antiAlias,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A).withValues(alpha: 0.45)
                            : const Color(0xFFF1F5F9).withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.35)
                              : Colors.white.withValues(alpha: 0.85),
                          width: 1.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.50)
                                : const Color(0xFF334155).withValues(alpha: 0.14),
                            blurRadius: 40,
                            offset: const Offset(0, 18),
                            spreadRadius: -6,
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.95),
                            blurRadius: 2,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const inset = 1.0;
                          final totalWidth = constraints.maxWidth;
                          final availableWidth = totalWidth - (inset * 2);
                          final tabWidth = availableWidth / navTabs.length;

                          return Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              // 2. Sliding Active Cyan Glowing Pill (3D Liquid Glass with Crisp 1.8px Rim)
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 320),
                                curve: const Cubic(0.34, 1.20, 0.64, 1.0),
                                left: inset + (activeIndex * tabWidth),
                                top: 0,
                                bottom: 0,
                                width: tabWidth,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(9999),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF71E2E8).withValues(alpha: 0.88),
                                            const Color(0xFF2DBAC6).withValues(alpha: 0.92),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(9999),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.92),
                                          width: 1.8,
                                        ),
                                        boxShadow: [
                                          // Outer cyan glow
                                          BoxShadow(
                                            color: const Color(0xFF2DBAC6).withValues(alpha: 0.55),
                                            blurRadius: 22,
                                            offset: const Offset(0, 9),
                                            spreadRadius: -2,
                                          ),
                                          // Top rim glass bevel highlight
                                          BoxShadow(
                                            color: Colors.white.withValues(alpha: 0.95),
                                            blurRadius: 2.5,
                                            offset: const Offset(0, 1.5),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          // Glossy Glass Reflection Overlay (Vệt sáng kính 3D)
                                          Positioned.fill(
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(9999),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white.withValues(alpha: 0.65),
                                                    Colors.white.withValues(alpha: 0.15),
                                                    Colors.white.withValues(alpha: 0.0),
                                                  ],
                                                  stops: const [0.0, 0.45, 1.0],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // 3. Tab Buttons Layer (.nav-btn)
                              Row(
                                children: List.generate(navTabs.length, (index) {
                                  final item = navTabs[index];
                                  final isSelected = activeIndex == index;
                                  final isPressed = _pressedIndex == item.branchIndex;

                                  return Expanded(
                                    child: GestureDetector(
                                      onTapDown: (_) => setState(() => _pressedIndex = item.branchIndex),
                                      onTapUp: (_) => setState(() => _pressedIndex = null),
                                      onTapCancel: () => setState(() => _pressedIndex = null),
                                      onTap: () => _onItemTapped(item.branchIndex, context),
                                      behavior: HitTestBehavior.opaque,
                                      child: AnimatedScale(
                                        scale: isPressed ? 0.92 : 1.0,
                                        duration: const Duration(milliseconds: 150),
                                        curve: Curves.easeOutCubic,
                                        child: SizedBox(
                                          height: 52,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Pressed soft glass feedback pill (.glass-press-effect)
                                              AnimatedOpacity(
                                                opacity: isPressed ? 1.0 : 0.0,
                                                duration: const Duration(milliseconds: 150),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(9999),
                                                  child: BackdropFilter(
                                                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                                    child: Container(
                                                      width: 44,
                                                      height: 44,
                                                      decoration: BoxDecoration(
                                                        color: isDark
                                                            ? Colors.white.withValues(alpha: 0.18)
                                                            : Colors.white.withValues(alpha: 0.45),
                                                        borderRadius: BorderRadius.circular(9999),
                                                        border: Border.all(
                                                          color: Colors.white.withValues(alpha: 0.75),
                                                          width: 1.5,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.white.withValues(alpha: 0.50),
                                                            blurRadius: 10,
                                                            spreadRadius: 1,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Icon (.nav-btn.active vs .nav-btn:not(.active))
                                              Icon(
                                                isSelected ? item.selectedIcon : item.icon,
                                                size: 24,
                                                color: isSelected
                                                    ? Colors.white
                                                    : (isDark ? Colors.white70 : const Color(0xFF4B5563)),
                                              ),

                                              // Orange Notification Badge Dot
                                              if (item.hasBadge && !isSelected)
                                                Positioned(
                                                  top: 11,
                                                  right: 18,
                                                  child: Container(
                                                    width: 9,
                                                    height: 9,
                                                    decoration: BoxDecoration(
                                                      gradient: const LinearGradient(
                                                        colors: [
                                                          Color(0xFFFBBF24), // amber-400
                                                          Color(0xFFF97316), // orange-500
                                                        ],
                                                      ),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 1.2,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withValues(alpha: 0.10),
                                                          blurRadius: 2,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // 4. Separate Floating AI Action Button (62x62px Glass Button with Crisp 1.8px Rim)
              Builder(
                builder: (context) {
                  final isAiActive = selectedIndex == 2;
                  final isPressed = _pressedIndex == 2;

                  return GestureDetector(
                    onTapDown: (_) => setState(() => _pressedIndex = 2),
                    onTapUp: (_) => setState(() => _pressedIndex = null),
                    onTapCancel: () => setState(() => _pressedIndex = null),
                    onTap: () => _onItemTapped(2, context),
                    child: AnimatedScale(
                      scale: isPressed ? 0.92 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOutCubic,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9999),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 62,
                            height: 62,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isAiActive
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF71E2E8),
                                        Color(0xFF2DBAC6),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : (isPressed
                                      ? LinearGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0.60),
                                            const Color(0xFFF1F5F9).withValues(alpha: 0.50),
                                          ],
                                        )
                                      : null),
                              color: isAiActive || isPressed
                                  ? null
                                  : (isDark
                                      ? const Color(0xFF0F172A).withValues(alpha: 0.45)
                                      : const Color(0xFFF1F5F9).withValues(alpha: 0.45)),
                              border: Border.all(
                                color: isAiActive || isPressed
                                    ? Colors.white.withValues(alpha: 0.92)
                                    : (isDark
                                        ? Colors.white.withValues(alpha: 0.35)
                                        : Colors.white.withValues(alpha: 0.85)),
                                width: isPressed ? 2.2 : 1.8,
                              ),
                              boxShadow: [
                                if (isAiActive)
                                  BoxShadow(
                                    color: const Color(0xFF2DBAC6).withValues(alpha: 0.55),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                    spreadRadius: -2,
                                  )
                                else if (isPressed)
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.60),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  )
                                else ...[
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withValues(alpha: 0.50)
                                        : const Color(0xFF334155).withValues(alpha: 0.14),
                                    blurRadius: 40,
                                    offset: const Offset(0, 18),
                                    spreadRadius: -6,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.95),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1.5),
                                  ),
                                ],
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                size: 24,
                                color: isAiActive
                                    ? Colors.white
                                    : (isPressed
                                        ? const Color(0xFF2DBAC6)
                                        : (isDark ? Colors.white : const Color(0xFF4B5563))),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
