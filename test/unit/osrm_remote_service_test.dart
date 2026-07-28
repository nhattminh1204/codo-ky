import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:codoky/features/map/data/models/osrm_route_model.dart';
import 'package:codoky/features/map/data/models/osrm_step_model.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';

void main() {
  group('OsrmRoute Model & OSRM GeoJSON Parsing Tests', () {
    test('1. OsrmRoute.fromJson parses valid OSRM response correctly', () {
      final sampleOsrmJson = {
        'code': 'Ok',
        'routes': [
          {
            'distance': 3457.9,
            'duration': 262.2,
            'weight_name': 'routability',
            'weight': 262.2,
            'geometry': {
              'type': 'LineString',
              'coordinates': [
                [107.5909, 16.4637],
                [107.5850, 16.4500],
                [107.5833, 16.4439]
              ]
            },
            'legs': [
              {
                'summary': 'Đường Lê Lợi',
                'distance': 3457.9,
                'duration': 262.2,
              }
            ]
          }
        ]
      };

      final route = OsrmRoute.fromJson(sampleOsrmJson);

      expect(route.points.length, equals(3));
      expect(route.points[0], equals(const LatLng(16.4637, 107.5909)));
      expect(route.points[2], equals(const LatLng(16.4439, 107.5833)));
      expect(route.distanceMeters, equals(3457.9));
      expect(route.durationSeconds, equals(262.2));
      expect(route.formattedDistance, equals('3.5 km'));
      expect(route.formattedDuration, equals('5 phút'));
      expect(route.summary, equals('Đường Lê Lợi'));
    });

    test('2. OsrmRoute.fromJson formats short distances in meters', () {
      final shortRouteJson = {
        'code': 'Ok',
        'routes': [
          {
            'distance': 450.0,
            'duration': 45.0,
            'geometry': {
              'type': 'LineString',
              'coordinates': [
                [107.5909, 16.4637],
                [107.5915, 16.4640]
              ]
            }
          }
        ]
      };

      final route = OsrmRoute.fromJson(shortRouteJson);
      expect(route.formattedDistance, equals('450 m'));
      expect(route.formattedDuration, equals('1 phút'));
    });

    test('3. OsrmRoute.fromJson throws FormatException when routes array is empty', () {
      final invalidJson = {'code': 'Ok', 'routes': []};

      expect(
        () => OsrmRoute.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('4. OsrmRoute.fromJson throws FormatException when geometry coordinates are missing', () {
      final invalidJson = {
        'code': 'Ok',
        'routes': [
          {'distance': 100}
        ]
      };

      expect(
        () => OsrmRoute.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('5. MapState travelMode default and copyWith work as expected', () {

      const state = MapState();
      expect(state.travelMode, equals('motorbike'));

      final updatedState = state.copyWith(travelMode: 'foot');
      expect(updatedState.travelMode, equals('foot'));
    });

    test('6. OsrmStep.fromJson parses maneuver instructions correctly', () {

      final stepJson = {
        'name': 'Đường Nguyễn Huệ',
        'distance': 250.0,
        'duration': 30.0,
        'maneuver': {
          'type': 'turn',
          'modifier': 'left',
          'location': [107.5850, 16.4500]
        }
      };

      final step = OsrmStep.fromJson(stepJson);
      expect(step.streetName, equals('Đường Nguyễn Huệ'));
      expect(step.distanceMeters, equals(250.0));
      expect(step.instruction, equals('Rẽ trái vào Đường Nguyễn Huệ'));
      expect(step.location, equals(const LatLng(16.4500, 107.5850)));
    });
  });
}


