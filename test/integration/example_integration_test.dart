import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

import 'package:codoky/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Tests', () {
    testWidgets('App launches and navigates', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify app loads
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}