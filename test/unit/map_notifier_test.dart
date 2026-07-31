import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:codoky/core/network/api_client.dart';
import 'package:codoky/core/network/network_exceptions.dart';
import 'package:codoky/features/map/data/datasources/osrm_remote_service.dart';
import 'package:codoky/features/map/data/models/osrm_route_model.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';

class MockSuccessOsrmRemoteService implements OsrmRemoteService {
  @override
  ApiClient get apiClient => throw UnimplementedError();

  @override
  Future<List<OsrmRoute>> getRoutes({required LatLng start, required LatLng end, String profile = 'driving', bool alternatives = true}) async {
    return [
      OsrmRoute(
        points: [start, const LatLng(16.4500, 107.5850), end],
        distanceMeters: 2500,
        durationSeconds: 180,
        summary: 'Đường Nguyễn Huệ',
      )
    ];
  }

  @override
  Future<OsrmRoute> getDrivingRoute({required LatLng start, required LatLng end, String profile = 'driving'}) async {
    final routes = await getRoutes(start: start, end: end, profile: profile);
    return routes.first;
  }
}

class MockErrorOsrmRemoteService implements OsrmRemoteService {
  @override
  ApiClient get apiClient => throw UnimplementedError();

  @override
  Future<List<OsrmRoute>> getRoutes({required LatLng start, required LatLng end, String profile = 'driving', bool alternatives = true}) async {
    throw NetworkExceptions.custom('Không thể tìm tuyến đường OSRM');
  }

  @override
  Future<OsrmRoute> getDrivingRoute({required LatLng start, required LatLng end, String profile = 'driving'}) async {
    throw NetworkExceptions.custom('Không thể tìm tuyến đường OSRM');
  }
}



