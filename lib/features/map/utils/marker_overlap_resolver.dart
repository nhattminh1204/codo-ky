import 'package:flutter/material.dart';
import 'package:codoky/features/map/presentation/widgets/marker_constants.dart';

/// Helper class to resolve visual overlaps between unclustered markers.
class MarkerOverlapResolver {
  MarkerOverlapResolver._();

  /// Calculates smooth screen displacement offsets for unclustered markers.
  /// [screenPositions]: Map entries of marker id to screen pixel coordinate.
  /// Returns a map of displacement [Offset] for each marker id.
  static Map<String, Offset> resolveOverlaps({
    required List<MapEntry<String, Offset>> screenPositions,
    double threshold = MarkerConstants.overlapThresholdPx,
  }) {
    final offsets = <String, Offset>{};
    for (var i = 0; i < screenPositions.length; i++) {
      final a = screenPositions[i];
      Offset adjust = Offset.zero;
      for (var j = 0; j < screenPositions.length; j++) {
        if (i == j) continue;
        final b = screenPositions[j];
        final delta = a.value - b.value;
        final dist = delta.distance;
        if (dist < threshold && dist > 0) {
          final pushStrength = (threshold - dist) / threshold;
          adjust += delta / dist * pushStrength * 6.0;
        }
      }
      offsets[a.key] = adjust;
    }
    return offsets;
  }
}
