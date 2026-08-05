import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';

/// WeatherIconWidget — Component hiển thị Icon thời tiết Meteocons SVG (by Bas Milius)
/// Tự động ánh xạ WMO Weather Code (Open-Meteo) và phân biệt Ngày/Đêm (Day/Night) theo timestamp.
class WeatherIconWidget extends StatelessWidget {
  final int weatherCode;
  final double size;
  final bool? isNight;
  final DateTime? timestamp;
  final bool enableGlow;
  final bool useEmojiFallback;

  const WeatherIconWidget({
    super.key,
    required this.weatherCode,
    this.size = 32.0,
    this.isNight,
    this.timestamp,
    this.useEmojiFallback = false,
    this.enableGlow = true,
  });

  /// Tính toán trạng thái Ban Đêm dựa trên tham số hoặc timestamp
  bool get _effectiveIsNight {
    if (isNight != null) return isNight!;
    final dt = timestamp ?? DateTime.now();
    return dt.hour < 6 || dt.hour >= 18;
  }

  /// Màu tỏa ánh sáng hào quang (Ambient Glow Color) theo loại thời tiết
  Color get glowColor {
    if (weatherCode == 0) {
      return _effectiveIsNight ? const Color(0xFF6366F1) : const Color(0xFFF59E0B);
    }
    if (weatherCode >= 1 && weatherCode <= 2) {
      return _effectiveIsNight ? const Color(0xFF818CF8) : const Color(0xFFFBBF24);
    }
    if (weatherCode == 3) {
      return const Color(0xFF64748B);
    }
    if (weatherCode == 45 || weatherCode == 48) {
      return const Color(0xFF94A3B8);
    }
    if ((weatherCode >= 51 && weatherCode <= 67) || (weatherCode >= 80 && weatherCode <= 82)) {
      return const Color(0xFF0EA5E9);
    }
    if (weatherCode >= 95 && weatherCode <= 99) {
      return const Color(0xFFA855F7);
    }
    return const Color(0xFF64748B);
  }

  /// Tên file SVG chuẩn Meteocons (Filled style) theo WMO weather code
  String get svgFileName {
    final night = _effectiveIsNight;

    switch (weatherCode) {
      case 0:
        return night ? 'clear-night.svg' : 'clear-day.svg';
      case 1:
      case 2:
        return night ? 'partly-cloudy-night.svg' : 'partly-cloudy-day.svg';
      case 3:
        return 'overcast.svg';
      case 45:
      case 48:
        return 'fog.svg';
      case 51:
      case 53:
      case 55:
        return 'drizzle.svg';
      case 56:
      case 57:
        return 'sleet.svg';
      case 61:
      case 63:
        return 'rain.svg';
      case 65:
        return 'overcast-rain.svg';
      case 66:
      case 67:
        return 'sleet.svg';
      case 71:
      case 73:
      case 75:
      case 77:
        return 'snow.svg';
      case 80:
      case 81:
      case 82:
        return night ? 'partly-cloudy-night-rain.svg' : 'partly-cloudy-day-rain.svg';
      case 85:
      case 86:
        return night ? 'partly-cloudy-night-snow.svg' : 'partly-cloudy-day-snow.svg';
      case 95:
        return night ? 'thunderstorms-night.svg' : 'thunderstorms-day.svg';
      case 96:
      case 99:
        return night ? 'thunderstorms-night-rain.svg' : 'thunderstorms-day-rain.svg';
      default:
        return night ? 'partly-cloudy-night.svg' : 'partly-cloudy-day.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (useEmojiFallback) {
      return Text(
        WmoCodeMapper.toIcon(weatherCode),
        style: TextStyle(fontSize: size * 0.85),
      );
    }

    final assetPath = 'assets/icons/weather/$svgFileName';

    final svgWidget = SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholderBuilder: (_) => Text(
        WmoCodeMapper.toIcon(weatherCode),
        style: TextStyle(fontSize: size * 0.8),
      ),
    );

    if (!enableGlow) {
      return SizedBox(
        width: size,
        height: size,
        child: svgWidget,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.28),
            blurRadius: size * 0.35,
            spreadRadius: 1,
          ),
        ],
      ),
      child: svgWidget,
    );
  }
}
