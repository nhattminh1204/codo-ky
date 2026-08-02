import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/features/map/presentation/widgets/marker_constants.dart';

void main() {
  group('MarkerConstants Sizing & Standards Tests', () {
    test('1. Calculates visibleSize as 10% increase from baseSize (42.0 -> 46.2)', () {
      expect(MarkerConstants.baseSize, equals(42.0));
      expect(MarkerConstants.sizeIncreaseFactor, equals(1.10));
      expect(MarkerConstants.visibleSize, closeTo(46.2, 0.001));
    });

    test('2. Guarantees touchTargetSize is at least 44.0px', () {
      expect(MarkerConstants.minTouchTarget, equals(44.0));
      expect(MarkerConstants.touchTargetSize, greaterThanOrEqualTo(44.0));
      expect(MarkerConstants.touchTargetSize, equals(MarkerConstants.visibleSize));
    });

    test('3. Calculates invisiblePadding correctly when visibleSize < minTouchTarget', () {
      expect(MarkerConstants.invisiblePadding, equals(0.0));
    });

    test('4. Selected scale is 1.16x applied on top of visibleSize', () {
      expect(MarkerConstants.selectedScale, equals(1.16));
      final selectedVisibleSize = MarkerConstants.visibleSize * MarkerConstants.selectedScale;
      expect(selectedVisibleSize, closeTo(53.592, 0.001));
    });
  });
}
