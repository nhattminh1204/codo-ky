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
  final bool useEmojiFallback;

  const WeatherIconWidget({
    super.key,
    required this.weatherCode,
    this.size = 32.0,
    this.isNight,
    this.timestamp,
    this.useEmojiFallback = false,
  });

  /// Tính toán trạng thái Ban Đêm dựa trên tham số hoặc timestamp
  bool get _effectiveIsNight {
    if (isNight != null) return isNight!;
    final dt = timestamp ?? DateTime.now();
    return dt.hour < 6 || dt.hour >= 18;
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

    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => Text(
          WmoCodeMapper.toIcon(weatherCode),
          style: TextStyle(fontSize: size * 0.8),
        ),
      ),
    );
  }
}
