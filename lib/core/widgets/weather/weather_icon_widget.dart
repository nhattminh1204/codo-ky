import 'package:flutter/material.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';

/// WeatherIconWidget — Render icon thời tiết HD Vibrant Emoji Badge cao cấp
/// Tự động hiển thị Emoji thời tiết sắc nét, màu sắc rực rỡ (Nắng vàng ☀️, Mưa Cyan 🌧️, Giông ⛈️)
/// kết hợp khung kính mờ nhẹ chuẩn Glassmorphic.
class WeatherIconWidget extends StatelessWidget {
  final int weatherCode;
  final double size;
  final bool showBadge;

  const WeatherIconWidget({
    super.key,
    required this.weatherCode,
    this.size = 32.0,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = WmoCodeMapper.toIcon(weatherCode);

    if (!showBadge) {
      return Text(
        emoji,
        style: TextStyle(
          fontSize: size * 0.85,
          height: 1.0,
        ),
      );
    }

    return Container(
      width: size * 1.2,
      height: size * 1.2,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: size * 0.75,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
