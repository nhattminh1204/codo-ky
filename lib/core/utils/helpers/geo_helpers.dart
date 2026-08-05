import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// Hàm thuần túy xử lý tọa độ địa lý — dùng chung cho toàn app.
///
/// Tránh copy-paste công thức haversine ở nhiều nơi (trước đây được
/// trùng lặp trong map_home_screen.dart).
class GeoHelpers {
  GeoHelpers._();

  /// Khoảng cách theo đường chim bay (haversine) giữa [p1] và [p2], đơn vị mét.
  static double distanceMeters(LatLng p1, LatLng p2) {
    const double r = 6371000; // bán kính Trái Đất (m)
    final lat1 = p1.latitude * (math.pi / 180.0);
    final lat2 = p2.latitude * (math.pi / 180.0);
    final dLat = (p2.latitude - p1.latitude) * (math.pi / 180.0);
    final dLng = (p2.longitude - p1.longitude) * (math.pi / 180.0);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }
}