import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/features/map/utils/marker_overlap_resolver.dart';

void main() {
  group('MarkerOverlapResolver Tests', () {
    test('1. Returns non-zero offsets when 2 markers are closer than threshold (40px)', () {
      final positions = [
        const MapEntry('marker1', Offset(100.0, 100.0)),
        const MapEntry('marker2', Offset(110.0, 105.0)), // Distance approx 11.18px < 40px
      ];

      final offsets = MarkerOverlapResolver.resolveOverlaps(
        screenPositions: positions,
        threshold: 40.0,
      );

      expect(offsets['marker1'], isNot(equals(Offset.zero)));
      expect(offsets['marker2'], isNot(equals(Offset.zero)));
    });

    test('2. Returns zero offset when markers are further than threshold (40px)', () {
      final positions = [
        const MapEntry('marker1', Offset(100.0, 100.0)),
        const MapEntry('marker2', Offset(200.0, 200.0)), // Distance 141.4px > 40px
      ];

      final offsets = MarkerOverlapResolver.resolveOverlaps(
        screenPositions: positions,
        threshold: 40.0,
      );

      expect(offsets['marker1'], equals(Offset.zero));
      expect(offsets['marker2'], equals(Offset.zero));
    });
  });
}
