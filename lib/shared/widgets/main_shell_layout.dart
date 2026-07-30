import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/core/config/theme/app_theme.dart';

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

  final List<_NavItemData> _items = const [
    _NavItemData(icon: Icons.map_outlined, selectedIcon: Icons.map_rounded, label: 'Bản đồ', route: '/map'),
    _NavItemData(icon: Icons.explore_outlined, selectedIcon: Icons.explore_rounded, label: 'Khám phá', route: '/explore'),
    _NavItemData(icon: Icons.add_rounded, selectedIcon: Icons.add_rounded, label: '', route: '/itinerary/setup', isCenterAction: true),
    _NavItemData(icon: Icons.calendar_today_outlined, selectedIcon: Icons.calendar_today_rounded, label: 'Lịch trình', route: '/itinerary'),
    _NavItemData(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Hồ sơ', route: '/profile'),
  ];

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

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: widget.navigationShell,
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E222A).withValues(alpha: 0.78)
                      : Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.08),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(_items.length, (index) {
                    final isSelected = index == selectedIndex;
                    final isPressed = _pressedIndex == index;
                    final item = _items[index];

                    if (item.isCenterAction) {
                      return Expanded(
                        child: GestureDetector(
                          onTapDown: (_) => setState(() => _pressedIndex = index),
                          onTapUp: (_) => setState(() => _pressedIndex = null),
                          onTapCancel: () => setState(() => _pressedIndex = null),
                          onTap: () => _onItemTapped(index, context),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedScale(
                            scale: isPressed ? AppMotion.pressScale : 1.0,
                            duration: AppMotion.snappy,
                            curve: AppMotion.standardCurve,
                            child: Center(
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: GestureDetector(
                        onTapDown: (_) => setState(() => _pressedIndex = index),
                        onTapUp: (_) => setState(() => _pressedIndex = null),
                        onTapCancel: () => setState(() => _pressedIndex = null),
                        onTap: () => _onItemTapped(index, context),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedScale(
                          scale: isPressed ? AppMotion.pressScale : 1.0,
                          duration: AppMotion.snappy,
                          curve: AppMotion.standardCurve,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: isSelected
                                ? BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(16),
                                  )
                                : null,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSelected ? item.selectedIcon : item.icon,
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark ? Colors.white70 : AppColors.textSecondary),
                                  size: 22,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark ? Colors.white70 : AppColors.textSecondary),
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
              ),
            ),
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
  final bool isCenterAction;

  const _NavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
    this.isCenterAction = false,
  });
}
