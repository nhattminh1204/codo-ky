import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/services/weather/weather_service.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';

class WeatherDetailState {
  final AsyncValue<WeatherDetailResult> detail;
  final AsyncValue<WeatherForecastResult> forecast;
  final DateTime? loadedAt;

  const WeatherDetailState({
    this.detail = const AsyncValue.loading(),
    this.forecast = const AsyncValue.loading(),
    this.loadedAt,
  });

  WeatherDetailState copyWith({
    AsyncValue<WeatherDetailResult>? detail,
    AsyncValue<WeatherForecastResult>? forecast,
    DateTime? loadedAt,
  }) {
    return WeatherDetailState(
      detail: detail ?? this.detail,
      forecast: forecast ?? this.forecast,
      loadedAt: loadedAt ?? this.loadedAt,
    );
  }

  bool get isFullyLoaded => detail.hasValue && forecast.hasValue;
}

class WeatherDetailNotifier extends StateNotifier<WeatherDetailState> {
  final WeatherService _service;
  static const double _hueLatitude = 16.4637;
  static const double _hueLongitude = 107.5909;
  static const Duration _cacheMaxAge = Duration(minutes: 60);

  WeatherDetailNotifier(this._service) : super(const WeatherDetailState());

  Future<void> loadDetail({bool forceRefresh = false}) async {
    final loadedAt = state.loadedAt;
    final isCacheValid = loadedAt != null &&
        DateTime.now().difference(loadedAt) < _cacheMaxAge &&
        state.isFullyLoaded;
    if (!forceRefresh && isCacheValid) return;

    state = state.copyWith(
      detail: const AsyncValue.loading(),
      forecast: const AsyncValue.loading(),
    );

    WeatherDetailResult? detailResult;
    WeatherForecastResult? forecastResult;
    Object? detailError;
    StackTrace? detailStack;
    Object? forecastError;
    StackTrace? forecastStack;

    await Future.wait([
      _service
          .fetchWeatherDetail(latitude: _hueLatitude, longitude: _hueLongitude)
          .then((v) => detailResult = v)
          .catchError((Object e, StackTrace st) {
        detailError = e;
        detailStack = st;
        return WeatherDetailResult(
          current: const CurrentWeatherResult(
            temperature: 0, weatherCode: 0, precipitation: 0, humidity: 0),
          feelsLike: 0, windSpeed: 0, uvIndex: 0, aqi: null, hourly: [],
        );
      }),
      _service
          .fetchForecast(latitude: _hueLatitude, longitude: _hueLongitude, forecastDays: 7)
          .then((v) => forecastResult = v)
          .catchError((Object e, StackTrace st) {
        forecastError = e;
        forecastStack = st;
        return const WeatherForecastResult(days: []);
      }),
    ]);

    state = state.copyWith(
      detail: detailResult != null
          ? AsyncValue.data(detailResult!)
          : AsyncValue.error(detailError!, detailStack!),
      forecast: forecastResult != null
          ? AsyncValue.data(forecastResult!)
          : AsyncValue.error(forecastError!, forecastStack!),
      loadedAt: DateTime.now(),
    );
  }
}

final weatherDetailProvider =
    StateNotifierProvider<WeatherDetailNotifier, WeatherDetailState>((ref) {
  final service = ref.watch(weatherServiceProvider);
  return WeatherDetailNotifier(service);
});
