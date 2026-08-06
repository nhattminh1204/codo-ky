import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:codoky/core/services/weather/weather_service.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';
import 'package:codoky/features/map/presentation/providers/current_weather_provider.dart';

/// Mock WeatherService (pattern giống itinerary_crud_test.dart): đếm số lần
/// fetch để assert callCount, không gọi network thật.
class MockWeatherService extends WeatherService {
  MockWeatherService() : super(Dio());
  int fetchCount = 0;

  @override
  Future<CurrentWeatherResult> fetchCurrentWeather({
    double latitude = 16.4637,
    double longitude = 107.5909,
  }) async {
    fetchCount++;
    return const CurrentWeatherResult(
      temperature: 30,
      weatherCode: 1,
      precipitation: 0,
      humidity: 80,
    );
  }
}

void main() {
  group('CurrentWeatherNotifier.refreshIfNeeded', () {
    // Huế
    final hue = LatLng(16.4637, 107.5909);
    // Đà Nẵng (~80km từ Huế)
    final daNang = LatLng(16.0544, 108.2022);

    test('1. Lần gọi đầu (lastFetchedPosition null) → luôn fetch', () async {
      final service = MockWeatherService();
      final notifier = CurrentWeatherNotifier(service);

      await notifier.refreshIfNeeded(hue);

      expect(service.fetchCount, equals(1));
      expect(notifier.state.lastFetchedPosition, isNotNull);
      expect(notifier.state.lastFetchedAt, isNotNull);
      expect(notifier.state.currentWeather.value, isNotNull);
      expect(notifier.state.currentWeather.value!.temperature, equals(30));
    });

    test('2. Vị trí gần (<10km) + trong 30 phút → KHÔNG fetch lại (callCount không tăng)',
        () async {
      final service = MockWeatherService();
      var now = DateTime(2026, 8, 4, 8, 0);
      final notifier = CurrentWeatherNotifier(service, now: () => now);

      await notifier.refreshIfNeeded(hue);
      expect(service.fetchCount, equals(1));

      // 10 phút sau, vị trí lệch ~0.7km (Tràng Tiền, gần Huế)
      now = now.add(const Duration(minutes: 10));
      final nearPos = LatLng(16.4700, 107.5900);

      await notifier.refreshIfNeeded(nearPos);

      // Không fetch mới → callCount giữ nguyên 1
      expect(service.fetchCount, equals(1));
      // Vị trí cache cuối cũng không đổi (không cần cập nhật)
      expect(notifier.state.lastFetchedPosition, equals(hue));
    });

    test('3. Vị trí xa (>10km) → fetch lại', () async {
      final service = MockWeatherService();
      var now = DateTime(2026, 8, 4, 8, 0);
      final notifier = CurrentWeatherNotifier(service, now: () => now);

      await notifier.refreshIfNeeded(hue);
      expect(service.fetchCount, equals(1));

      // Di chuyển tới Đà Nẵng (~80km) dù mới 5 phút
      now = now.add(const Duration(minutes: 5));

      await notifier.refreshIfNeeded(daNang);

      expect(service.fetchCount, equals(2));
      expect(notifier.state.lastFetchedPosition, equals(daNang));
    });

    test('4. Vị trí same nhưng đã quá 30 phút → fetch lại', () async {
      final service = MockWeatherService();
      var now = DateTime(2026, 8, 4, 8, 0);
      final notifier = CurrentWeatherNotifier(service, now: () => now);

      await notifier.refreshIfNeeded(hue);
      expect(service.fetchCount, equals(1));

      // Trôi 31 phút, vẫn đứng yên ở Huế → hết hạn cache theo thời gian
      now = now.add(const Duration(minutes: 31));

      await notifier.refreshIfNeeded(hue);

      expect(service.fetchCount, equals(2));
    });

    test('5. Truyền force: true → luôn fetch lại lập tức dù cùng vị trí và chưa qua 30 phút', () async {
      final service = MockWeatherService();
      var now = DateTime(2026, 8, 4, 8, 0);
      final notifier = CurrentWeatherNotifier(service, now: () => now);

      await notifier.refreshIfNeeded(hue);
      expect(service.fetchCount, equals(1));

      // Mới trôi 1 phút, cùng vị trí nhưng có force: true (cập nhật thời tiết liên tục/manual tap)
      now = now.add(const Duration(minutes: 1));
      await notifier.refreshIfNeeded(hue, force: true);

      expect(service.fetchCount, equals(2));
    });
  });
}