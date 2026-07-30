import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/motion.dart';

/// 1. GRADIENT CHO THANH NAV CAPSULE (DẠNG RỘNG)
SweepGradient buildNavGlassBorderGradient({
  required Color greyBorder,
  required Color whiteBorder,
  required Color fadedBorder,
  required double width,
  required double height,
}) {
  final double r = height / 2;
  final double halfW = width / 2;
  final double halfH = height / 2;

  final double cornerDeg = (halfW > r)
      ? math.atan(halfH / (halfW - r)) * 180 / math.pi
      : 45.0;

  const double spread = 3.5;

  double n(double deg) => (deg % 360) / 360;

  final double brIn = n(cornerDeg - spread);
  final double br = n(cornerDeg);
  final double brOut = n(cornerDeg + spread);

  final double blIn = n(180 - cornerDeg - spread);
  final double bl = n(180 - cornerDeg);
  final double blOut = n(180 - cornerDeg + spread);

  final double tlIn = n(180 + cornerDeg - spread);
  final double tl = n(180 + cornerDeg);
  final double tlOut = n(180 + cornerDeg + spread);

  final double trIn = n(360 - cornerDeg - spread);
  final double tr = n(360 - cornerDeg);
  final double trOut = n(360 - cornerDeg + spread);

  return SweepGradient(
    center: Alignment.center,
    startAngle: 0.0,
    endAngle: math.pi * 2,
    colors: [
      fadedBorder,
      greyBorder,
      fadedBorder,
      fadedBorder,
      whiteBorder,
      fadedBorder,
      fadedBorder,
      greyBorder,
      fadedBorder,
      fadedBorder,
      whiteBorder,
      fadedBorder,
      fadedBorder,
    ],
    stops: [
      0.0,
      brIn,
      br,
      brOut,
      blIn,
      bl,
      blOut,
      tlIn,
      tl,
      tlOut,
      trIn,
      tr,
      trOut,
    ],
  );
}

/// 2. GRADIENT CHO NÚT AI TRÒN (TỶ LỆ 1:1)
LinearGradient buildAIButtonGlassBorderGradient({
  required Color greyBorder,
  required Color whiteBorder,
  required Color fadedBorder,
}) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      greyBorder,
      whiteBorder,
      fadedBorder,
      whiteBorder,
      greyBorder,
    ],
    stops: const [0.0, 0.30, 0.50, 0.70, 1.0],
  );
}

class _DockColorPalette {
  final String name;
  final List<Color> gradientColors;
  final Color shadowColor;
  final Color activeIconLight;
  final Color activeIconDark;

  const _DockColorPalette({
    required this.name,
    required this.gradientColors,
    required this.shadowColor,
    required this.activeIconLight,
    required this.activeIconDark,
  });
}

const _dockPalettes = [
  _DockColorPalette(
    name: 'Emerald Mint 🍃',
    gradientColors: [Color(0xFF6EE7B7), Color(0xFF10B981)],
    shadowColor: Color(0xFF10B981),
    activeIconLight: Color(0xFF059669),
    activeIconDark: Color(0xFF6EE7B7),
  ),
  _DockColorPalette(
    name: 'Electric Cyan ⚡',
    gradientColors: [Color(0xFF71E2E8), Color(0xFF2DBAC6)],
    shadowColor: Color(0xFF2DBAC6),
    activeIconLight: Color(0xFF0284C7),
    activeIconDark: Color(0xFF38BDF8),
  ),
  _DockColorPalette(
    name: 'Deep Emerald 🟢',
    gradientColors: [Color(0xFF34D399), Color(0xFF059669)],
    shadowColor: Color(0xFF059669),
    activeIconLight: Color(0xFF059669),
    activeIconDark: Color(0xFF34D399),
  ),
];

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

class MainShellLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellLayout({super.key, required this.navigationShell});

  @override
  State<MainShellLayout> createState() => _MainShellLayoutState();
}

