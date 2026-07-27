import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/features/explore/presentation/providers/explore_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExploreNotifier Unit Tests', () {
    test('initial state should have default values', () {
      final state = ExploreState();
      expect(state.allPlaces, isEmpty);
      expect(state.restaurants, isEmpty);
      expect(state.attractions, isEmpty);
      expect(state.temples, isEmpty);
      expect(state.tombs, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.selectedCategory, isNull);
    });

    test('loadPlaces loads seed data correctly', () async {
      final notifier = ExploreNotifier();
      await notifier.loadPlaces(refresh: true);

      expect(notifier.state.allPlaces, isNotEmpty);
      expect(notifier.state.categories, isNotEmpty);
      expect(notifier.state.isLoading, isFalse);
    });

    test('selectCategory updates selectedCategory state', () {
      final notifier = ExploreNotifier();
      notifier.selectCategory('temple');
      expect(notifier.state.selectedCategory, equals('temple'));

      notifier.selectCategory('all');
      expect(notifier.state.selectedCategory, isNull);
    });

    test('searchPlaces updates searchQuery', () {
      final notifier = ExploreNotifier();
      notifier.searchPlaces('Đại Nội');
      expect(notifier.state.searchQuery, equals('Đại Nội'));
    });
  });
}
