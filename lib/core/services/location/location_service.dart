import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:codoky/core/logging/app_logger.dart';

class LocationResult {
  final LatLng position;
  final double accuracy;
  final bool isLastKnown;
  final String? message;

  const LocationResult({
    required this.position,
    required this.accuracy,
    this.isLastKnown = false,
    this.message,
  });
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStreamSubscription;

  /// Check GPS service status & request runtime permissions cleanly
  Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppLogger.w('LocationService: GPS service is disabled on device');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppLogger.w('LocationService: Location permission denied by user');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppLogger.w('LocationService: Location permission denied forever');
      return false;
    }

    return true;
  }

  /// Request GPS runtime permission cleanly with contextual dialogs
  Future<bool> ensureLocationPermission(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.location_off_rounded, color: Color(0xFFDC2626)),
                SizedBox(width: 10),
                Text('Định vị GPS đã tắt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              'Ứng dụng CodoKy cần dịch vụ vị trí GPS để xác định vị trí của bạn trên bản đồ và chỉ đường. Vui lòng bật GPS.',
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Bỏ qua'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  openLocationSettings();
                },
                child: const Text('Mở Cài đặt GPS'),
              ),
            ],
          ),
        );
      }
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Yêu cầu quyền vị trí trực tiếp từ hệ thống
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Bạn đã từ chối cấp quyền vị trí GPS cho ứng dụng.'),
              backgroundColor: Color(0xFFDC2626),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.security_rounded, color: Color(0xFFDC2626)),
                SizedBox(width: 10),
                Text('Cần cấp quyền Vị trí', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              'Quyền vị trí GPS đã bị tắt trong Cài đặt ứng dụng. Vui lòng mở Cài đặt để cho phép CodoKy truy cập vị trí.',
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Để sau'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  openAppSettings();
                },
                child: const Text('Mở Cài đặt'),
              ),
            ],
          ),
        );
      }
      return false;
    }

    return true;
  }

  /// Multi-tier accurate location fetch strategy
  /// 1. Instant last known position (<50ms response)
  /// 2. High-accuracy satellite position fix
  /// 3. Medium accuracy fallback if indoors/timeout
  Future<LocationResult?> getAccuratePosition({
    Function(LocationResult)? onFastFix,
  }) async {
    final hasPermission = await checkPermission();
    if (!hasPermission) return null;

    // Step 1: Fast Fix from Last Known Location
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && onFastFix != null) {
        final fastPos = LatLng(lastKnown.latitude, lastKnown.longitude);
        AppLogger.i('LocationService: Fast fix from last known position ($fastPos)');
        onFastFix(LocationResult(
          position: fastPos,
          accuracy: lastKnown.accuracy,
          isLastKnown: true,
        ));
      }
    } catch (e) {
      AppLogger.w('LocationService: Last known position error: $e');
    }

    // Step 2: High Accuracy Fresh Fix
    try {
      final freshPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 7),
        ),
      );

      final accuratePos = LatLng(freshPos.latitude, freshPos.longitude);
      AppLogger.i('LocationService: High-accuracy fresh position ($accuratePos, accuracy: ${freshPos.accuracy}m)');

      return LocationResult(
        position: accuratePos,
        accuracy: freshPos.accuracy,
        isLastKnown: false,
      );
    } on TimeoutException {
      AppLogger.w('LocationService: High-accuracy timeout, falling back to medium accuracy');
    } catch (e) {
      AppLogger.w('LocationService: High-accuracy fix error ($e), attempting fallback');
    }

    // Step 3: Medium/Balanced Fallback Fix (for indoors or weak satellite signal)
    try {
      final fallbackPos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );

      final pos = LatLng(fallbackPos.latitude, fallbackPos.longitude);
      AppLogger.i('LocationService: Fallback position acquired ($pos)');
      return LocationResult(
        position: pos,
        accuracy: fallbackPos.accuracy,
        isLastKnown: false,
      );
    } catch (e) {
      AppLogger.e('LocationService: All location acquisition strategies failed', e);
      return null;
    }
  }

  /// Subscribe to real-time live position updates with distance filter
  StreamSubscription<Position>? startLiveTracking({
    required Function(LatLng position, double accuracy) onLocationUpdate,
    int distanceFilterMeters = 5,
  }) {
    stopLiveTracking();

    LocationSettings locationSettings;
    try {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
        forceLocationManager: false,
        intervalDuration: const Duration(seconds: 2),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: "CodoKy đang chỉ đường...",
          notificationText: "Theo dõi vị trí GPS thời gian thực khi màn hình khóa",
          notificationIcon: AndroidResource(name: 'launch_background'),
          enableWakeLock: true,
        ),
      );
    } catch (_) {
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
      );
    }

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(

      (Position position) {
        // Filter out extreme inaccuracies (>150m radius)
        if (position.accuracy <= 150) {
          final latLng = LatLng(position.latitude, position.longitude);
          onLocationUpdate(latLng, position.accuracy);
        }
      },
      onError: (e) {
        AppLogger.w('LocationService: Live stream error: $e');
      },
    );

    return _positionStreamSubscription;
  }

  /// Stop live position tracking stream
  void stopLiveTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Open app settings for user to enable permissions if denied forever
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Open location services settings if GPS is disabled
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
