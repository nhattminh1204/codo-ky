import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/logging/app_logger.dart';

/// Loads the static boundary polygon of Vietnam from `assets/data/vietnam_boundary.geojson`.
class VietnamBoundaryLoader {
  VietnamBoundaryLoader._();

  static List<LatLng>? _cachedRing;

  /// Returns the outer boundary ring of Vietnam as a closed list of `LatLng`s.
  static Future<List<LatLng>?> loadBoundaryRing() async {
    if (_cachedRing != null) return _cachedRing;
    try {
      final raw = await rootBundle.loadString('assets/data/vietnam_boundary.geojson');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>;
      if (features.isEmpty) return null;

      final geometry = (features.first as Map<String, dynamic>)['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List<dynamic>;
      final ring = (coordinates.first as List<dynamic>);

      final latLngs = <LatLng>[
        for (final c in ring)
          LatLng((c as List<dynamic>)[1] as double, (c[0] as double)),
      ];

      return _cachedRing = latLngs;
    } catch (e) {
      AppLogger.w('VietnamBoundaryLoader: failed to parse boundary: $e');
      return null;
    }
  }
}
