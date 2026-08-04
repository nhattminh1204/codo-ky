import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/logging/app_logger.dart';

/// Loads the static administrative boundary of Thành phố Huế from the bundled
/// GeoJSON asset (`assets/data/hue_boundary.geojson`).
///
/// The data is static and bundled with the app (no network call at runtime),
/// mirroring how `hue_places_seed.json` is consumed.
class HueBoundaryLoader {
  HueBoundaryLoader._();

  static List<LatLng>? _cachedRing;

  /// Returns the outer boundary ring of Thành phố Huế as a closed list of
  /// `LatLng`s (`[lon, lat]` order from GeoJSON is swapped to `[lat, lng]`).
  ///
  /// Loaded exactly once per app session and cached. Returns `null` if the
  /// asset is missing or malformed.
  static Future<List<LatLng>?> loadBoundaryRing() async {
    if (_cachedRing != null) return _cachedRing;
    try {
      final raw =
          await rootBundle.loadString('assets/data/hue_boundary.geojson');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>;
      if (features.isEmpty) {
        AppLogger.w('HueBoundaryLoader: GeoJSON has no features.');
        return null;
      }

      final geometry =
          (features.first as Map<String, dynamic>)['geometry']
              as Map<String, dynamic>;
      // MultiPolygon -> first polygon -> outer ring.
      final coordinates = geometry['coordinates'] as List<dynamic>;
      final polygon = coordinates.first as List<dynamic>;
      final ring = polygon.first as List<dynamic>;

      final latLngs = <LatLng>[
        for (final c in ring)
          LatLng((c as List<dynamic>)[1] as double, c[0] as double),
      ];

      if (latLngs.isEmpty) {
        AppLogger.w('HueBoundaryLoader: boundary ring is empty.');
        return null;
      }
      return _cachedRing = latLngs;
    } catch (e) {
      AppLogger.w('HueBoundaryLoader: failed to parse boundary: $e');
      return null;
    }
  }
}