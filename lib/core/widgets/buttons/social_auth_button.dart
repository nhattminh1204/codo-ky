import 'package:flutter/material.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';

enum SocialType { google, apple, phone }

class SocialAuthButton extends StatefulWidget {
  final SocialType type;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.type,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<SocialAuthButton> createState() => _SocialAuthButtonState();
}

class _SocialAuthButtonState extends State<SocialAuthButton> with SingleTickerProviderStateMixin {
  AnimationController? _pressController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pressController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController!, curve: Curves.easeInOut),
    );
    _isInitialized = true;
  }

  @override
  void reassemble() {
    super.reassemble();
    _setupAnimations();
  }

  @override
  void dispose() {
    _pressController?.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isLoading) {
      _pressController?.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isLoading) {
      _pressController?.reverse();
    }
  }

  void _onTapCancel() {
    if (!widget.isLoading) {
      _pressController?.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      _setupAnimations();
    }

    final isGoogle = widget.type == SocialType.google;
    final isApple = widget.type == SocialType.apple;

    final String label;
    final Color backgroundColor;
    final Color textColor;
    final Border? border;
    final List<BoxShadow> shadows;
    final l10n = context.l10n;

    if (isGoogle) {
      label = l10n.continueWithGoogle;
      backgroundColor = Colors.white;
      textColor = const Color(0xFF2C2C2C);
      border = Border.all(color: Colors.black.withValues(alpha: 0.08), width: 1);
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.04),
          blurRadius: _isHovered ? 20 : 14,
          offset: const Offset(0, 4),
        ),
      ];
    } else if (isApple) {
      label = l10n.continueWithApple;
      backgroundColor = const Color(0xFF000000);
      textColor = Colors.white;
      border = null;
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: _isHovered ? 0.25 : 0.15),
          blurRadius: _isHovered ? 20 : 12,
          offset: const Offset(0, 6),
        ),
      ];
    } else {
      label = l10n.continueWithPhone;
      backgroundColor = const Color(0xFFFFFDF9);
      textColor = const Color(0xFF3D352E);
      border = Border.all(color: const Color(0xFFC89B3C).withValues(alpha: 0.40), width: 1.2);
      shadows = [
        BoxShadow(
          color: const Color(0xFFC89B3C).withValues(alpha: _isHovered ? 0.12 : 0.06),
          blurRadius: _isHovered ? 16 : 10,
          offset: const Offset(0, 3),
        ),
      ];
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.isLoading ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(28), // M3 Expressive pill shape
              border: border,
              boxShadow: shadows,
            ),
            child: widget.isLoading
                ? Center(
                    child: SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isApple ? Colors.white : const Color(0xFFA61E2D),
                        ),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Social Icon
                      if (isGoogle)
                        const _GoogleIcon(size: 22)
                      else if (isApple)
                        const Icon(
                          Icons.apple,
                          size: 25,
                          color: Colors.white,
                        )
                      else
                        const Icon(
                          Icons.phone_iphone_rounded,
                          size: 22,
                          color: Color(0xFF8B1522),
                        ),

                      const SizedBox(width: 12),

                      // Label (clean, centered, no right chevron)
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: textColor,
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

/// Official Google G Multi-color Logo Vector Painter
class _GoogleIcon extends StatelessWidget {
  final double size;

  const _GoogleIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: const _GoogleIconPainter(),
      ),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  const _GoogleIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 48.0;
    canvas.scale(scale, scale);

    // 1. Red Top Arc (#EA4335)
    final redPath = Path()
      ..moveTo(24, 9.5)
      ..cubicTo(27.54, 9.5, 30.71, 10.72, 33.21, 13.1)
      ..relativeLineTo(6.85, -6.85)
      ..cubicTo(35.9, 2.38, 30.47, 0, 24, 0)
      ..cubicTo(14.62, 0, 6.51, 5.38, 2.56, 13.22)
      ..relativeLineTo(7.98, 6.19)
      ..cubicTo(12.43, 13.72, 17.74, 9.5, 24, 9.5)
      ..close();
    canvas.drawPath(redPath, Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.fill);

    // 2. Blue Right Arc (#4285F4)
    final bluePath = Path()
      ..moveTo(46.98, 24.55)
      ..cubicTo(46.98, 22.98, 46.83, 21.46, 46.6, 20.0)
      ..lineTo(24, 20.0)
      ..relativeLineTo(0, 9.02)
      ..relativeLineTo(12.94, 0)
      ..cubicTo(36.36, 31.98, 34.68, 34.5, 32.16, 36.2)
      ..relativeLineTo(7.73, 6.0)
      ..cubicTo(44.4, 38.02, 46.98, 31.84, 46.98, 24.55)
      ..close();
    canvas.drawPath(bluePath, Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill);

    // 3. Yellow Left Arc (#FBBC05)
    final yellowPath = Path()
      ..moveTo(10.53, 28.59)
      ..cubicTo(10.05, 27.14, 9.77, 25.6, 9.77, 24.0)
      ..cubicTo(9.77, 22.4, 10.05, 20.86, 10.53, 19.41)
      ..relativeLineTo(-7.98, -6.19)
      ..cubicTo(0.92, 16.46, 0, 20.12, 0, 24.0)
      ..cubicTo(0, 27.88, 0.92, 31.54, 2.56, 34.78)
      ..relativeLineTo(7.97, -6.19)
      ..close();
    canvas.drawPath(yellowPath, Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.fill);

    // 4. Green Bottom Arc (#34A853)
    final greenPath = Path()
      ..moveTo(24, 48.0)
      ..cubicTo(30.48, 48.0, 35.93, 45.87, 39.89, 42.19)
      ..relativeLineTo(-7.73, -6.0)
      ..cubicTo(30.01, 37.64, 27.24, 38.5, 24, 38.5)
      ..cubicTo(17.74, 38.5, 12.43, 34.28, 10.53, 28.59)
      ..relativeLineTo(-7.98, 6.19)
      ..cubicTo(6.51, 42.62, 14.62, 48.0, 24, 48.0)
      ..close();
    canvas.drawPath(greenPath, Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
