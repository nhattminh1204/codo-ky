import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
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
    _NavItemData(icon: Icons.auto_awesome_outlined, selectedIcon: Icons.auto_awesome_rounded, label: 'Lịch trình', route: '/itinerary'),
    _NavItemData(icon: Icons.rate_review_outlined, selectedIcon: Icons.rate_review_rounded, label: 'Đánh giá', route: '/reviews'),
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/itinerary')) return 2;
    if (location.startsWith('/reviews')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    HapticFeedback.lightImpact();
    context.go(_items[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final mediaQuery = MediaQuery.of(context);
    
    // Exact Width inside margin (padding horizontal 16 x 2 = 32)
    final horizontalMargin = 16.0;
    final navWidth = mediaQuery.size.width - (horizontalMargin * 2);
    final itemWidth = navWidth / _items.length;
    
    // Active Center X relative to nav bar container
    final activeX = itemWidth * selectedIndex + itemWidth / 2;

    const double circleSize = 52.0;

    return Scaffold(
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 10),
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
                          color: const Color(0xFF18171C), // Deep Sleek Dark
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // 2. Floating Active Circle Button (Floating smoothly above the notch)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: activeX, end: activeX),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  builder: (context, currentX, child) {
                    return Positioned(
                      left: currentX - (circleSize / 2),
                      top: -12, // Floating slightly above the bar edge
                      child: Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFB81D35),
                              Color(0xFF9B1B30),
                              Color(0xFF7B0020),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF9B1B30).withValues(alpha: 0.5),
                              blurRadius: 12,
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

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onItemTapped(index, context),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Icon shown only when unselected
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
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFFFFD700) // Royal Gold Highlight
                                        : Colors.white.withValues(alpha: 0.5),
                                    fontSize: isSelected ? 12 : 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  ),
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

  const _NavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}
