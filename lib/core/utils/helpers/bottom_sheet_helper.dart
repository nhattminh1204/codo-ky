import 'package:flutter/material.dart';
import 'package:codoky/core/theme/motion.dart';

/// Helper chuẩn duy nhất để hiển thị Bottom Sheet với Spring / Motion Token chuẩn của CodoKy
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  Color backgroundColor = Colors.transparent,
  TickerProvider? vsync,
}) {
  AnimationController? animationController;
  if (vsync != null) {
    animationController = AnimationController(
      duration: AppMotion.standard,
      vsync: vsync,
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    transitionAnimationController: animationController,
    builder: (context) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: AppMotion.standard,
        curve: AppMotion.emphasizedCurve,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, (1.0 - value) * 40),
            child: Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: builder(context),
      );
    },
  );
}
