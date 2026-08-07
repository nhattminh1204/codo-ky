import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/logging/app_logger.dart';

/// Loads the static boundary polygon rings of Vietnam (Mainland, Hoang Sa, Truong Sa, Phu Quoc)
/// from `assets/data/vietnam_boundary.geojson` with Catmull-Rom spline smoothing.
class VietnamBoundaryLoader {
  VietnamBoundaryLoader._();

  static List<List<LatLng>>? _cachedRings;

  /// Returns all boundary rings of Vietnam (Mainland + Islands) as a list of `List<LatLng>`.
  static Future<List<List<LatLng>>?> loadBoundaryRings() async {
    if (_cachedRings != null) return _cachedRings;
    try {
      final raw = await rootBundle.loadString('assets/data/vietnam_boundary.geojson');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>;
      final rawRings = <List<LatLng>>[];

      for (final feat in features) {
        final geometry = (feat as Map<String, dynamic>)['geometry'] as Map<String, dynamic>;
        final type = geometry['type'] as String;
        final coordinates = geometry['coordinates'] as List<dynamic>;

        if (type == 'MultiPolygon') {
          for (final poly in coordinates) {
            final ringRaw = (poly as List<dynamic>).first as List<dynamic>;
            final latLngs = <LatLng>[
              for (final c in ringRaw)
                LatLng(((c as List<dynamic>)[1] as num).toDouble(), (c[0] as num).toDouble()),
            ];
            if (latLngs.isNotEmpty) rawRings.add(latLngs);
          }
        } else if (type == 'Polygon') {
          final ringRaw = coordinates.first as List<dynamic>;
          final latLngs = <LatLng>[
            for (final c in ringRaw)
              LatLng(((c as List<dynamic>)[1] as num).toDouble(), (c[0] as num).toDouble()),
          ];
          if (latLngs.isNotEmpty) rawRings.add(latLngs);
        }
      }

      return _cachedRings = rawRings;
    } catch (e) {
      AppLogger.w('VietnamBoundaryLoader: failed to parse boundary: $e');
      return null;
    }
  }

  /// Backward compatibility helper returning the primary ring (Mainland Vietnam).
  static Future<List<LatLng>?> loadBoundaryRing() async {
    final rings = await loadBoundaryRings();
    return rings?.first;
  }
}
