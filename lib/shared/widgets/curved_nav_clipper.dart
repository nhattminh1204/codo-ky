import 'package:flutter/material.dart';

class CurvedNavClipper extends CustomClipper<Path> {
  final double activeX;
  final double dipRadius;
  final double dipDepth;
  final double cornerRadius;

  CurvedNavClipper({
    required this.activeX,
    this.dipRadius = 28.0,
    this.dipDepth = 32.0,
    this.cornerRadius = 24.0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    // Start top-left after corner
    path.moveTo(cornerRadius, 0);

    // Line to left side of notch
    final leftNotch = activeX - dipRadius * 1.35;
    if (leftNotch > cornerRadius) {
      path.lineTo(leftNotch, 0);
    }

    // Smooth curve entering U-notch
    path.cubicTo(
      activeX - dipRadius * 0.7,
      0,
      activeX - dipRadius * 0.65,
      dipDepth,
      activeX,
      dipDepth,
    );

    // Smooth curve exiting U-notch
    path.cubicTo(
      activeX + dipRadius * 0.65,
      dipDepth,
      activeX + dipRadius * 0.7,
      0,
      activeX + dipRadius * 1.35,
      0,
    );

    // Line to top-right
    path.lineTo(width - cornerRadius, 0);
    path.quadraticBezierTo(width, 0, width, cornerRadius);

    // Bottom-right corner
    path.lineTo(width, height - cornerRadius);
    path.quadraticBezierTo(width, height, width - cornerRadius, height);

    // Bottom-left corner
    path.lineTo(cornerRadius, height);
    path.quadraticBezierTo(0, height, 0, height - cornerRadius);

    // Top-left corner
    path.lineTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CurvedNavClipper oldClipper) {
    return oldClipper.activeX != activeX ||
        oldClipper.dipRadius != dipRadius ||
        oldClipper.dipDepth != dipDepth ||
        oldClipper.cornerRadius != cornerRadius;
  }
}



