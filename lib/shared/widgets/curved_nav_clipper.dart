import 'package:flutter/material.dart';

class CurvedNavClipper extends CustomClipper<Path> {
  final double activeX;
  final double dipRadius;
  final double dipDepth;

  CurvedNavClipper({
    required this.activeX,
    this.dipRadius = 34.0,
    this.dipDepth = 24.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    // Start top-left
    path.moveTo(0, 0);

    // Line to left side of notch
    path.lineTo(activeX - dipRadius * 1.5, 0);

    // Smooth curve entering notch
    path.cubicTo(
      activeX - dipRadius * 0.8,
      0,
      activeX - dipRadius * 0.65,
      dipDepth,
      activeX,
      dipDepth,
    );

    // Smooth curve exiting notch
    path.cubicTo(
      activeX + dipRadius * 0.65,
      dipDepth,
      activeX + dipRadius * 0.8,
      0,
      activeX + dipRadius * 1.5,
      0,
    );

    // Line to top-right
    path.lineTo(width, 0);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CurvedNavClipper oldClipper) {
    return oldClipper.activeX != activeX ||
        oldClipper.dipRadius != dipRadius ||
        oldClipper.dipDepth != dipDepth;
  }
}
