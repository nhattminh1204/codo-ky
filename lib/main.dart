import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/config/app_config.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Initialize Firebase Crashlytics
  // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };
  
  // TODO: Initialize Firebase Analytics
  // await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  
  // Load environment configuration safely
  try {
    await AppConfig.initialize();
    AppConfig.debugPrintConfig();
  } catch (e) {
    print('⚠️ Error initializing AppConfig: $e');
  }
  
  runApp(const ProviderScope(child: CodoKyApp()));
}