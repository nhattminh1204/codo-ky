import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/features/map/presentation/widgets/place_marker.dart';

void main() {
  group('PlaceMarker Widget & State Tests', () {
    testWidgets('1. Renders default orange marker', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlaceMarker(
              category: 'attraction',
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PlaceMarker), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_rounded), findsOneWidget);

      final animatedScale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(animatedScale.scale, equals(1.0));
      expect(animatedScale.duration, equals(const Duration(milliseconds: 450)));
      expect(animatedScale.curve, equals(Curves.easeInOutCubic));
    });

    testWidgets('2. Renders selected state with 1.16x scale and EaseInOutCubic animation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlaceMarker(
              category: 'cafe',
              state: PlaceMarkerState.selected,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PlaceMarker), findsOneWidget);
      expect(find.byIcon(Icons.local_cafe_rounded), findsOneWidget);

      final animatedScale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(animatedScale.scale, equals(1.16));
      expect(animatedScale.duration, equals(const Duration(milliseconds: 450)));
      expect(animatedScale.curve, equals(Curves.easeInOutCubic));
    });

    testWidgets('3. Renders saved state with heart badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlaceMarker(
              category: 'food',
              isSaved: true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PlaceMarker), findsOneWidget);
      expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('4. Renders featured state with star badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlaceMarker(
              category: 'temple',
              state: PlaceMarkerState.featured,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PlaceMarker), findsOneWidget);
      expect(find.byIcon(Icons.temple_buddhist_rounded), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('5. Deselecting marker restores scale to 1.0 default state', (WidgetTester tester) async {
      bool isSelected = true;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    PlaceMarker(
                      category: 'hotel',
                      isSelected: isSelected,
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => isSelected = false),
                      child: const Text('Deselect'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
      await tester.pump();

      var scaleWidget = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(scaleWidget.scale, equals(1.16));

      // Tap deselect
      await tester.tap(find.text('Deselect'));
      await tester.pump(const Duration(milliseconds: 700));

      scaleWidget = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(scaleWidget.scale, equals(1.0));
    });

    testWidgets('6. Renders BOTH Saved and Featured badges simultaneously (heart top-right, star top-left)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlaceMarker(
              category: 'attraction',
              isSaved: true,
              isFeatured: true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PlaceMarker), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('7. Renders Selected + Saved state simultaneously with 1.16x scale and heart badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlaceMarker(
              category: 'food',
              isSelected: true,
              isSaved: true,
            ),
          ),
        ),
      );
      await tester.pump();

      final animatedScale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
      expect(animatedScale.scale, equals(1.16));
      expect(find.byIcon(Icons.restaurant_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });
  });
}
