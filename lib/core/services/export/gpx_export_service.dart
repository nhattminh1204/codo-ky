import 'dart:io';
import 'package:gpx/gpx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:codoky/core/logging/app_logger.dart';
import 'package:codoky/features/map/data/models/osrm_route_model.dart';

class GpxExportService {
  /// Exports an [OsrmRoute] to a GPX file and returns the file path.
  Future<String?> exportRouteToGpx({
    required OsrmRoute route,
    required String routeName,
  }) async {
    try {
      final gpx = Gpx();
      gpx.creator = 'CodoKy App';
      
      final trk = Trk(name: routeName);
      final trkseg = Trkseg();

      for (final point in route.points) {
        trkseg.trkpts.add(
          Wpt(
            lat: point.latitude,
            lon: point.longitude,
            ele: 0.0, // OSRM 2D routes don't usually provide elevation
          ),
        );
      }

      trk.trksegs.add(trkseg);
      gpx.trks.add(trk);

      final gpxString = GpxWriter().asString(gpx, pretty: true);
      
      final directory = await getApplicationDocumentsDirectory();
      final sanitizedName = routeName.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/${sanitizedName}_$timestamp.gpx';
      
      final file = File(filePath);
      await file.writeAsString(gpxString);
      
      AppLogger.i('GPX Export Successful: $filePath');
      return filePath;
    } catch (e, stackTrace) {
      AppLogger.e('Failed to export route to GPX', e, stackTrace);
      return null;
    }
  }
}