class FakeErrorAssetBundle extends Fake implements AssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    throw const FormatException('Simulated asset parse error');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapNotifier & MapState Unit Tests', () {
    late MapNotifier mapNotifier;

    setUp(() {
      mapNotifier = MapNotifier();
    });

    test('1. Initial MapState has default empty values and null activeRoute', () {
      final state = mapNotifier.state;

      expect(state.allPlaces, isEmpty);
      expect(state.places, isEmpty);
      expect(state.selectedPlace, isNull);
      expect(state.selectedCategory, isNull);
      expect(state.selectedCategories, isEmpty);
      expect(state.searchQuery, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.activeRoute, isNull);
      expect(state.isFetchingRoute, isFalse);
      expect(state.routeErrorMessage, isNull);
    });

    test('2. loadPlaces initializes places dataset safely', () async {
      await mapNotifier.loadPlaces();
      final state = mapNotifier.state;

      expect(state.isLoading, isFalse);
      expect(state.allPlaces, isNotEmpty);
      expect(state.places, isNotEmpty);
      expect(state.errorMessage, isNull);
      expect(state.currentLocation, isNull);
    });

    test('2b. loadPlaces handles asset/parse error by setting errorMessage without hardcoded fallback', () async {
      await mapNotifier.loadPlaces(bundle: FakeErrorAssetBundle());
      final state = mapNotifier.state;

      expect(state.isLoading, isFalse);
      expect(state.allPlaces, isEmpty);
      expect(state.places, isEmpty);
      expect(state.errorMessage, equals('Không thể tải dữ liệu địa điểm. Vui lòng thử lại!'));

      final hasHardcodedItem = state.allPlaces.any((p) =>
        p['name'] == 'Huế Imperial City' || p['name'] == 'Thiên Mụ Pagoda'
      );
      expect(hasHardcodedItem, isFalse);
    });

    test('2c. loadPlaces skips redundant reload when forceRefresh is false and places exist', () async {
      await mapNotifier.loadPlaces();
      final initialPlaces = mapNotifier.state.places;

      await mapNotifier.loadPlaces(bundle: FakeErrorAssetBundle());
      final updatedState = mapNotifier.state;

      expect(updatedState.places, equals(initialPlaces));
      expect(updatedState.errorMessage, isNull);

      await mapNotifier.loadPlaces(forceRefresh: true, bundle: FakeErrorAssetBundle());
      expect(mapNotifier.state.errorMessage, equals('Không thể tải dữ liệu địa điểm. Vui lòng thử lại!'));
    });

    test('3. filterByCategory filters places matching category accurately', () async {
      await mapNotifier.loadPlaces();

      mapNotifier.filterByCategory('temple');
      final filtered = mapNotifier.state.places;

      expect(mapNotifier.state.selectedCategory, equals('temple'));
      for (final p in filtered) {
        final cat = (p['category'] as String?)?.toLowerCase() ?? '';
        final isMatch = cat.contains('temple') || cat.contains('chùa') || cat.contains('tâm linh');
        expect(isMatch, isTrue);
      }
    });

    test('4. setSearchQuery filters places by search keyword', () async {
      await mapNotifier.loadPlaces();

      mapNotifier.setSearchQuery('Thiên Mụ');
      final filtered = mapNotifier.state.places;

      expect(mapNotifier.state.searchQuery, equals('Thiên Mụ'));
      for (final p in filtered) {
        final name = (p['name'] as String?) ?? '';
        final address = (p['address'] as String?) ?? '';
        final containsQuery = name.contains('Thiên Mụ') || address.contains('Thiên Mụ');
        expect(containsQuery, isTrue);
      }
    });

    test('5. selectPlace and clearSelection manage selected place state correctly', () {
      final samplePlace = {'id': '10', 'name': 'Đại Nội'};

      mapNotifier.selectPlace(samplePlace);
      expect(mapNotifier.state.selectedPlace, equals(samplePlace));

      mapNotifier.clearSelection();
      expect(mapNotifier.state.selectedPlace, isNull);
    });

    test('6. fetchRouteToPlace success sets activeRoute and clears error', () async {
      final notifier = MapNotifier(osrmRemoteService: MockSuccessOsrmRemoteService());
      final place = {'id': '2', 'name': 'Chùa Thiên Mụ', 'latitude': 16.4439, 'longitude': 107.5833};

      final result = await notifier.fetchRouteToPlace(place);

      expect(result, isTrue);
      expect(notifier.state.activeRoute, isNotNull);
      expect(notifier.state.activeRoute!.points.length, equals(3));
      expect(notifier.state.activeRoute!.formattedDistance, equals('2.5 km'));
      expect(notifier.state.isFetchingRoute, isFalse);
      expect(notifier.state.routeErrorMessage, isNull);
    });

    test('7. fetchRouteToPlace error clears activeRoute and sets routeErrorMessage (NO FAKE LINE)', () async {
      final notifier = MapNotifier(osrmRemoteService: MockErrorOsrmRemoteService());
      final place = {'id': '2', 'name': 'Chùa Thiên Mụ', 'latitude': 16.4439, 'longitude': 107.5833};

      final result = await notifier.fetchRouteToPlace(place);

      expect(result, isFalse);
      expect(notifier.state.activeRoute, isNull);
      expect(notifier.state.isFetchingRoute, isFalse);
      expect(notifier.state.routeErrorMessage, contains('Không thể tìm tuyến đường OSRM'));
    });

    test('8. clearRoute removes activeRoute and routeErrorMessage from state', () async {
      final notifier = MapNotifier(osrmRemoteService: MockSuccessOsrmRemoteService());
      final place = {'id': '2', 'name': 'Chùa Thiên Mụ', 'latitude': 16.4439, 'longitude': 107.5833};

      await notifier.fetchRouteToPlace(place);
      expect(notifier.state.activeRoute, isNotNull);

      notifier.clearRoute();
      expect(notifier.state.activeRoute, isNull);
      expect(notifier.state.routeErrorMessage, isNull);
    });
  });
}
