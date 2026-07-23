import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration loaded from environment variables
/// 
/// Usage: Call [AppConfig.initialize()] in main() before runApp()
class AppConfig {
  static bool _isInitialized = false;
  
  static String get apiBaseUrl => _getString('API_BASE_URL');
  static String get googleMapsApiKey => _getString('GOOGLE_MAPS_API_KEY');
  static String get geminiApiKey => _getString('GEMINI_API_KEY');
  
  // Optional configs with defaults
  static int get apiTimeoutSeconds => _getInt('API_TIMEOUT_SECONDS', 30);
  static int get defaultPageSize => _getInt('DEFAULT_PAGE_SIZE', 20);
  static String get appName => _getString('APP_NAME', 'CodoKy');
  static String get appVersion => _getString('APP_VERSION', '1.0.0');
  
  /// Initialize dotenv from the appropriate .env file
  /// Call this in main() before runApp()
  static Future<void> initialize({String? environment}) async {
    if (_isInitialized) return;
    
    final env = environment ?? const String.fromEnvironment('ENV', defaultValue: 'dev');
    
    for (final fileName in ['.env.$env', '.env.dev', '.env.example', 'assets/.env.dev', 'assets/.env.example']) {
      try {
        await dotenv.load(fileName: fileName);
        _isInitialized = true;
        print('✅ Loaded configuration from $fileName');
        return;
      } catch (_) {
        // Try next file
      }
    }
    
    _isInitialized = true;
    print('⚠️ Using default configuration values');
  }
  
  static String _getString(String key, [String defaultValue = '']) {
    return dotenv.env[key] ?? defaultValue;
  }
  
  static int _getInt(String key, int defaultValue) {
    final value = dotenv.env[key];
    return int.tryParse(value ?? '') ?? defaultValue;
  }
  
  static double _getDouble(String key, double defaultValue) {
    final value = dotenv.env[key];
    return double.tryParse(value ?? '') ?? defaultValue;
  }
  
  static bool _getBool(String key, bool defaultValue) {
    final value = dotenv.env[key]?.toLowerCase();
    if (value == 'true' || value == '1') return true;
    if (value == 'false' || value == '0') return false;
    return defaultValue;
  }
  
  /// Debug: print all loaded config (without sensitive values)
  static void debugPrintConfig() {
    print('=== AppConfig ===');
    print('Environment: ${const String.fromEnvironment('ENV', defaultValue: 'production')}');
    print('API Base URL: $apiBaseUrl');
    print('Google Maps API Key: ${googleMapsApiKey.isNotEmpty ? '***SET***' : 'NOT SET'}');
    print('Gemini API Key: ${geminiApiKey.isNotEmpty ? '***SET***' : 'NOT SET'}');
    print('API Timeout: ${apiTimeoutSeconds}s');
    print('Default Page Size: $defaultPageSize');
    print('==================');
  }
}