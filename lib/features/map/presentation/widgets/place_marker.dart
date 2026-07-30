import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:codoky/core/theme/motion.dart';

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
  final bool isSelected;
  final MapMarkerStyle? style;
  final bool enableFloat;
  final bool enablePulse;

  const PlaceMarker({
    super.key,
    required this.category,
    this.isSelected = false,
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

    if (widget.enablePulse || widget.isSelected) {
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
    if ((widget.enablePulse || widget.isSelected) != (oldWidget.enablePulse || oldWidget.isSelected)) {
      if (widget.enablePulse || widget.isSelected) {
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
    const double markerSize = 42.0;
    const double tailSize = 10.0;

    final isHighlighted = widget.isSelected || widget.enablePulse;

    return AnimatedScale(
      scale: widget.isSelected ? 1.12 : 1.0,
      duration: AppMotion.standard,
      curve: widget.isSelected ? AppMotion.springyCurve : AppMotion.standardCurve,
      child: SizedBox(
        width: 52.0,
        height: 58.0,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            // 1. Pulsing Aura Ring (if active/highlighted)
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
                  // Main rounded-2xl Square Container
                  Container(
                    width: markerSize,
                    height: markerSize,
                    decoration: _getMarkerDecoration(),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(widget.category),
                        color: _getIconColor(),
                        size: 22,
                      ),
                    ),
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
  BoxDecoration _getMarkerDecoration() {
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
              color: const Color(0xFFFF5E36).withValues(alpha: widget.isSelected ? 0.65 : 0.45),
              blurRadius: widget.isSelected ? 16 : 10,
              spreadRadius: widget.isSelected ? 2 : 1,
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
              color: const Color(0xFF06B6D4).withValues(alpha: widget.isSelected ? 0.5 : 0.3),
              blurRadius: widget.isSelected ? 14 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        );

      case MapMarkerStyle.playfulPop3D:
        return BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF8B5CF6),
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF5B21B6),
              offset: Offset(0, 5),
              blurRadius: 0, // Hard 3D offset shadow
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