import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/motion.dart';

/// 1. GRADIENT CHO THANH NAV CAPSULE (DẠNG RỘNG)
/// Tính TOÁN ĐỘNG góc bo thật của capsule dựa trên width/height thực tế,
/// để đảm bảo vệt màu xám/trắng luôn nằm đúng tại góc bo (không còn hardcode
/// theo một tỉ lệ cố định như trước).
///
/// - Góc DƯỚI-PHẢI & TRÊN-TRÁI: XÁM (đường chéo 45° "trên trái - dưới phải")
/// - Góc DƯỚI-TRÁI & TRÊN-PHẢI: TRẮNG SÁNG
SweepGradient buildNavGlassBorderGradient({
  required Color greyBorder,
  required Color whiteBorder,
  required Color fadedBorder,
  required double width,
  required double height,
}) {
  final double r = height / 2; // bán kính bo 2 đầu capsule (stadium shape)
  final double halfW = width / 2;
  final double halfH = height / 2;

  // Góc thực (độ) từ tâm hình đến điểm bo góc của capsule.
  // Nếu halfW <= r (capsule quá ngắn / gần tròn), fallback về 45°.
  final double cornerDeg = (halfW > r)
      ? math.atan(halfH / (halfW - r)) * 180 / math.pi
      : 45.0;

  const double spread = 3.5; // độ rộng vệt màu quanh mỗi góc, chỉnh tuỳ ý

  double n(double deg) => (deg % 360) / 360;

  final double brIn = n(cornerDeg - spread);
  final double br = n(cornerDeg); // GÓC DƯỚI-PHẢI (xám)
  final double brOut = n(cornerDeg + spread);

  final double blIn = n(180 - cornerDeg - spread);
  final double bl = n(180 - cornerDeg); // GÓC DƯỚI-TRÁI (trắng)
  final double blOut = n(180 - cornerDeg + spread);

  final double tlIn = n(180 + cornerDeg - spread);
  final double tl = n(180 + cornerDeg); // GÓC TRÊN-TRÁI (xám)
  final double tlOut = n(180 + cornerDeg + spread);

  final double trIn = n(360 - cornerDeg - spread);
  final double tr = n(360 - cornerDeg); // GÓC TRÊN-PHẢI (trắng)
  final double trOut = n(360 - cornerDeg + spread);

  return SweepGradient(
    center: Alignment.center,
    startAngle: 0.0,
    endAngle: math.pi * 2,
    colors: [
      fadedBorder, // 0.00: Khép vòng seamless
      greyBorder, // GÓC BO DƯỚI - PHẢI: XÁM
      fadedBorder,
      fadedBorder,
      whiteBorder, // GÓC BO DƯỚI - TRÁI: TRẮNG SÁNG
      fadedBorder,
      fadedBorder,
      greyBorder, // GÓC BO TRÊN - TRÁI: XÁM
      fadedBorder,
      fadedBorder,
      whiteBorder, // GÓC BO TRÊN - PHẢI: TRẮNG SÁNG
      fadedBorder,
      fadedBorder, // 1.00: Khép vòng 100%
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
/// Nút AI dạng tròn hình học 1:1 dùng LinearGradient đường chéo 45° đối xứng chuẩn góc.
LinearGradient buildAIButtonGlassBorderGradient({
  required Color greyBorder,
  required Color whiteBorder,
  required Color fadedBorder,
}) {
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      greyBorder, // Góc TRÊN - TRÁI (XÁM)
      whiteBorder, // Góc TRÊN - PHẢI (TRẮNG SÁNG)
      fadedBorder, // Tâm giữa (MỜ)
      whiteBorder, // Góc DƯỚI - TRÁI (TRẮNG SÁNG)
      greyBorder, // Góc DƯỚI - PHẢI (XÁM)
    ],
    stops: const [0.0, 0.30, 0.50, 0.70, 1.0],
  );
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

class MainShellLayout extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellLayout({super.key, required this.navigationShell});

  @override
  State<MainShellLayout> createState() => _MainShellLayoutState();
}

class _MainShellLayoutState extends State<MainShellLayout> {
  void _onItemTapped(int index, BuildContext context) {
    HapticFeedback.lightImpact();
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  /// Ánh xạ branchIndex sang vi trí Tab hiển thị trong thanh Capsule.
  /// Nếu chọn branchIndex = 2 (Nút Trợ Lý AI), trả về -1 để ẩn Active Pill trong Capsule.
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
        return -1; // AI Assistant (Đang chọn nút AI tách biệt)
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = widget.navigationShell.currentIndex;
    final activeIndex = _getActiveTabIndex(selectedIndex);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAiActive = selectedIndex == 2;

    // Màu viền gradient dùng chung cho cả nav capsule và AI button
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
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── 1. Floating Glass Navigation Capsule ────────────────────────
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
                                            borderRadius: BorderRadius.circular(9999),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                sigmaX: 16,
                                                sigmaY: 16,
                                              ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      const Color(0xFF71E2E8)
                                                          .withValues(alpha: 0.75),
                                                      const Color(0xFF2DBAC6)
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
                                                      color: const Color(0xFF2DBAC6)
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
                                                              BorderRadius.circular(9999),
                                                          gradient: LinearGradient(
                                                            colors: [
                                                              Colors.white
                                                                  .withValues(alpha: 0.55),
                                                              Colors.white
                                                                  .withValues(alpha: 0.0),
                                                            ],
                                                            stops: const [0.0, 0.55],
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

                                      // ── Tab Buttons ──
                                      Row(
                                        children: List.generate(navTabs.length, (index) {
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

              // ─── 2. Floating AI Circular Glass Button ────────────────────────
              _AiButtonWidget(
                isAiActive: isAiActive,
                isDark: isDark,
                aiGlassGradient: aiGlassGradient,
                onTap: () => _onItemTapped(2, context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nút Tab đơn lẻ giúp tự quản lý hiệu ứng press state cục bộ (không làm rebuild toàn bộ Shell)
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

/// Nút AI Tròn Nội bộ quản lý hiệu ứng press state độc lập
class _AiButtonWidget extends StatefulWidget {
  final bool isAiActive;
  final bool isDark;
  final LinearGradient aiGlassGradient;
  final VoidCallback onTap;

  const _AiButtonWidget({
    required this.isAiActive,
    required this.isDark,
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
                    ? const LinearGradient(
                        colors: [Color(0xFF71E2E8), Color(0xFF2DBAC6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : widget.aiGlassGradient,
                boxShadow: widget.isAiActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2DBAC6).withValues(alpha: 0.45),
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
                                  ? const Color(0xFF38BDF8)
                                  : const Color(0xFF0284C7)),
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
