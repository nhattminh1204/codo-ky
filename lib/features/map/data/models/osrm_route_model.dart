import 'package:latlong2/latlong.dart';
import 'package:codoky/features/map/data/models/osrm_step_model.dart';

/// Representation of an OSRM driving route between coordinates.
class OsrmRoute {
  final List<LatLng> points;
  final List<OsrmStep> steps;
  final double distanceMeters;
  final double durationSeconds;
  final String summary;
  final List<double> legDurations;

  const OsrmRoute({
    required this.points,
    this.steps = const [],
    required this.distanceMeters,
    required this.durationSeconds,
    this.summary = '',
    this.legDurations = const [],
  });

  /// Distance formatted in kilometers (or meters if < 1km)
  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)} m';
    }
    final km = distanceMeters / 1000.0;
    return '${km.toStringAsFixed(1)} km';
  }

  /// Duration formatted in minutes / hours
  String get formattedDuration {
    final minutes = (durationSeconds / 60.0).ceil();
    if (minutes < 60) {
      return '$minutes phút';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours giờ';
    }
    return '$hours giờ $remainingMinutes phút';
  }

  /// Creates an [OsrmRoute] from OSRM JSON response GeoJSON format
  factory OsrmRoute.fromJson(Map<String, dynamic> json) {
    final routes = json['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw const FormatException('Không tìm thấy tuyến đường hợp lệ');
    }

    final primaryRoute = routes.first as Map<String, dynamic>;
    final geometry = primaryRoute['geometry'] as Map<String, dynamic>?;
    if (geometry == null) {
      throw const FormatException('Dữ liệu tọa độ tuyến đường không hợp lệ');
    }

    final coordinates = geometry['coordinates'] as List<dynamic>?;
    if (coordinates == null || coordinates.isEmpty) {
      throw const FormatException('Không có dữ liệu tọa độ đường đi');
    }

    final points = <LatLng>[];
    for (final coord in coordinates) {
      if (coord is List && coord.length >= 2) {
        final lng = (coord[0] as num).toDouble();
        final lat = (coord[1] as num).toDouble();
        points.add(LatLng(lat, lng));
      }
    }

    final distance = (primaryRoute['distance'] as num?)?.toDouble() ?? 0.0;
    final duration = (primaryRoute['duration'] as num?)?.toDouble() ?? 0.0;

    String routeSummary = '';
    final stepsList = <OsrmStep>[];
    final legDurationsList = <double>[];
    final legs = primaryRoute['legs'] as List<dynamic>?;
    if (legs != null && legs.isNotEmpty) {
      final firstLeg = legs.first as Map<String, dynamic>;
      routeSummary = firstLeg['summary'] as String? ?? '';
      
      for (final legRaw in legs) {
        if (legRaw is Map<String, dynamic>) {
          final legDuration = (legRaw['duration'] as num?)?.toDouble() ?? 0.0;
          legDurationsList.add(legDuration);
          
          final rawSteps = legRaw['steps'] as List<dynamic>?;
          if (rawSteps != null) {
            for (final rawStep in rawSteps) {
              if (rawStep is Map<String, dynamic>) {
                stepsList.add(OsrmStep.fromJson(rawStep));
              }
            }
          }
        }
      }
    }

    return OsrmRoute(
      points: points,
      steps: stepsList,
      distanceMeters: distance,
      durationSeconds: duration,
      summary: routeSummary,
      legDurations: legDurationsList,
    );
  }

  /// Parses multiple routes from OSRM JSON response when alternatives=true
  static List<OsrmRoute> fromMultiRouteJson(Map<String, dynamic> json) {
    final routesRaw = json['routes'] as List<dynamic>?;
    if (routesRaw == null || routesRaw.isEmpty) {
      throw const FormatException('Không tìm thấy tuyến đường hợp lệ');
    }

    final result = <OsrmRoute>[];
    for (final routeMap in routesRaw) {
      if (routeMap is Map<String, dynamic>) {
        result.add(OsrmRoute.fromJson({'routes': [routeMap]}));
      }
    }
    return result;
  }
}


