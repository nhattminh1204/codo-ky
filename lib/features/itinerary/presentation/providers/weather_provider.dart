import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/services/weather/weather_service.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';

/// FutureProvider.family cache dự báo thời tiết theo số ngày lộ trình.
///
/// Gọi MỘT LẦN duy nhất khi màn hình mở, cache tự động theo Riverpod.
/// Khi người dùng bấm qua lại giữa các tab ngày, dữ liệu được lấy từ
/// cache — không gọi lại API.
///
/// Key = [forecastDays] (số ngày lộ trình, 1–16).
///
/// Khi lỗi mạng/timeout, provider trả AsyncValue.error — WeatherStrip
/// sẽ render trạng thái empty/ẩn, không crash màn hình.
final weatherForecastProvider =
    FutureProvider.family<WeatherForecastResult, int>((ref, forecastDays) async {
  final service = ref.watch(weatherServiceProvider);
  // Clamp trong khoảng hợp lệ (1–16 ngày, Open-Meteo free tier)
  final clampedDays = forecastDays.clamp(1, 16);
  return service.fetchForecast(forecastDays: clampedDays);
});
