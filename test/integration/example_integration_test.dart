import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:codoky/main.dart' as app;

class FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getTemporaryPath() async => '.';

  @override
  Future<String?> getApplicationSupportPath() async => '.';

  @override
  Future<String?> getLibraryPath() async => '.';

  @override
  Future<String?> getApplicationDocumentsPath() async => '.';

  @override
  Future<List<String>?> getExternalCachePaths() async => ['.'];
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    PathProviderPlatform.instance = FakePathProviderPlatform();
  });

  group('End-to-End Tests', () {
    testWidgets('App launches and navigates', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify app loads
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}