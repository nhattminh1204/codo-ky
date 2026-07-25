import 'package:flutter/material.dart';
import 'package:codoky/core/config/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool useGradient;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;
  final IconData? icon;
  final bool isDisabled;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.useGradient = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 52,
    this.icon,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = (isLoading || isDisabled || onPressed == null) ? null : onPressed;
    final primaryColor = backgroundColor ?? AppColors.primary;
    final fgColor = foregroundColor ?? Colors.white;

    Widget childWidget = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? primaryColor : fgColor,
              ),
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: 20, color: isOutlined ? primaryColor : fgColor),
          const SizedBox(width: 8),
        ],
        if (!isLoading)
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isOutlined ? primaryColor : fgColor,
            ),
          ),
      ],
    );

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor, width: 1.6),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
          ),
          child: childWidget,
        ),
      );
    }

    if (useGradient && effectiveOnPressed != null) {
      return Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: AppGradients.sunsetGradient,
          borderRadius: AppRadius.button,
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.button,
          child: InkWell(
            onTap: effectiveOnPressed,
            borderRadius: AppRadius.button,
            child: Center(child: childWidget),
          ),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: fgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
        ),
        child: childWidget,
      ),
    );
  }
}