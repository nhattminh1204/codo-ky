import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:codoky/core/services/weather/weather_service.dart';
import 'package:codoky/core/services/weather/weather_forecast_model.dart';
import 'package:codoky/core/utils/helpers/geo_helpers.dart';

/// Ngưỡng cache thời tiết hiện tại: chỉ refetch khi vị trí dịch chuyển
/// nhiều hơn [kCurrentWeatherMaxDistanceKm] km HOẶC đã quá [kCurrentWeatherMaxAge]
/// kể từ lần fetch cuối.
const double kCurrentWeatherMaxDistanceKm = 10;
const Duration kCurrentWeatherMaxAge = Duration(minutes: 30);

/// State của [CurrentWeatherNotifier]: kết quả API (dưới dạng AsyncValue)
/// + metadata vị trí/thời gian lần fetch cuối để phục vụ cache.
class CurrentWeatherState {
  final AsyncValue<CurrentWeatherResult> currentWeather;
  final LatLng? lastFetchedPosition;
  final DateTime? lastFetchedAt;

  const CurrentWeatherState({
    this.currentWeather = const AsyncValue<CurrentWeatherResult>.loading(),
    this.lastFetchedPosition,
    this.lastFetchedAt,
  });

  CurrentWeatherState copyWith({
    AsyncValue<CurrentWeatherResult>? currentWeather,
    LatLng? lastFetchedPosition,
    bool clearLastFetchedPosition = false,
    DateTime? lastFetchedAt,
  }) {
    return CurrentWeatherState(
      currentWeather: currentWeather ?? this.currentWeather,
      lastFetchedPosition: clearLastFetchedPosition
          ? null
          : (lastFetchedPosition ?? this.lastFetchedPosition),
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
    );
  }
}

/// Quản lý thời tiết hiện tại cho bản đồ, có cache theo vị trí + thời gian.
///
/// KHÔNG gắn vào onLocationUpdate stream (chạy liên tục). Thay vào đó gọi
/// [refreshIfNeeded] 1 lần khi map khởi tạo; nội bộ tự quyết định có gọi API
/// hay không dựa trên khoảng cách ([kCurrentWeatherMaxDistanceKm]) và tuổi dữ
/// liệu ([kCurrentWeatherMaxAge]).
class CurrentWeatherNotifier extends StateNotifier<CurrentWeatherState> {
  final WeatherService _service;

  /// Nguồn thời gian — inject được để test (giả lập trôi nhanh 30 phút).
  final DateTime Function() _now;

  CurrentWeatherNotifier(this._service, {DateTime Function()? now})
      : _now = now ?? DateTime.now,
        super(const CurrentWeatherState());

  bool get hasWeather => state.currentWeather.hasValue;

  /// Fetch thời tiết cho [newPosition] nếu cần (vị trí null/đổi >10km/đã >30 phút).
  Future<void> refreshIfNeeded(LatLng newPosition) async {
    final lastPos = state.lastFetchedPosition;
    final lastAt = state.lastFetchedAt;

    final bool shouldFetch;
    if (lastPos == null || lastAt == null) {
      // Lần đầu tiên: chưa từng fetch → luôn gọi.
      shouldFetch = true;
    } else {
      final distanceKm = GeoHelpers.distanceMeters(lastPos, newPosition) / 1000.0;
      final age = _now().difference(lastAt);
      shouldFetch = distanceKm > kCurrentWeatherMaxDistanceKm || age > kCurrentWeatherMaxAge;
    }

    if (!shouldFetch) return;

    state = state.copyWith(
      currentWeather: const AsyncValue<CurrentWeatherResult>.loading(),
    );

    try {
      final result = await _service.fetchCurrentWeather(
        latitude: newPosition.latitude,
        longitude: newPosition.longitude,
      );
      state = state.copyWith(
        currentWeather: AsyncValue.data(result),
        lastFetchedPosition: newPosition,
        lastFetchedAt: _now(),
      );
    } catch (e, st) {
      // GIỮ lại dữ liệu cũ + metadata nếu có để UI không crash giữa chừng.
      state = state.copyWith(
        currentWeather: AsyncValue.error(e, st),
      );
    }
  }
}

/// Provider cho [CurrentWeatherNotifier], dùng chung [weatherServiceProvider]
/// (có Dio timeout/retry) đã khai báo trong weather_service.dart.
final currentWeatherProvider =
    StateNotifierProvider<CurrentWeatherNotifier, CurrentWeatherState>((ref) {
  final service = ref.watch(weatherServiceProvider);
  return CurrentWeatherNotifier(service);
});