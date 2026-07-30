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

class _MainShellLayoutState extends State<MainShellLayout> {
  int? _pressedIndex;

  void _onItemTapped(int index, BuildContext context) {
    HapticFeedback.lightImpact();
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = widget.navigationShell.currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter items: 0: Map, 1: Explore, 2: Itinerary, 3: Profile
    // (Center action index 2 '/itinerary/setup' mapped to right floating badge button)
    final navTabs = [
      const _NavItemData(icon: Icons.map_outlined, selectedIcon: Icons.map_rounded, label: 'Bản đồ', route: '/map', branchIndex: 0),
      const _NavItemData(icon: Icons.explore_outlined, selectedIcon: Icons.explore_rounded, label: 'Khám phá', route: '/explore', branchIndex: 1),
      const _NavItemData(icon: Icons.calendar_today_outlined, selectedIcon: Icons.calendar_today_rounded, label: 'Lịch trình', route: '/itinerary', branchIndex: 3),
      const _NavItemData(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Hồ sơ', route: '/profile', branchIndex: 4),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: widget.navigationShell,
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
          child: Row(
            children: [
              // 1. Main Floating Pill Navigation Bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E222A).withValues(alpha: 0.82)
                            : Colors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.75),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: navTabs.map((item) {
                          final isSelected = selectedIndex == item.branchIndex;
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
                                child: Center(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOutCubic,
                                    padding: isSelected
                                        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                                        : const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: isSelected
                                        ? BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF38BDF8), // Cyan / Sky Blue
                                                Color(0xFF2DD4BF), // Teal Accent
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(24),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF2DD4BF).withValues(alpha: 0.45),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          )
                                        : null,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isSelected ? item.selectedIcon : item.icon,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                                          size: isSelected ? 22 : 21,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // 2. Right Floating Action Badge Button (Tạo Lịch trình / AI Plan)
              GestureDetector(
                onTapDown: (_) => setState(() => _pressedIndex = 2),
                onTapUp: (_) => setState(() => _pressedIndex = null),
                onTapCancel: () => setState(() => _pressedIndex = null),
                onTap: () => _onItemTapped(2, context),
                child: AnimatedScale(
                  scale: _pressedIndex == 2 ? 0.92 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE0F2FE),
                          Color(0xFFCCFBF1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: const Color(0xFF2DD4BF).withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2DD4BF).withValues(alpha: 0.30),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF0EA5E9),
                                Color(0xFF0D9488),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
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
