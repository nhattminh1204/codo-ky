import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/core/services/weather/weather_service.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';
import 'package:codoky/features/map/presentation/providers/weather_detail_provider.dart';

class MockWeatherDetailService extends WeatherService {
  MockWeatherDetailService() : super(Dio());
  int detailFetchCount = 0;
  int forecastFetchCount = 0;
  bool shouldThrowError = false;

  @override
  Future<WeatherDetailResult> fetchWeatherDetail({
    double latitude = 16.4637,
    double longitude = 107.5909,
  }) async {
    detailFetchCount++;
    if (shouldThrowError) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      );
    }
    return WeatherDetailResult(
      current: const CurrentWeatherResult(
        temperature: 28,
        weatherCode: 1,
        precipitation: 0,
        humidity: 70,
      ),
      feelsLike: 29,
      windSpeed: 12,
      uvIndex: 4.5,
      aqi: 65,
      hourly: [],
    );
  }

  @override
  Future<WeatherForecastResult> fetchForecast({
    double latitude = 16.4637,
    double longitude = 107.5909,
    int forecastDays = 7,
  }) async {
    forecastFetchCount++;
    if (shouldThrowError) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      );
    }
    return const WeatherForecastResult(days: []);
  }
}

void main() {
  group('WeatherDetailNotifier SWR & Offline Resilience Tests', () {
    test('1. Cold start: Nạp dữ liệu thành công lần đầu tiên', () async {
      final service = MockWeatherDetailService();
      final notifier = WeatherDetailNotifier(service);

      await notifier.loadDetail();

      expect(service.detailFetchCount, equals(1));
      expect(service.forecastFetchCount, equals(1));
      expect(notifier.state.isFullyLoaded, isTrue);
      expect(notifier.state.isRefreshing, isFalse);
      expect(notifier.state.isOffline, isFalse);
      expect(notifier.state.detail.value!.feelsLike, equals(29));
    });

    test('2. Stale-While-Revalidate (SWR): Vuốt làm mới KHÔNG xóa dữ liệu cũ trong RAM', () async {
      final service = MockWeatherDetailService();
      final notifier = WeatherDetailNotifier(service);

      // Nạp lần 1
      await notifier.loadDetail();
      expect(notifier.state.isFullyLoaded, isTrue);

      // Gọi forceRefresh = true
      final refreshFuture = notifier.loadDetail(forceRefresh: true);

      // Ngay khi vừa gọi refresh, data cũ VẪN PHẢI HỢP LỆ (SWR: 0% flicker)
      expect(notifier.state.detail.hasValue, isTrue);
      expect(notifier.state.isRefreshing, isTrue);

      await refreshFuture;

      expect(service.detailFetchCount, equals(2));
      expect(notifier.state.isRefreshing, isFalse);
      expect(notifier.state.isOffline, isFalse);
    });

    test('3. Offline Resilience: Mất mạng khi vuốt làm mới VẪN GIỮ dữ liệu cũ', () async {
      final service = MockWeatherDetailService();
      final notifier = WeatherDetailNotifier(service);

      // Nạp lần 1 thành công
      await notifier.loadDetail();
      expect(notifier.state.detail.value!.feelsLike, equals(29));

      // Giả lập rớt mạng khi refresh
      service.shouldThrowError = true;
      await notifier.loadDetail(forceRefresh: true);

      // Dữ liệu cũ KHÔNG bị đè bởi dummy 0°C, isOffline bật thành true
      expect(notifier.state.detail.hasValue, isTrue);
      expect(notifier.state.detail.value!.feelsLike, equals(29));
      expect(notifier.state.isRefreshing, isFalse);
      expect(notifier.state.isOffline, isTrue);
    });
  });
}
