import 'package:flutter/material.dart';

/// Centralized SnackBar notification helper for CodoKy
/// Ensures all floating notifications float cleanly above the bottom navigation bar (margin bottom: 92).
class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor = isDark ? const Color(0xFF1E222A) : const Color(0xFF0F172A);
    Color textColor = Colors.white;
    IconData icon = Icons.info_outline_rounded;
    Color iconColor = const Color(0xFFFF7A00);

    if (isError) {
      bgColor = const Color(0xFF9B1B30);
      icon = Icons.error_outline_rounded;
      iconColor = Colors.white;
    } else if (isSuccess) {
      bgColor = const Color(0xFF065F46);
      icon = Icons.check_circle_outline_rounded;
      iconColor = const Color(0xFF34D399);
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 92, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: bgColor,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.20),
            width: 1,
          ),
        ),
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: const Color(0xFFFF7A00),
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
