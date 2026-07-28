import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:codoky/core/logging/app_logger.dart';

class CachedDiskTileProvider extends TileProvider {
  final String userAgent;
  final int maxCacheSizeBytes;
  final Duration maxCacheAge;
  static String? _cachedPath;
  static bool _isPruning = false;

  CachedDiskTileProvider({
    this.userAgent = 'com.codoky.app',
    this.maxCacheSizeBytes = 250 * 1024 * 1024,
    this.maxCacheAge = const Duration(days: 30),
  }) {
    _initCacheDir();
  }

  static Future<String?> _initCacheDir() async {
    if (_cachedPath != null) return _cachedPath;
    try {
      final baseDir = await getApplicationSupportDirectory();
      final dir = Directory('${baseDir.path}/map_tile_cache');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _cachedPath = dir.path;
      return _cachedPath;
    } catch (e) {
      AppLogger.w('⚠️ Could not initialize map_tile_cache directory: $e');
      return null;
    }
  }

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final tileUrl = getTileUrl(coordinates, options);
    return CachedTileImageProvider(
      url: tileUrl,
      coordinates: coordinates,
      cachePath: _cachedPath,
      getCachePath: _initCacheDir,
      userAgent: userAgent,
      maxCacheAge: maxCacheAge,
    );
  }

  static void pruneCache({
    int maxCacheSizeBytes = 250 * 1024 * 1024,
    Duration maxCacheAge = const Duration(days: 30),
  }) {
    if (_isPruning) return;
    _isPruning = true;
    Future.microtask(() async {
      try {
        final path = await _initCacheDir();
        if (path == null) return;
        final dir = Directory(path);
        if (!await dir.exists()) return;

        final entities = await dir.list().where((e) => e is File).cast<File>().toList();
        final now = DateTime.now();
        int totalSize = 0;

        final fileStats = <MapEntry<File, FileStat>>[];
        for (final file in entities) {
          final stat = await file.stat();
          fileStats.add(MapEntry(file, stat));
          totalSize += stat.size;

          if (now.difference(stat.modified) > maxCacheAge) {
            try {
              await file.delete();
              totalSize -= stat.size;
            } catch (_) {}
          }
        }

        if (totalSize > maxCacheSizeBytes) {
          fileStats.sort((a, b) => a.value.modified.compareTo(b.value.modified));
          for (final entry in fileStats) {
            if (totalSize <= maxCacheSizeBytes) break;
            if (await entry.key.exists()) {
              try {
                await entry.key.delete();
                totalSize -= entry.value.size;
              } catch (_) {}
            }
          }
        }
      } catch (e) {
        AppLogger.w('Tile cache pruning warning: $e');
      } finally {
        _isPruning = false;
      }
    });
  }
}

class CachedTileImageKey {
  final String url;
  const CachedTileImageKey(this.url);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedTileImageKey && runtimeType == other.runtimeType && url == other.url;

  @override
  int get hashCode => url.hashCode;
}

class CachedTileImageProvider extends ImageProvider<CachedTileImageKey> {
  final String url;
  final TileCoordinates coordinates;
  final String? cachePath;
  final Future<String?> Function() getCachePath;
  final String userAgent;
  final Duration maxCacheAge;

  CachedTileImageProvider({
    required this.url,
    required this.coordinates,
    required this.cachePath,
    required this.getCachePath,
    required this.userAgent,
    required this.maxCacheAge,
  });

  @override
  Future<CachedTileImageKey> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedTileImageKey>(CachedTileImageKey(url));
  }

  @override
  ImageStreamCompleter loadImage(CachedTileImageKey key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      debugLabel: key.url,
      informationCollector: () => [
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<CachedTileImageKey>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(CachedTileImageKey key, ImageDecoderCallback decode) async {
    File? file;
    try {
      final path = cachePath ?? await getCachePath();
      if (path != null) {
        final sanitizedFileName = '${key.url.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}.png';
        file = File('$path/$sanitizedFileName');

        if (file.existsSync()) {
          final stat = file.statSync();
          final isExpired = DateTime.now().difference(stat.modified) > maxCacheAge;
          if (!isExpired) {
            final bytes = await file.readAsBytes();
            if (bytes.isNotEmpty) {
              final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
              return await decode(buffer);
            }
          }
        }
      }
    } catch (e) {
      AppLogger.w('⚠️ Disk tile cache read exception for ${key.url}: $e');
    }

    try {
      final response = await http.get(
        Uri.parse(key.url),
        headers: {'User-Agent': userAgent},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        if (file != null) {
          try {
            await file.writeAsBytes(response.bodyBytes);
          } catch (e) {
            AppLogger.w('⚠️ Could not write tile cache to disk: $e');
          }
        }
        final buffer = await ui.ImmutableBuffer.fromUint8List(response.bodyBytes);
        return await decode(buffer);
      }
    } catch (e) {
      AppLogger.w('⚠️ Network tile fetch exception for ${key.url}: $e');
    }

    if (file != null && file.existsSync()) {
      try {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
          return await decode(buffer);
        }
      } catch (_) {}
    }

    throw Exception('Failed to load map tile from network ($url) and no disk cache available.');
  }
}
