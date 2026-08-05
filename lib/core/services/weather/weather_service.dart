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
  // Endpoint riêng cho chất lượng không khí.
  final airQualityDio = Dio(
    BaseOptions(
      baseUrl: 'https://air-quality-api.open-meteo.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  return WeatherService(dio, airQualityDio: airQualityDio);
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
  final Dio _airQualityDio;

  /// Tọa độ mặc định của Huế (dùng khi không truyền lat/lon).
  static const double _hueLatitude = 16.4637;
  static const double _hueLongitude = 107.5909;

  WeatherService(this._dio, {Dio? airQualityDio})
      : _airQualityDio = airQualityDio ?? Dio(BaseOptions(baseUrl: 'https://air-quality-api.open-meteo.com'));

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

  /// Lấy thời tiết HIỆN TẠI tại [latitude]/[longitude] (mặc định Huế).
  ///
  /// Dùng cùng endpoint /v1/forecast nhưng chỉ request khối `current`,
  /// nhẹ hơn nhiều so với [fetchForecast] (nhiều ngày).
  ///
  /// Throws [WeatherServiceException] nếu network lỗi hoặc parse thất bại.
  Future<CurrentWeatherResult> fetchCurrentWeather({
    double latitude = _hueLatitude,
    double longitude = _hueLongitude,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current': [
            'temperature_2m',
            'weather_code',
            'precipitation',
            'relative_humidity_2m',
          ].join(','),
          'timezone': 'auto',
        },
      );

      final data = response.data;
      if (data == null) {
        throw WeatherServiceException('Response data trống từ Open-Meteo.');
      }

      return _parseCurrentWeather(data);
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

  /// Lấy thời tiết chi tiết cho panel Map: tình hình hiện tại + các chỉ số
  /// mở rộng + dự báo theo giờ 24h + chất lượng không khí (US AQI).
  ///
  /// AQI được gọi song song endpoint riêng; nếu thất bại chỉ set `null` chứ
  /// KHÔNG làm hỏng toàn bộ kết quả.
  Future<WeatherDetailResult> fetchWeatherDetail({
    double latitude = _hueLatitude,
    double longitude = _hueLongitude,
  }) async {
    int? aqi;
    try {
      final airResponse = await _airQualityDio.get<Map<String, dynamic>>(
        '/v1/air-quality',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current': 'us_aqi',
        },
      );
      final currentAir = airResponse.data?['current'] as Map<String, dynamic>?;
      aqi = (currentAir?['us_aqi'] as num?)?.toInt();
    } on DioException {
      aqi = null;
    } catch (_) {
      aqi = null;
    }

    return _parseWeatherDetail(
      await _safeForecast(
        latitude: latitude,
        longitude: longitude,
        current: [
          'temperature_2m',
          'weather_code',
          'precipitation',
          'relative_humidity_2m',
          'apparent_temperature',
          'wind_speed_10m',
          'uv_index',
        ],
        hourly: [
          'temperature_2m',
          'weather_code',
          'precipitation_probability',
        ],
        forecastHours: 24,
      ),
      aqi: aqi,
    );
  }

  /// Helper thực hiện request `/v1/forecast` và bọc mọi lỗi thành
  /// [WeatherServiceException].
  Future<Map<String, dynamic>> _safeForecast({
    required double latitude,
    required double longitude,
    required List<String> current,
    required List<String> hourly,
    required int forecastHours,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current': current.join(','),
          'hourly': hourly.join(','),
          'forecast_hours': forecastHours,
          'timezone': 'auto',
        },
      );
      final data = response.data;
      if (data == null) {
        throw WeatherServiceException('Response data trống từ Open-Meteo.');
      }
      return data;
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

  /// Parse JSON thành [WeatherDetailResult].
  WeatherDetailResult _parseWeatherDetail(
    Map<String, dynamic> data, {
    int? aqi,
  }) {
    final current = _parseCurrentWeather(data);
    final currentRaw = data['current'] as Map<String, dynamic>? ?? {};

    final hourlyRaw = data['hourly'] as Map<String, dynamic>?;
    final times = (hourlyRaw?['time'] as List?)?.cast<String>() ?? [];
    final codes = (hourlyRaw?['weather_code'] as List?)?.cast<num>() ?? [];
    final temps = (hourlyRaw?['temperature_2m'] as List?)?.cast<num>() ?? [];
    final probs =
        (hourlyRaw?['precipitation_probability'] as List?)?.cast<num>() ?? [];

    final now = DateTime.now().toUtc();
    final hourly = <HourlyWeather>[];
    for (var i = 0; i < times.length && hourly.length < 24; i++) {
      final time = DateTime.tryParse(times[i]);
      // Chỉ giữ giờ từ hiện tại trở đi.
      if (time == null || !time.isAfter(now.subtract(const Duration(hours: 1)))) {
        continue;
      }
      hourly.add(HourlyWeather(
        time: time.toLocal(),
        weatherCode: codes.elementAtOrNull(i)?.toInt() ?? 0,
        temperature: temps.elementAtOrNull(i)?.toDouble() ?? 0.0,
        precipitationProbability: probs.elementAtOrNull(i)?.toInt() ?? 0,
      ));
    }

    return WeatherDetailResult(
      current: current,
      feelsLike: (currentRaw['apparent_temperature'] as num?)?.toDouble() ?? current.temperature,
      windSpeed: (currentRaw['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      uvIndex: (currentRaw['uv_index'] as num?)?.toDouble() ?? 0.0,
      aqi: aqi,
      hourly: hourly,
    );
  }

  /// Parse khối `current` từ JSON response Open-Meteo thành [CurrentWeatherResult].
  CurrentWeatherResult _parseCurrentWeather(Map<String, dynamic> data) {
    final current = data['current'] as Map<String, dynamic>?;
    if (current == null) {
      throw WeatherServiceException(
          'Thiếu trường "current" trong response Open-Meteo.');
    }

    return CurrentWeatherResult(
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? 0,
      precipitation: (current['precipitation'] as num?)?.toDouble() ?? 0.0,
      humidity: (current['relative_humidity_2m'] as num?)?.toDouble() ?? 0.0,
    );
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
