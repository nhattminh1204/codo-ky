import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';
import 'package:codoky/core/config/theme/app_theme.dart';
import 'curved_nav_clipper.dart';

class MainShellLayout extends StatefulWidget {
  final Widget child;

  const MainShellLayout({
    super.key,
    required this.child,
  });

  @override
  State<MainShellLayout> createState() => _MainShellLayoutState();
}

class _MainShellLayoutState extends State<MainShellLayout> {
  final List<_NavItemData> _items = const [
    _NavItemData(icon: Icons.map_outlined, selectedIcon: Icons.map_rounded, label: 'Bản đồ', route: '/map'),
    _NavItemData(icon: Icons.explore_outlined, selectedIcon: Icons.explore_rounded, label: 'Khám phá', route: '/explore'),
    _NavItemData(icon: Icons.add, selectedIcon: Icons.add, label: '', route: '/itinerary/setup', isCenterAction: true),
    _NavItemData(icon: Icons.calendar_today_outlined, selectedIcon: Icons.calendar_today_rounded, label: 'Lịch trình', route: '/itinerary'),
    _NavItemData(icon: Icons.person_outline, selectedIcon: Icons.person_rounded, label: 'Hồ sơ', route: '/profile'),
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/itinerary')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    HapticFeedback.lightImpact();
    final item = _items[index];
    if (item.isCenterAction) {
      context.push(item.route);
    } else {
      context.go(item.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final mediaQuery = MediaQuery.of(context);
    final currentPath = GoRouterState.of(context).uri.path;
    
    const horizontalMargin = 16.0;
    final navWidth = mediaQuery.size.width - (horizontalMargin * 2);
    final itemWidth = navWidth / _items.length;
    final activeX = itemWidth * selectedIndex + itemWidth / 2;
    const double circleSize = 52.0;

    return Scaffold(
      extendBody: true,
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey(currentPath),
          child: widget.child,
        ),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 10),
          child: SizedBox(
            height: 68,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Curved Background Bar
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: activeX, end: activeX),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  builder: (context, currentX, child) {
                    return ClipPath(
                      clipper: CurvedNavClipper(
                        activeX: currentX,
                        dipRadius: 36,
                        dipDepth: 26,
                      ),
                      child: Container(
                        height: 68,
                        decoration: BoxDecoration(
                          color: const Color(0xFF18171C),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppShadows.floating,
                        ),
                      ),
                    );
                  },
                ),

                // 2. Floating Active Circle Button
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: activeX, end: activeX),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  builder: (context, currentX, child) {
                    return Positioned(
                      left: currentX - (circleSize / 2),
                      top: -12,
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF5E62), Color(0xFFFF9966)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF5E62).withValues(alpha: 0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _items[selectedIndex].selectedIcon,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // 3. Navigation Bar Icons & Text Labels
                Positioned.fill(
                  child: Row(
                    children: List.generate(_items.length, (index) {
                      final isSelected = index == selectedIndex;
                      final item = _items[index];

                      if (item.isCenterAction) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _onItemTapped(index, context),
                            behavior: HitTestBehavior.opaque,
                            child: const Center(
                              child: Icon(
                                Icons.add_circle_rounded,
                                color: Colors.transparent,
                                size: 28,
                              ),
                            ),
                          ),
                        );
                      }

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onItemTapped(index, context),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!isSelected)
                                Icon(
                                  item.icon,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  size: 22,
                                )
                              else
                                const SizedBox(height: 22),
                              
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.label,
                                      style: TextStyle(
                                        color: isSelected
                                            ? const Color(0xFFFF7A00)
                                            : Colors.white.withValues(alpha: 0.5),
                                        fontSize: isSelected ? 12 : 11,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(height: 2),
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFF7A00),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
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
