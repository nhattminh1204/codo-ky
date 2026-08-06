import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/services/weather/weather_service.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';

class WeatherDetailState {
  final AsyncValue<WeatherDetailResult> detail;
  final AsyncValue<WeatherForecastResult> forecast;
  final DateTime? loadedAt;
  final bool isRefreshing;
  final bool isOffline;

  const WeatherDetailState({
    this.detail = const AsyncValue.loading(),
    this.forecast = const AsyncValue.loading(),
    this.loadedAt,
    this.isRefreshing = false,
    this.isOffline = false,
  });

  WeatherDetailState copyWith({
    AsyncValue<WeatherDetailResult>? detail,
    AsyncValue<WeatherForecastResult>? forecast,
    DateTime? loadedAt,
    bool? isRefreshing,
    bool? isOffline,
  }) {
    return WeatherDetailState(
      detail: detail ?? this.detail,
      forecast: forecast ?? this.forecast,
      loadedAt: loadedAt ?? this.loadedAt,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isOffline: isOffline ?? this.isOffline,
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

    final hasExistingData = state.isFullyLoaded;

    if (hasExistingData) {
      // Stale-While-Revalidate (SWR): Preserve existing data in RAM to prevent UI flicker!
      state = state.copyWith(isRefreshing: true, isOffline: false);
    } else {
      // Cold start: Show loading skeleton
      state = state.copyWith(
        detail: const AsyncValue.loading(),
        forecast: const AsyncValue.loading(),
        isRefreshing: true,
        isOffline: false,
      );
    }

    WeatherDetailResult? detailResult;
    WeatherForecastResult? forecastResult;
    Object? detailError;
    StackTrace? detailStack;
    Object? forecastError;
    StackTrace? forecastStack;

    await Future.wait([
      () async {
        try {
          detailResult = await _service.fetchWeatherDetail(
              latitude: _hueLatitude, longitude: _hueLongitude);
        } catch (e, st) {
          detailError = e;
          detailStack = st;
        }
      }(),
      () async {
        try {
          forecastResult = await _service.fetchForecast(
              latitude: _hueLatitude, longitude: _hueLongitude, forecastDays: 7);
        } catch (e, st) {
          forecastError = e;
          forecastStack = st;
        }
      }(),
    ]);

    final isDetailSuccess = detailResult != null;
    final isForecastSuccess = forecastResult != null;

    if (isDetailSuccess && isForecastSuccess) {
      state = state.copyWith(
        detail: AsyncValue.data(detailResult!),
        forecast: AsyncValue.data(forecastResult!),
        loadedAt: DateTime.now(),
        isRefreshing: false,
        isOffline: false,
      );
    } else if (hasExistingData) {
      // Offline fallback during refresh: Preserve stale data & flag as offline
      state = state.copyWith(
        isRefreshing: false,
        isOffline: true,
      );
    } else {
      // Cold start error with no previous data
      state = state.copyWith(
        detail: isDetailSuccess
            ? AsyncValue.data(detailResult!)
            : AsyncValue.error(detailError ?? Exception('Failed to fetch weather detail'), detailStack ?? StackTrace.current),
        forecast: isForecastSuccess
            ? AsyncValue.data(forecastResult!)
            : AsyncValue.error(forecastError ?? Exception('Failed to fetch weather forecast'), forecastStack ?? StackTrace.current),
        isRefreshing: false,
        isOffline: true,
      );
    }
  }
}

final weatherDetailProvider =
    StateNotifierProvider<WeatherDetailNotifier, WeatherDetailState>((ref) {
  final service = ref.watch(weatherServiceProvider);
  return WeatherDetailNotifier(service);
});
