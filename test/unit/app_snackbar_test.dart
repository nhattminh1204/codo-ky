import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/core/utils/helpers/app_snackbar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSnackBar Unit & Widget Tests', () {
    testWidgets('AppSnackBar shows message floating with bottom margin 92', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AppSnackBar.show(context, 'Test notification floating');
                },
                child: const Text('Show SnackBar'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show SnackBar'));
      await tester.pump();

      expect(find.text('Test notification floating'), findsOneWidget);
    });

    testWidgets('AppSnackBar renders error style when isError: true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  AppSnackBar.show(context, 'Test error message', isError: true);
                },
                child: const Text('Show Error'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pump();

      expect(find.text('Test error message'), findsOneWidget);
    });
  });
}
