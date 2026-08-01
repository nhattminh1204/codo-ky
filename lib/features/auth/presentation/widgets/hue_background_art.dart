import 'package:flutter/material.dart';

class HueBackgroundArt extends StatelessWidget {
  final Widget? child;

  const HueBackgroundArt({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
          // Background Image Asset from e:\Workspace\CodoKy\logo\background.png
          Positioned.fill(
            child: Image.asset(
              'assets/images/hue_background.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to custom canvas artwork if image is unavailable
                return CustomPaint(
                  painter: _HueFallbackBackgroundPainter(),
                );
              },
            ),
          ),
          if (child != null) child!,
        ],
      );
  }
}

class _HueFallbackBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final strokePaint = Paint()
      ..color = const Color(0xFFA61E2D).withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFFA61E2D).withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    final bridgePath = Path();
    final bridgeY = h * 0.88;
    final archWidth = w / 6;

    bridgePath.moveTo(0, bridgeY);
    for (int i = 0; i < 6; i++) {
      final startX = i * archWidth;
      final endX = (i + 1) * archWidth;
      final midX = startX + archWidth / 2;
      bridgePath.quadraticBezierTo(midX, bridgeY - 24, endX, bridgeY);
    }
    bridgePath.lineTo(w, h);
    bridgePath.lineTo(0, h);
    bridgePath.close();

    canvas.drawPath(bridgePath, fillPaint);
    canvas.drawPath(bridgePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
