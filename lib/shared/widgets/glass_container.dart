import 'dart:ui';
import 'package:flutter/material.dart';

/// AppLiquidGlassContainer - Reusable Apple Liquid Glass Component (Spatial Translucency)
///
/// Replicates the Locus Liquid Glass recipe (Locus/Support/Theme.swift):
/// - [blur]: backdrop blur matching Apple's `ultraThinMaterial` (~30px).
/// - Adaptive Light / Dark base fill (white / imperial slate).
/// - [tint]: colored "liquid" overlay alpha-blended into the glass, mirroring
///   Locus's `.tint(...)` glass tint.
/// - Specular refraction border: a 45° light-catching gradient ring (brighter
///   at the top-left, fading to the bottom-right) plus an inner top-edge
///   highlight band, like `panelStroke` / the glass specular edge.
/// - Soft Z-axis elevation shadow for spatial depth.
class AppLiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double? opacity;
  final Color? color;
  final Color? tint;
  final double tintOpacity;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? boxShadow;
  final Gradient? borderGradient;
  final bool enableSpecular;
  final double specularStrength;
  final bool enableTopHighlight;

  const AppLiquidGlassContainer({
    super.key,
    required this.child,
    this.blur = 30.0, // Match Apple's ultraThinMaterial blur
    this.opacity,
    this.color,
    this.tint,
    this.tintOpacity = 0.16,
    this.borderRadius,
    this.border,
    this.padding,
    this.margin,
    this.boxShadow,
    this.borderGradient,
    this.enableSpecular = true,
    this.specularStrength = 1.0,
    this.enableTopHighlight = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveRadius = borderRadius ?? BorderRadius.circular(20);

    // Adaptive Light / Dark Mode Color & Opacity matching ultraThinMaterial
    final effectiveColor =
        color ??
        (isDark
            ? const Color(0xFF1E293B).withValues(alpha: opacity ?? 0.24)
            : Colors.white.withValues(alpha: opacity ?? 0.14));

    // Gradient specular border is used when no explicit border is provided.
    final useGradientBorder =
        borderGradient != null || (enableSpecular && border == null);

    final glassTint = tint;
    final effectiveShadow =
        boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.10),
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
        ];

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: effectiveShadow,
        gradient: borderGradient ??
            (useGradientBorder
                ? _specularBorderGradient(isDark, specularStrength)
                : null),
      ),
      padding: useGradientBorder
          ? const EdgeInsets.all(1.5)
          : EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: effectiveRadius,
        clipBehavior: Clip.antiAlias,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Stack(
            children: [
              // 1. Glass fill + optional "liquid" color tint blended in.
              Container(
                padding: padding,
                decoration: BoxDecoration(
                  borderRadius: effectiveRadius,
                  color: glassTint == null ? effectiveColor : null,
                  gradient: glassTint != null
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.alphaBlend(
                              glassTint.withValues(alpha: tintOpacity),
                              effectiveColor,
                            ),
                            Color.alphaBlend(
                              glassTint.withValues(alpha: tintOpacity * 0.35),
                              effectiveColor,
                            ),
                          ],
                        )
                      : null,
                ),
                child: child,
              ),
              // 2. Inner specular edge highlight (glass catches light on top).
              if (enableTopHighlight)
                Positioned.fill(
                  child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: effectiveRadius,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.35],
                        colors: [
                          Colors.white.withValues(
                            alpha: (isDark ? 0.10 : 0.22) * specularStrength,
                          ),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                  ),
                ),
              ),
            ),
              // 3. Specular refraction stroke (like Locus panelStroke).
              if (!useGradientBorder)
                Positioned.fill(
                  child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: effectiveRadius,
                      border:
                          border ??
                          Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.14)
                                : Colors.white.withValues(alpha: 0.45),
                            width: 1.0,
                          ),
                    ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 45° specular refraction border: bright on the top-left edge where light
  /// enters the glass, dimming toward the bottom-right — mirroring the liquid
  /// glass specular edge and `LocusTheme.panelStroke`.
  LinearGradient _specularBorderGradient(bool isDark, double strength) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0.0, 0.5, 1.0],
      colors: [
        Colors.white.withValues(alpha: (isDark ? 0.30 : 0.65) * strength),
        Colors.white.withValues(alpha: (isDark ? 0.10 : 0.22) * strength),
        Colors.black.withValues(alpha: (isDark ? 0.0 : 0.10) * strength),
      ],
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
