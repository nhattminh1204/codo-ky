import 'package:latlong2/latlong.dart';

class AppConstants {
  static const String appName = 'CodoKy';
  static const String appVersion = '1.0.0';
  static const String baseUrl = 'https://api.codoky.com/v1';
  static const String defaultOsrmBaseUrl = 'http://router.project-osrm.org';
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  static const int defaultTimeout = 30;
  static const int defaultPageSize = 20;
  static const double defaultMapZoom = 14.0;
  static const double minMapZoom = 3.5;
  static const double maxMapZoom = 18.5;
  static const double defaultMapLatitude = 16.4637;
  static const double defaultMapLongitude = 107.5909;

  /// Tọa độ giới hạn khung hình Mở rộng Lãnh thổ & Biển Đông Việt Nam (Bao gồm Hoàng Sa & Trường Sa)
  static final LatLng vietnamSouthWest = LatLng(3.0, 95.0);
  static final LatLng vietnamNorthEast = LatLng(27.0, 126.0);

  static const String defaultMapStyle = '[]';
  static const int maxImageSize = 5 * 1024 * 1024;
  static const List<String> supportedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> supportedLocales = ['en', 'vi'];
  static const String defaultLocale = 'vi';
  static const int cacheDuration = 3600;
  static const String tokenStorageKey = 'auth_token';
  static const String userStorageKey = 'user_data';
  static const String localeStorageKey = 'app_locale';
}