import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:codoky/features/map/presentation/providers/map_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapNotifier & MapState Unit Tests', () {
    late MapNotifier mapNotifier;

    setUp(() {
      mapNotifier = MapNotifier();
    });

    test('1. Initial MapState has default empty values', () {
      final state = mapNotifier.state;

      expect(state.allPlaces, isEmpty);
      expect(state.places, isEmpty);
      expect(state.selectedPlace, isNull);
      expect(state.selectedCategory, isNull);
      expect(state.selectedCategories, isEmpty);
      expect(state.searchQuery, isEmpty);
      expect(state.isLoading, isFalse);
    });

    test('2. loadPlaces initializes places and fallback dataset safely', () async {
      await mapNotifier.loadPlaces();
      final state = mapNotifier.state;

      expect(state.isLoading, isFalse);
      expect(state.allPlaces, isNotEmpty);
      expect(state.places, isNotEmpty);
      expect(state.currentLocation, equals(const LatLng(16.4637, 107.5909)));
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
  });
}
