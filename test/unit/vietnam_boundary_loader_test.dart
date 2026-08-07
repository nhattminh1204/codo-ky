import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/features/map/data/datasources/vietnam_boundary_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VietnamBoundaryLoader Unit Tests', () {
    test('1. loadBoundaryRings loads boundary asset and returns non-empty rings', () async {
      final rings = await VietnamBoundaryLoader.loadBoundaryRings();
      expect(rings, isNotNull);
      expect(rings, isNotEmpty);
      expect(rings!.first.length, greaterThanOrEqualTo(3));
    });

    test('2. loadBoundaryRing returns primary mainland ring', () async {
      final ring = await VietnamBoundaryLoader.loadBoundaryRing();
      expect(ring, isNotNull);
      expect(ring!.length, greaterThanOrEqualTo(3));
    });
  });
}
