import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:codoky/core/theme/motion.dart';

/// Reusable OpenContainer widget wrapper implementing Material 3 Container Transform
/// for smooth Shared Element Transitions between cards and detail screens.
class AppOpenContainer<T> extends StatelessWidget {
  final Widget Function(BuildContext context, VoidCallback openContainer) closedBuilder;
  final Widget Function(BuildContext context, VoidCallback closeContainer) openBuilder;
  final BorderRadius closedRadius;
  final Color? closedColor;
  final Color? openColor;
  final Duration duration;

  const AppOpenContainer({
    super.key,
    required this.closedBuilder,
    required this.openBuilder,
    this.closedRadius = const BorderRadius.all(Radius.circular(16)),
    this.closedColor = Colors.transparent,
    this.openColor,
    this.duration = AppMotion.emphasized,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OpenContainer<T>(
      transitionDuration: duration,
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: 0,
      openElevation: 0,
      closedShape: RoundedRectangleBorder(borderRadius: closedRadius),
      closedColor: closedColor ?? Colors.transparent,
      openColor: openColor ?? theme.scaffoldBackgroundColor,
      openBuilder: openBuilder,
      closedBuilder: closedBuilder,
    );
  }
}
