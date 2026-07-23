import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class MainShellLayout extends StatefulWidget {
  final Widget child;

  const MainShellLayout({
    super.key,
    required this.child,
  });

  @override
  State<MainShellLayout> createState() => _MainShellLayoutState();
}

class _MainShellLayoutState extends State<MainShellLayout>
    with SingleTickerProviderStateMixin {
  late AnimationController _navAnimController;

  @override
  void initState() {
    super.initState();
    _navAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();
  }

  @override
  void dispose() {
    _navAnimController.dispose();
    super.dispose();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/itinerary')) return 2;
    if (location.startsWith('/review')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    HapticFeedback.lightImpact();
    switch (index) {
      case 0:
        context.go('/map');
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        context.go('/itinerary');
        break;
      case 3:
        context.go('/review');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _navAnimController,
          curve: Curves.easeOutCubic,
        )),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    index: 0,
                    selectedIndex: selectedIndex,
                    icon: Icons.map_outlined,
                    selectedIcon: Icons.map_rounded,
                    label: 'Bản đồ',
                    onTap: () => _onItemTapped(0, context),
                  ),
                  _NavItem(
                    index: 1,
                    selectedIndex: selectedIndex,
                    icon: Icons.explore_outlined,
                    selectedIcon: Icons.explore_rounded,
                    label: 'Khám phá',
                    onTap: () => _onItemTapped(1, context),
                  ),
                  _NavItem(
                    index: 2,
                    selectedIndex: selectedIndex,
                    icon: Icons.auto_awesome_outlined,
                    selectedIcon: Icons.auto_awesome_rounded,
                    label: 'Lịch trình',
                    onTap: () => _onItemTapped(2, context),
                  ),
                  _NavItem(
                    index: 3,
                    selectedIndex: selectedIndex,
                    icon: Icons.rate_review_outlined,
                    selectedIcon: Icons.rate_review_rounded,
                    label: 'Đánh giá',
                    onTap: () => _onItemTapped(3, context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isSelected => widget.index == widget.selectedIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: _isSelected ? 16 : 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: _isSelected
                ? const Color(0xFF9B1B30).withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isSelected
                ? Row(
                    key: const ValueKey('selected'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.selectedIcon,
                        color: const Color(0xFF9B1B30),
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: Color(0xFF9B1B30),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  )
                : Column(
                    key: ValueKey('unselected_${widget.index}'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon,
                        color: Colors.grey[500],
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
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
