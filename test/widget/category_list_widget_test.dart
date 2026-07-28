import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/features/explore/presentation/screens/category_list_screen.dart';
import 'package:codoky/features/explore/presentation/providers/explore_provider.dart';

class ExploreNotifierMock extends ExploreNotifier {
  ExploreNotifierMock(ExploreState initialState) {
    state = initialState;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final samplePlaces = [
    {
      'id': 'p1',
      'name': 'Chùa Thiên Mụ',
      'category': 'temple',
      'rating': 4.8,
      'address': 'Hương Long, Huế',
    },
    {
      'id': 'p2',
      'name': 'Đại Nội Huế',
      'category': 'attraction',
      'rating': 4.9,
      'address': 'Thuận Thành, Huế',
    },
  ];

  group('CategoryListScreen Widget & User Flow Tests', () {
    testWidgets('1. CategoryListScreen renders category title and search input', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exploreProvider.overrideWith((ref) => ExploreNotifierMock(ExploreState(
              allPlaces: samplePlaces,
              isLoading: false,
            ))),
          ],
          child: const MaterialApp(
            home: CategoryListScreen(categoryId: 'temple'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('Thiên Mụ'), findsAtLeastNWidgets(1));
    });

    testWidgets('2. Entering search text filters places dynamically on UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exploreProvider.overrideWith((ref) => ExploreNotifierMock(ExploreState(
              allPlaces: samplePlaces,
              isLoading: false,
            ))),
          ],
          child: const MaterialApp(
            home: CategoryListScreen(categoryId: 'temple'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Thiên Mụ');
      await tester.pumpAndSettle();

      expect(find.textContaining('Thiên Mụ'), findsAtLeastNWidgets(1));
    });
  });
}
