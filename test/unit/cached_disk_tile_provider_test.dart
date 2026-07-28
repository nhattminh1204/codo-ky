import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/features/map/data/datasources/cached_disk_tile_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CachedDiskTileProvider Unit Tests', () {
    test('1. CachedDiskTileProvider initializes with default parameters', () {
      final provider = CachedDiskTileProvider();

      expect(provider.userAgent, equals('com.codoky.app'));
      expect(provider.maxCacheSizeBytes, equals(250 * 1024 * 1024));
      expect(provider.maxCacheAge, equals(const Duration(days: 30)));
    });

    test('2. CachedTileImageKey equality and hash code work correctly', () {
      const key1 = CachedTileImageKey('https://tile.openstreetmap.org/15/26354/14982.png');
      const key2 = CachedTileImageKey('https://tile.openstreetmap.org/15/26354/14982.png');
      const key3 = CachedTileImageKey('https://tile.openstreetmap.org/15/26354/99999.png');

      expect(key1, equals(key2));
      expect(key1.hashCode, equals(key2.hashCode));
      expect(key1, isNot(equals(key3)));
    });
  });
}
