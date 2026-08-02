import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:codoky/features/map/presentation/widgets/marker_constants.dart';

/// Functional state of a place marker
enum PlaceMarkerState {
  /// Default marker appearance
  defaultState,

  /// Marker is selected (scaled up with enhanced glow shadow)
  selected,

  /// Marker represents a saved place (displays heart badge)
  saved,

  /// Marker represents a featured place (displays star badge)
  featured,
}

/// Style variants supported by MapMarker system
enum MapMarkerStyle {
  /// 1. Gradient Vibrant Glow: Orange-yellow gradient (#FF5E36 → #FFAE33), 3px white border, orange glow shadow
  gradientVibrantGlow,

  /// 2. Glassmorphic Duotone: Dark transparent glass background, cyan border & icon (#06B6D4)
  glassmorphicDuotone,

  /// 3. 3D Playful Pop: Solid purple (#8B5CF6), hard 3D offset shadow (#5B21B6), white border
  playfulPop3D,
}

class PlaceMarker extends StatefulWidget {
  final String category;
  final PlaceMarkerState state;
  final bool isSelected;
  final bool isSaved;
  final bool isFeatured;
  final MapMarkerStyle? style;
  final bool enableFloat;
  final bool enablePulse;

  const PlaceMarker({
    super.key,
    required this.category,
    this.state = PlaceMarkerState.defaultState,
    this.isSelected = false,
    this.isSaved = false,
    this.isFeatured = false,
    this.style = MapMarkerStyle.gradientVibrantGlow,
    this.enableFloat = true,
    this.enablePulse = false,
  });

  @override
  State<PlaceMarker> createState() => _PlaceMarkerState();
}

