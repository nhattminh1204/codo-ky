import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/core/services/export/gpx_export_service.dart';
import 'package:codoky/features/map/data/models/osrm_route_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return Directory.systemTemp.path;
  }
}

void main() {
  late GpxExportService gpxExportService;

  setUp(() {
    PathProviderPlatform.instance = MockPathProviderPlatform();
    gpxExportService = GpxExportService();
  });

  test('GpxExportService exports an OsrmRoute to a GPX file successfully', () async {
    // Arrange
    final route = const OsrmRoute(
      distanceMeters: 1000.0,
      durationSeconds: 600.0,
      points: [
        LatLng(16.4637, 107.5909), // Hue Citadel
        LatLng(16.4534, 107.5815), // Hue Railway Station
      ],
      summary: 'Test Route',
    );

    // Act
    final filePath = await gpxExportService.exportRouteToGpx(
      route: route,
      routeName: 'Hue_Test_Route',
    );

    // Assert
    expect(filePath, isNotNull);
    
    final file = File(filePath!);
    expect(await file.exists(), isTrue);

    final contents = await file.readAsString();
    expect(contents, contains('<gpx'));
    expect(contents, contains('<trk>'));
    expect(contents, contains('<name>Hue_Test_Route</name>'));
    expect(contents, contains('lat="16.4637"'));
    expect(contents, contains('lon="107.5909"'));
    expect(contents, contains('lat="16.4534"'));
    expect(contents, contains('lon="107.5815"'));

    // Cleanup
    await file.delete();
  });
}
