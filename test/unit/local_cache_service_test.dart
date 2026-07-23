import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:codoky/core/storage/local_cache_service.dart';

class FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String tempPath;
  FakePathProviderPlatform(this.tempPath);

  @override
  Future<String?> getTemporaryPath() async => tempPath;

  @override
  Future<String?> getApplicationSupportPath() async => tempPath;

  @override
  Future<String?> getLibraryPath() async => tempPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => tempPath;

  @override
  Future<List<String>?> getExternalCachePaths() async => [tempPath];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir.path);
  });

  tearDownAll(() async {
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  group('LocalCacheService Unit Tests', () {
    test('Hive.initFlutter initializes successfully and can set/get preference', () async {
      final cacheService = LocalCacheService.instance;
      await cacheService.init();

      await cacheService.setPreference<String>('test_key', 'test_value');
      final result = cacheService.getPreference<String>('test_key');

      expect(result, equals('test_value'));
    });
  });
}