class _MainShellLayoutState extends State<MainShellLayout> {
  int _paletteIndex = 0; // 0: Electric Cyan, 1: Emerald Jade, 2: Eco Bamboo

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
        return 0; // Bản đồ
      case 1:
        return 1; // Khám phá
      case 3:
        return 2; // Lịch trình
      case 4:
        return 3; // Hồ sơ
      case 2:
      default:
        return -1; // AI Assistant
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = widget.navigationShell.currentIndex;
    final activeIndex = _getActiveTabIndex(selectedIndex);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAiActive = selectedIndex == 2;
    final currentPalette = _dockPalettes[_paletteIndex];

    final greyBorder = isDark
        ? const Color(0xFF475569).withValues(alpha: 0.50)
        : const Color(0xFF64748B).withValues(alpha: 0.60);
    final whiteBorder = Colors.white.withValues(alpha: isDark ? 0.70 : 0.90);
    final fadedBorder = Colors.white.withValues(alpha: isDark ? 0.20 : 0.40);

    final aiGlassGradient = buildAIButtonGlassBorderGradient(
      greyBorder: greyBorder,
      whiteBorder: whiteBorder,
      fadedBorder: fadedBorder,
    );

    final navTabs = const [
      _NavItemData(
        icon: Icons.map_outlined,
        selectedIcon: Icons.map_rounded,
        label: 'Bản đồ',
        route: '/map',
        branchIndex: 0,
      ),
      _NavItemData(
        icon: Icons.explore_outlined,
        selectedIcon: Icons.explore_rounded,
        label: 'Khám phá',
        route: '/explore',
        branchIndex: 1,
      ),
      _NavItemData(
        icon: Icons.calendar_today_outlined,
        selectedIcon: Icons.calendar_today_rounded,
        label: 'Lịch trình',
        route: '/itinerary',
        branchIndex: 3,
        hasBadge: true,
      ),
      _NavItemData(
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        label: 'Hồ sơ',
        route: '/profile',
        branchIndex: 4,
      ),
    ];

