import 'package:latlong2/latlong.dart';

class OsrmStep {
  final String instruction;
  final String streetName;
  final double distanceMeters;
  final double durationSeconds;
  final LatLng location;
  final String type; // 'depart', 'turn', 'arrive', 'straight'
  final String modifier; // 'left', 'right', 'straight', 'slight left', 'slight right'

  const OsrmStep({
    required this.instruction,
    required this.streetName,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.location,
    required this.type,
    required this.modifier,
  });

  factory OsrmStep.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'đường nội bộ';
    final distance = (json['distance'] as num?)?.toDouble() ?? 0.0;
    final duration = (json['duration'] as num?)?.toDouble() ?? 0.0;
    final maneuver = json['maneuver'] as Map<String, dynamic>? ?? {};
    final type = maneuver['type'] as String? ?? 'straight';
    final modifier = maneuver['modifier'] as String? ?? 'straight';
    final locList = maneuver['location'] as List<dynamic>?;

    LatLng loc = const LatLng(16.4637, 107.5909);
    if (locList != null && locList.length >= 2) {
      loc = LatLng((locList[1] as num).toDouble(), (locList[0] as num).toDouble());
    }

    String instruction = 'Đi thẳng';
    if (type == 'depart') {
      instruction = 'Khởi hành trên $name';
    } else if (type == 'arrive') {
      instruction = 'Bạn đã đến điểm đến';
    } else if (type == 'turn') {
      if (modifier.contains('left')) {
        instruction = 'Rẽ trái vào $name';
      } else if (modifier.contains('right')) {
        instruction = 'Rẽ phải vào $name';
      } else {
        instruction = 'Đi thẳng vào $name';
      }
    } else {
      instruction = 'Tiếp tục đi thẳng trên $name';
    }

    return OsrmStep(
      instruction: instruction,
      streetName: name,
      distanceMeters: distance,
      durationSeconds: duration,
      location: loc,
      type: type,
      modifier: modifier,
    );
  }

  String get formattedDistance {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    }
    return '${distanceMeters.round()} m';
  }
}
