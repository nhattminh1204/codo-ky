import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:codoky/core/config/app_config.dart';
import 'package:codoky/core/logging/app_logger.dart';
import 'package:codoky/core/network/api_client.dart';
import 'package:codoky/core/network/network_exceptions.dart';
import 'package:codoky/features/map/data/models/osrm_route_model.dart';

final osrmRemoteServiceProvider = Provider<OsrmRemoteService>((ref) {
  return OsrmRemoteService(
    apiClient: ref.watch(apiClientProvider),
    baseUrl: AppConfig.osrmBaseUrl,
  );
});

class OsrmRemoteService {
  final ApiClient apiClient;
  final String _baseUrl;

  OsrmRemoteService({
    required this.apiClient,
    String? baseUrl,
  })  : _baseUrl = (baseUrl != null && baseUrl.isNotEmpty)
            ? baseUrl
            : 'http://router.project-osrm.org';

  /// Fetches a real OSRM route from origin [start] to destination [end] for specified [profile].
  /// Profiles supported by OSRM public server:
  ///   - 'driving'    → xe ô tô / xe hơi
  ///   - 'bike'       → xe máy / xe đạp (motorbike maps to this)
  ///   - 'foot'       → đi bộ
  /// Fetches real driving routes from OSRM server with optional alternatives=true.
  /// Throws [NetworkExceptions] or [FormatException] if routing fails.
  /// NO mock data or fake straight line fallbacks allowed.
  Future<List<OsrmRoute>> getRoutes({
    required LatLng start,
    required LatLng end,
    String profile = 'driving',
    bool alternatives = true,
  }) async {
    final osrmProfile = switch (profile) {
      'motorbike' => 'bike',
      'walking' || 'foot' => 'foot',
      _ => 'driving',
    };
    final formattedCoords =
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';
    final altParam = alternatives ? '&alternatives=true' : '';
    final requestUri =
        '$_baseUrl/route/v1/$osrmProfile/$formattedCoords?overview=full&geometries=geojson&steps=true$altParam';

    AppLogger.i('🌐 Fetching real OSRM routes ($osrmProfile, alt=$alternatives): $requestUri');

    try {
      final responseData = await apiClient.get(requestUri);

      if (responseData is Map<String, dynamic>) {
        final code = responseData['code'] as String?;
        if (code != 'Ok') {
          final message = responseData['message'] as String? ?? 'OSRM error code: $code';
          AppLogger.e('❌ OSRM routing failed with status: $code ($message)');
          throw NetworkExceptions.custom('Không thể tìm tuyến đường OSRM: $message');
        }

        final routes = OsrmRoute.fromMultiRouteJson(responseData);
        AppLogger.i('✅ OSRM ${routes.length} route(s) fetched successfully');
        return routes;
      } else {
        throw const FormatException('Định dạng dữ liệu từ OSRM server không hợp lệ');
      }
    } catch (e) {
      if (_baseUrl != 'https://router.project-osrm.org') {
        AppLogger.w('⚠️ OSRM server ($_baseUrl) unreachable ($e). Falling back to public OSRM server (https://router.project-osrm.org)');
        return _fetchFromPublicOsrm(start: start, end: end, profile: profile, alternatives: alternatives);
      }
      AppLogger.e('❌ OSRM route request error: $e');
      if (e is DioException) {
        throw NetworkExceptions.getDioException(e);
      }
      throw NetworkExceptions.custom('Lỗi kết nối khi lấy tuyến đường OSRM: $e');
    }
  }

  Future<List<OsrmRoute>> _fetchFromPublicOsrm({
    required LatLng start,
    required LatLng end,
    required String profile,
    required bool alternatives,
  }) async {
    final osrmProfile = switch (profile) {
      'motorbike' => 'bike',
      'walking' || 'foot' => 'foot',
      _ => 'driving',
    };
    final formattedCoords =
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}';
    final altParam = alternatives ? '&alternatives=true' : '';
    final fallbackUri =
        'https://router.project-osrm.org/route/v1/$osrmProfile/$formattedCoords?overview=full&geometries=geojson&steps=true$altParam';

