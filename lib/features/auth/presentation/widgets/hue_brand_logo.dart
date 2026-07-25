import 'dart:math' as math;
import 'package:flutter/material.dart';

class HueBrandLogo extends StatelessWidget {
  final double size;

  const HueBrandLogo({
    super.key,
    this.size = 112.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Concentric Ceremonial Sun Wheel / Gold Halo Pattern behind the logo
        CustomPaint(
          size: Size(size * 2.2, size * 2.2),
          painter: const _GoldenHaloRingsPainter(),
        ),

        // Main Imperial Red Logo Container
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.28), // Apple / M3 continuous smooth corners
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B1522).withValues(alpha: 0.38),
                blurRadius: 28,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFFC89B3C).withValues(alpha: 0.2),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.28),
            child: Image.asset(
              'assets/images/hue_logo.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF9B1B30),
                  child: const Icon(
                    Icons.map_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Ceremonial Gold Halo Circle Pattern (behind logo)
class _GoldenHaloRingsPainter extends CustomPainter {
  const _GoldenHaloRingsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final goldStroke1 = Paint()
      ..color = const Color(0xFFC89B3C).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final goldStroke2 = Paint()
      ..color = const Color(0xFFC89B3C).withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final goldDotted = Paint()
      ..color = const Color(0xFFC89B3C).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Concentric Ring 1
    canvas.drawCircle(center, maxRadius * 0.62, goldStroke1);
    // Concentric Ring 2
    canvas.drawCircle(center, maxRadius * 0.76, goldStroke2);
    // Concentric Ring 3
    canvas.drawCircle(center, maxRadius * 0.90, goldStroke1);

    // Decorative radial ticks around outer ring
    const int numTicks = 36;
    for (int i = 0; i < numTicks; i++) {
      final angle = (i * 360 / numTicks) * (math.pi / 180);
      final r1 = maxRadius * 0.86;
      final r2 = maxRadius * 0.90;
      final p1 = Offset(center.dx + r1 * math.cos(angle), center.dy + r1 * math.sin(angle));
      final p2 = Offset(center.dx + r2 * math.cos(angle), center.dy + r2 * math.sin(angle));
      canvas.drawLine(p1, p2, goldDotted);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
