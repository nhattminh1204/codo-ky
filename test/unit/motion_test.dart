import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/core/theme/motion.dart';

void main() {
  group('AppMotion Tokens Unit Tests', () {
    test('1. AppMotion durations follow design hierarchy', () {
      expect(AppMotion.micro.inMilliseconds, equals(150));
      expect(AppMotion.standard.inMilliseconds, equals(300));
      expect(AppMotion.emphasized.inMilliseconds, equals(450));

      expect(AppMotion.micro < AppMotion.standard, isTrue);
      expect(AppMotion.standard < AppMotion.emphasized, isTrue);
    });

    test('2. AppMotion curves are defined correctly with gentle overshoot', () {
      expect(AppMotion.standardCurve, equals(Curves.easeOutCubic));
      expect(AppMotion.emphasizedCurve, equals(Curves.easeOutBack));
      expect(AppMotion.springyCurve, equals(Curves.elasticOut));
    });

    test('3. AppMotion softSpring description parameters are physically balanced', () {
      expect(AppMotion.softSpring.mass, equals(1.0));
      expect(AppMotion.softSpring.stiffness, equals(180.0));
      expect(AppMotion.softSpring.damping, equals(20.0));
    });
  });
}