    const double navHeight = 62;

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: widget.navigationShell,
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ── Quick Dock Theme Palette Switcher ──────────────────────────
              Padding(
                padding: const EdgeInsets.only(right: 4, bottom: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.35)
                            : Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.60),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_dockPalettes.length, (i) {
                          final p = _dockPalettes[i];
                          final isSelected = _paletteIndex == i;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _paletteIndex = i);
                            },
                            child: Tooltip(
                              message: p.name,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 1.8,
                                  ),
                                ),
                                child: Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: p.gradientColors,
                                    ),
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

              // ── Dock Row (Capsule + AI Button) ─────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ─── 1. Floating Glass Navigation Capsule ──────────────────
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, outerConstraints) {
                        final navGlassGradient = buildNavGlassBorderGradient(
                          greyBorder: greyBorder,
                          whiteBorder: whiteBorder,
                          fadedBorder: fadedBorder,
                          width: outerConstraints.maxWidth,
                          height: navHeight,
                        );

                        return Container(
                          height: navHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9999),
                            gradient: navGlassGradient,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(2.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9999),
                            clipBehavior: Clip.antiAlias,
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9999),
                                  color: isDark
                                      ? const Color(0xFF1E293B).withValues(alpha: 0.10)
                                      : Colors.white.withValues(alpha: 0.15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final tabWidth =
                                          constraints.maxWidth / navTabs.length;

                                      return Stack(
                                        alignment: Alignment.centerLeft,
                                        children: [
                                          // ── Active Pill Indicator ──
                                          if (activeIndex != -1)
                                            AnimatedPositioned(
                                              duration: AppMotion.standard,
                                              curve: const Cubic(
                                                0.34,
                                                1.20,
                                                0.64,
                                                1.0,
                                              ),
                                              left: activeIndex * tabWidth,
                                              top: 0,
                                              bottom: 0,
                                              width: tabWidth,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(9999),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(
                                                    sigmaX: 16,
                                                    sigmaY: 16,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          currentPalette
                                                              .gradientColors[0]
                                                              .withValues(alpha: 0.75),
                                                          currentPalette
                                                              .gradientColors[1]
                                                              .withValues(alpha: 0.85),
                                                        ],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(9999),
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withValues(alpha: 0.85),
                                                        width: 1.2,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: currentPalette
                                                              .shadowColor
                                                              .withValues(alpha: 0.45),
                                                          blurRadius: 18,
                                                          offset: const Offset(0, 6),
                                                          spreadRadius: -2,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        Positioned.fill(
                                                          child: DecoratedBox(
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      9999),
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  Colors.white
                                                                      .withValues(
                                                                          alpha: 0.55),
                                                                  Colors.white
                                                                      .withValues(
                                                                          alpha: 0.0),
                                                                ],
                                                                stops: const [0.0, 0.55],
                                                                begin: Alignment
                                                                    .topCenter,
                                                                end: Alignment
                                                                    .bottomCenter,
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

                                          // ── Tab Buttons ──
                                          Row(
                                            children: List.generate(navTabs.length,
                                                (index) {
                                              final item = navTabs[index];
                                              final isSelected = activeIndex == index;

                                              return Expanded(
                                                child: _NavItemButton(
                                                  item: item,
                                                  isSelected: isSelected,
                                                  isDark: isDark,
                                                  onTap: () => _onItemTapped(
                                                    item.branchIndex,
                                                    context,
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
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ─── 2. Floating AI Circular Glass Button ──────────────────
                  _AiButtonWidget(
                    isAiActive: isAiActive,
                    isDark: isDark,
                    palette: currentPalette,
                    aiGlassGradient: aiGlassGradient,
                    onTap: () => _onItemTapped(2, context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nút Tab đơn lẻ
class _NavItemButton extends StatefulWidget {
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
  State<_NavItemButton> createState() => _NavItemButtonState();
}

class _NavItemButtonState extends State<_NavItemButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed != value) {
      setState(() {
        _isPressed = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.item.label,
      selected: widget.isSelected,
      button: true,
      child: Tooltip(
        message: widget.item.label,
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: _isPressed ? 0.88 : 1.0,
            duration: AppMotion.micro,
            curve: AppMotion.standardCurve,
            child: SizedBox(
              height: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isPressed)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9999),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(9999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.50),
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        widget.isSelected
                            ? widget.item.selectedIcon
                            : widget.item.icon,
                        size: 26,
                        color: widget.isSelected
                            ? Colors.white
                            : (widget.isDark
                                  ? Colors.white.withValues(alpha: 0.75)
                                  : const Color(0xFF64748B)),
                      ),
                      if (widget.item.hasBadge)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: widget.isSelected
                                  ? Colors.white
                                  : const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
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

/// Nút AI Tròn Nội bộ
class _AiButtonWidget extends StatefulWidget {
  final bool isAiActive;
  final bool isDark;
  final _DockColorPalette palette;
  final LinearGradient aiGlassGradient;
  final VoidCallback onTap;

  const _AiButtonWidget({
    required this.isAiActive,
    required this.isDark,
    required this.palette,
    required this.aiGlassGradient,
    required this.onTap,
  });

  @override
  State<_AiButtonWidget> createState() => _AiButtonWidgetState();
}

class _AiButtonWidgetState extends State<_AiButtonWidget> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed != value) {
      setState(() {
        _isPressed = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Trợ lý AI CodoKy',
      selected: widget.isAiActive,
      button: true,
      child: Tooltip(
        message: 'Trợ lý AI CodoKy',
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isPressed ? 0.88 : 1.0,
            duration: AppMotion.micro,
            curve: AppMotion.standardCurve,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.isAiActive
                    ? LinearGradient(
                        colors: widget.palette.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : widget.aiGlassGradient,
                boxShadow: widget.isAiActive
                    ? [
                        BoxShadow(
                          color: widget.palette.shadowColor.withValues(alpha: 0.45),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              padding: const EdgeInsets.all(2.0),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isAiActive
                          ? Colors.transparent
                          : (widget.isDark
                                ? const Color(0xFF0F172A).withValues(alpha: 0.12)
                                : Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 28,
                        color: widget.isAiActive
                            ? Colors.white
                            : (widget.isDark
                                  ? widget.palette.activeIconDark
                                  : widget.palette.activeIconLight),
                      ),
                    ),
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
