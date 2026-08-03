import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';

/// Provider cho WeatherService — inject ApiClient sẵn có (có timeout/retry).
final weatherServiceProvider = Provider<WeatherService>((ref) {
  // Tạo Dio riêng biệt cho Open-Meteo (baseUrl khác Cloud Function)
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.open-meteo.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  return WeatherService(dio);
});

/// Service gọi Open-Meteo API để lấy dự báo thời tiết.
///
/// Không cần API key. Dùng trực tiếp từ Flutter client vì:
/// - Open-Meteo là public API, không có thông tin nhạy cảm.
/// - Bảo mật không yêu cầu proxy qua Cloud Function cho trường hợp này.
///
/// Doc: https://open-meteo.com/en/docs
class WeatherService {
  final Dio _dio;

  /// Tọa độ mặc định của Huế (dùng khi không truyền lat/lon).
  static const double _hueLatitude = 16.4637;
  static const double _hueLongitude = 107.5909;

  WeatherService(this._dio);

  /// Lấy dự báo thời tiết cho [forecastDays] ngày tới.
  ///
  /// [latitude] và [longitude] mặc định là tọa độ trung tâm Huế.
  /// [forecastDays] tối đa 16 ngày (giới hạn Open-Meteo free tier).
  ///
  /// Throws [WeatherServiceException] nếu network lỗi hoặc parse thất bại.
  Future<WeatherForecastResult> fetchForecast({
    double latitude = _hueLatitude,
    double longitude = _hueLongitude,
    int forecastDays = 3,
  }) async {
    assert(forecastDays >= 1 && forecastDays <= 16,
        'forecastDays phải trong khoảng 1–16');

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'daily': [
            'weather_code',
            'temperature_2m_max',
            'temperature_2m_min',
            'precipitation_probability_max',
          ].join(','),
          'timezone': 'auto',
          'forecast_days': forecastDays,
        },
      );

      final data = response.data;
      if (data == null) {
        throw WeatherServiceException('Response data trống từ Open-Meteo.');
      }

      return _parseResponse(data);
    } on DioException catch (e) {
      throw WeatherServiceException(
        'Network error khi gọi Open-Meteo: ${e.message}',
        cause: e,
      );
    } catch (e) {
      if (e is WeatherServiceException) rethrow;
      throw WeatherServiceException('Lỗi không xác định: $e', cause: e);
    }
  }

  /// Parse JSON response từ Open-Meteo thành [WeatherForecastResult].
  WeatherForecastResult _parseResponse(Map<String, dynamic> data) {
    final daily = data['daily'] as Map<String, dynamic>?;
    if (daily == null) {
      throw WeatherServiceException(
          'Thiếu trường "daily" trong response Open-Meteo.');
    }

    final times = (daily['time'] as List?)?.cast<String>() ?? [];
    final codes = (daily['weather_code'] as List?)?.cast<num>() ?? [];
    final tempMax = (daily['temperature_2m_max'] as List?)?.cast<num>() ?? [];
    final tempMin = (daily['temperature_2m_min'] as List?)?.cast<num>() ?? [];
    final rainProb =
        (daily['precipitation_probability_max'] as List?)?.cast<num>() ?? [];

    if (times.isEmpty) {
      return const WeatherForecastResult(days: []);
    }

    final days = <DayWeatherForecast>[];
    for (var i = 0; i < times.length; i++) {
      days.add(DayWeatherForecast(
        date: DateTime.parse(times[i]),
        weatherCode: codes.elementAtOrNull(i)?.toInt() ?? 0,
        tempMax: tempMax.elementAtOrNull(i)?.toDouble() ?? 0.0,
        tempMin: tempMin.elementAtOrNull(i)?.toDouble() ?? 0.0,
        rainProbability: rainProb.elementAtOrNull(i)?.toInt() ?? 0,
      ));
    }

    return WeatherForecastResult(days: days);
  }
}

/// Exception riêng cho WeatherService — có thể catch cụ thể trong UI.
class WeatherServiceException implements Exception {
  final String message;
  final Object? cause;

  const WeatherServiceException(this.message, {this.cause});

  @override
  String toString() => 'WeatherServiceException: $message';
}