    AppLogger.i('🌐 Fallback fetching from public OSRM server: $fallbackUri');

    final responseData = await apiClient.get(fallbackUri);
    if (responseData is Map<String, dynamic>) {
      final code = responseData['code'] as String?;
      if (code != 'Ok') {
        final message = responseData['message'] as String? ?? 'OSRM error code: $code';
        throw NetworkExceptions.custom('Không thể tìm tuyến đường OSRM: $message');
      }
      final routes = OsrmRoute.fromMultiRouteJson(responseData);
      AppLogger.i('✅ OSRM fallback ${routes.length} route(s) fetched successfully');
      return routes;
    }
    throw const FormatException('Định dạng dữ liệu từ OSRM public server không hợp lệ');
  }

  Future<OsrmRoute> getDrivingRoute({
    required LatLng start,
    required LatLng end,
    String profile = 'driving',
  }) async {
    final routes = await getRoutes(start: start, end: end, profile: profile, alternatives: false);
    return routes.first;
  }

  /// Fetches a multi-waypoint OSRM route through [waypoints] in order.
  /// Returns a single [OsrmRoute] containing leg durations for each segment.
  /// Requires at least 2 waypoints. Throws on failure.
  Future<OsrmRoute> getMultiWaypointRoute({
    required List<LatLng> waypoints,
    String profile = 'driving',
  }) async {
    if (waypoints.length < 2) {
      throw ArgumentError('Cần ít nhất 2 điểm dừng để tính tuyến đường');
    }

    final osrmProfile = switch (profile) {
      'motorbike' => 'bike',
      'walking' || 'foot' => 'foot',
      _ => 'driving',
    };
    final formattedCoords = waypoints
        .map((w) => '${w.longitude},${w.latitude}')
        .join(';');
    final requestUri =
        '$_baseUrl/route/v1/$osrmProfile/$formattedCoords?overview=full&geometries=geojson&steps=true';

    AppLogger.i('🌐 Fetching multi-waypoint OSRM route ($osrmProfile, ${waypoints.length} waypoints): $requestUri');

    try {
      final responseData = await apiClient.get(requestUri);

      if (responseData is Map<String, dynamic>) {
        final code = responseData['code'] as String?;
        if (code != 'Ok') {
          final message = responseData['message'] as String? ?? 'OSRM error code: $code';
          AppLogger.e('❌ OSRM multi-waypoint routing failed: $code ($message)');
          throw NetworkExceptions.custom('Không thể tính lại tuyến đường: $message');
        }

        final route = OsrmRoute.fromJson(responseData);
        AppLogger.i('✅ OSRM multi-waypoint route fetched (${route.legDurations.length} legs)');
        return route;
      } else {
        throw const FormatException('Định dạng dữ liệu OSRM không hợp lệ');
      }
    } catch (e) {
      if (_baseUrl != 'https://router.project-osrm.org') {
        AppLogger.w('⚠️ OSRM multi-waypoint server ($_baseUrl) unreachable ($e). Falling back to public OSRM server');
        final fallbackUri =
            'https://router.project-osrm.org/route/v1/$osrmProfile/$formattedCoords?overview=full&geometries=geojson&steps=true';
        final responseData = await apiClient.get(fallbackUri);
        if (responseData is Map<String, dynamic>) {
          final code = responseData['code'] as String?;
          if (code == 'Ok') {
            return OsrmRoute.fromJson(responseData);
          }
        }
      }
      AppLogger.e('❌ OSRM multi-waypoint route error: $e');
      if (e is DioException) {
        throw NetworkExceptions.getDioException(e);
      }
      throw NetworkExceptions.custom('Lỗi kết nối OSRM: $e');
    }
  }
}
