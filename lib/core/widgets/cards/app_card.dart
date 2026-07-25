import 'package:flutter/material.dart';
import 'package:codoky/core/config/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final double? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.boxShadow,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = BorderRadius.circular(borderRadius ?? AppRadius.lg);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget container = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        borderRadius: effectiveRadius,
        border: border ?? Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        boxShadow: boxShadow ?? AppShadows.card,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          child: container,
        ),
      );
    }

    return container;
  }
}