class _PlaceMarkerState extends State<PlaceMarker> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _pulseOpacityAnimation;

  bool get _effectiveSelected => widget.isSelected || widget.state == PlaceMarkerState.selected;
  bool get _effectiveSaved => widget.isSaved || widget.state == PlaceMarkerState.saved;
  bool get _effectiveFeatured => widget.isFeatured || widget.state == PlaceMarkerState.featured;

  @override
  void initState() {
    super.initState();

    // Floating micro-animation (smooth up-down sine wave)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _floatAnimation = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.enableFloat) {
      _floatController.repeat(reverse: true);
    }

    // Pulse ring animation for highlight / new / selected markers
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.65).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );
    _pulseOpacityAnimation = Tween<double>(begin: 0.65, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );

    if (widget.enablePulse || _effectiveSelected || _effectiveFeatured) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(PlaceMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableFloat != oldWidget.enableFloat) {
      if (widget.enableFloat) {
        _floatController.repeat(reverse: true);
      } else {
        _floatController.stop();
        _floatController.reset();
      }
    }
    final wasSelected = oldWidget.isSelected || oldWidget.state == PlaceMarkerState.selected;
    final wasFeatured = oldWidget.isFeatured || oldWidget.state == PlaceMarkerState.featured;
    final isPulseActive = widget.enablePulse || _effectiveSelected || _effectiveFeatured;
    final wasPulseActive = oldWidget.enablePulse || wasSelected || wasFeatured;

    if (isPulseActive != wasPulseActive) {
      if (isPulseActive) {
        _pulseController.repeat();
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double markerSize = MarkerConstants.visibleSize;
    const double tailSize = 10.0;

    final selected = _effectiveSelected;
    final featured = _effectiveFeatured;
    final saved = _effectiveSaved;
    final isHighlighted = widget.enablePulse || selected || featured;

    return AnimatedScale(
      scale: selected ? MarkerConstants.selectedScale : 1.0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
      child: SizedBox(
        width: markerSize + 12.0,
        height: markerSize + 18.0,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // 1. Pulsing Aura Ring (if active/highlighted: Selected or Featured or enablePulse=true)
            if (isHighlighted)
              Positioned(
                top: 2,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: markerSize,
                        height: markerSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getAccentColor().withValues(alpha: _pulseOpacityAnimation.value),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // 2. Main Marker Body with Tail Pointer
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, widget.enableFloat ? _floatAnimation.value : 0),
                  child: child,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main rounded-2xl Square Container with Stack for Badges
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeInOutCubic,
                        width: markerSize,
                        height: markerSize,
                        decoration: _getMarkerDecoration(selected),
                        child: Center(
                          child: Icon(
                            _getCategoryIcon(widget.category),
                            color: _getIconColor(),
                            size: 24,
                          ),
                        ),
                      ),

                      // Featured Star Badge (Top-Left corner)
                      if (featured)
                        Positioned(
                          top: -3,
                          left: -3,
                          child: AnimatedOpacity(
                            opacity: featured ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeInOutCubic,
                            child: Container(
                              width: 17,
                              height: 17,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                                border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFF59E0B),
                                  size: 11,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Saved Heart Badge (Top-Right corner)
                      if (saved)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: AnimatedOpacity(
                            opacity: saved ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeInOutCubic,
                            child: Container(
                              width: 17,
                              height: 17,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                                border: Border.all(color: const Color(0xFFEF4444), width: 1.2),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.favorite_rounded,
                                  color: Color(0xFFEF4444),
                                  size: 10,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Diamond Tail Pin Pointer (45° rotated square)
                  Transform.translate(
                    offset: const Offset(0, -5),
                    child: Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: tailSize,
                        height: tailSize,
                        decoration: _getTailDecoration(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  MapMarkerStyle get _activeStyle => widget.style ?? MapMarkerStyle.gradientVibrantGlow;

  /// Color accent helper
  Color _getAccentColor() {
    switch (_activeStyle) {
      case MapMarkerStyle.gradientVibrantGlow:
        return const Color(0xFFFF5E36);
      case MapMarkerStyle.glassmorphicDuotone:
        return const Color(0xFF06B6D4);
      case MapMarkerStyle.playfulPop3D:
        return const Color(0xFF8B5CF6);
    }
  }

  /// Main Marker Container Decoration
  BoxDecoration _getMarkerDecoration(bool isSelected) {
    switch (_activeStyle) {
      case MapMarkerStyle.gradientVibrantGlow:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF5E36), Color(0xFFFFAE33)],
          ),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5E36).withValues(alpha: isSelected ? 0.65 : 0.45),
              blurRadius: isSelected ? 18 : 10,
              spreadRadius: isSelected ? 2.5 : 1,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case MapMarkerStyle.glassmorphicDuotone:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF0F172A).withValues(alpha: 0.75), // Glass dark backdrop
          border: Border.all(color: const Color(0xFF06B6D4), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06B6D4).withValues(alpha: isSelected ? 0.5 : 0.3),
              blurRadius: isSelected ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case MapMarkerStyle.playfulPop3D:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF8B5CF6),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B21B6),
              offset: const Offset(0, 5),
              blurRadius: isSelected ? 8 : 0, // 3D offset shadow with optional glow
            ),
          ],
        );
    }
  }

  /// Tail Pointer Decoration (Matches marker body styling)
  BoxDecoration _getTailDecoration() {
    switch (_activeStyle) {
      case MapMarkerStyle.gradientVibrantGlow:
        return const BoxDecoration(
          color: Color(0xFFFFAE33), // Matches bottom corner of gradient
        );

      case MapMarkerStyle.glassmorphicDuotone:
        return BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.85),
          border: const Border(
            bottom: BorderSide(color: Color(0xFF06B6D4), width: 2),
            right: BorderSide(color: Color(0xFF06B6D4), width: 2),
          ),
        );

      case MapMarkerStyle.playfulPop3D:
        return const BoxDecoration(
          color: Color(0xFF5B21B6), // Matches 3D shadow depth
        );
    }
  }

  /// Icon Color depending on style
  Color _getIconColor() {
    switch (_activeStyle) {
      case MapMarkerStyle.glassmorphicDuotone:
        return const Color(0xFF06B6D4);
      case MapMarkerStyle.gradientVibrantGlow:
      case MapMarkerStyle.playfulPop3D:
        return Colors.white;
    }
  }

  /// Lucide-style Line Icon Mapping for Categories
  IconData _getCategoryIcon(String category) {
    final cat = category.toLowerCase().trim();
    if (cat.contains('food') || cat.contains('restaurant') || cat.contains('ăn') || cat.contains('ẩm thực')) {
      return Icons.restaurant_rounded;
    }
    if (cat.contains('cafe') || cat.contains('cà phê') || cat.contains('trà')) {
      return Icons.local_cafe_rounded;
    }
    if (cat.contains('attraction') || cat.contains('di tích') || cat.contains('lịch sử') || cat.contains('landmark')) {
      return Icons.account_balance_rounded;
    }
    if (cat.contains('shop') || cat.contains('mua sắm') || cat.contains('chợ')) {
      return Icons.shopping_bag_rounded;
    }
    if (cat.contains('saved') || cat.contains('đã lưu') || cat.contains('yêu thích')) {
      return Icons.auto_awesome_rounded;
    }
    if (cat.contains('hotel') || cat.contains('khách sạn') || cat.contains('lưu trú')) {
      return Icons.bed_rounded;
    }
    if (cat.contains('photo') || cat.contains('checkin') || cat.contains('sống ảo') || cat.contains('nhiếp ảnh')) {
      return Icons.camera_alt_rounded;
    }
    if (cat.contains('entertainment') || cat.contains('giải trí') || cat.contains('vui chơi')) {
      return Icons.confirmation_number_rounded;
    }
    if (cat.contains('temple') || cat.contains('chùa') || cat.contains('tâm linh')) {
      return Icons.temple_buddhist_rounded;
    }
    if (cat.contains('tomb') || cat.contains('lăng')) {
      return Icons.fort_rounded;
    }
    return Icons.place_rounded;
  }
}