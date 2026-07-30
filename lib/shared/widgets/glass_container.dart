import 'dart:ui';
import 'package:flutter/material.dart';

/// AppLiquidGlassContainer - Reusable Apple Liquid Glass Component (Spatial Translucency)
/// Automatically adapts glass translucency, specular refraction border, backdrop blur,
/// and soft Z-axis spatial elevation shadows depending on Light / Dark mode.
class AppLiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double? opacity;
  final Color? color;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? boxShadow;
  final Gradient? borderGradient;

  const AppLiquidGlassContainer({
    super.key,
    required this.child,
    this.blur = 24.0,
    this.opacity,
    this.color,
    this.borderRadius,
    this.border,
    this.padding,
    this.margin,
    this.boxShadow,
    this.borderGradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(20);

    // Adaptive Light / Dark Mode Color & Opacity
    final effectiveColor = color ??
        (isDark
            ? const Color(0xFF1E293B).withValues(alpha: opacity ?? 0.25)
            : Colors.white.withValues(alpha: opacity ?? 0.55));

    // Adaptive 45° Specular Refraction Glass Border Highlight
    final effectiveBorder = borderGradient != null
        ? null
        : (border ??
            Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.85),
              width: 1.2,
            ));

    final effectiveShadow = boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ];

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: effectiveShadow,
        gradient: borderGradient,
      ),
      padding: borderGradient != null ? const EdgeInsets.all(1.5) : EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: effectiveRadius,
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: effectiveRadius,
              border: effectiveBorder,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Backwards compatibility alias for GlassContainer
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color color;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.opacity = 0.15,
    this.color = Colors.white,
    this.borderRadius,
    this.border,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AppLiquidGlassContainer(
      blur: blur,
      opacity: opacity,
      color: color,
      borderRadius: borderRadius,
      border: border,
      padding: padding,
      margin: margin,
      child: child,
    );
  }
}
