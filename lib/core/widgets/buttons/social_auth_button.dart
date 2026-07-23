import 'package:flutter/material.dart';

enum SocialType { google, apple }

class SocialAuthButton extends StatelessWidget {
  final SocialType type;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.type,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isGoogle = type == SocialType.google;
    final label = isGoogle ? 'Tiếp tục với Google' : 'Tiếp tục với Apple';
    final icon = isGoogle ? Icons.g_mobiledata_rounded : Icons.apple;
    final iconColor = isGoogle ? const Color(0xFFEA4335) : Colors.black;

    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300, width: 1.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: isGoogle ? 30 : 24, color: iconColor),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
              ],
            ),
    );
  }
}
