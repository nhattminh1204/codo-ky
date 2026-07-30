import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/shared/widgets/app_open_container.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppOpenContainer Widget Tests', () {
    testWidgets('AppOpenContainer renders closedBuilder widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppOpenContainer(
              closedBuilder: (context, openContainer) {
                return ElevatedButton(
                  onPressed: openContainer,
                  child: const Text('Open Detail'),
                );
              },
              openBuilder: (context, closeContainer) {
                return const Scaffold(
                  body: Text('Detail Screen Content'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Open Detail'), findsOneWidget);
      expect(find.text('Detail Screen Content'), findsNothing);
    });

    testWidgets('AppOpenContainer transitions to openBuilder when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppOpenContainer(
              closedBuilder: (context, openContainer) {
                return ElevatedButton(
                  onPressed: openContainer,
                  child: const Text('Open Detail'),
                );
              },
              openBuilder: (context, closeContainer) {
                return const Scaffold(
                  body: Text('Detail Screen Content'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Detail'));
      await tester.pumpAndSettle();

      expect(find.text('Detail Screen Content'), findsOneWidget);
    });
  });
}
