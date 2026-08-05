import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:codoky/core/config/app_config.dart';
import 'package:codoky/core/logging/app_logger.dart';
import 'firebase_options.dart';

import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'app.dart';

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    HttpOverrides.global = DevHttpOverrides();
  }

  // Load environment configuration safely
  try {
    await AppConfig.initialize();
    AppConfig.debugPrintConfig();
  } catch (e) {
    AppLogger.e('Error initializing AppConfig: $e');
  }

  // Register Meteocons MIT License
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      ['meteocons'],
      '''Meteocons Weather Icons
Copyright (c) Bas Milius (https://github.com/basmilius/weather-icons)
Licensed under the MIT License.''',
    );
  });

  // Initialize Firebase Core with DefaultFirebaseOptions
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.i('Firebase Core initialized successfully');
  } catch (e) {
    AppLogger.w('Firebase initializeApp note: $e');
  }

  try {
    await LiquidGlassWidgets.initialize();
  } catch (e) {
    AppLogger.w('LiquidGlassWidgets initialize error: $e');
  }

  runApp(
    LiquidGlassWidgets.wrap(
      child: const ProviderScope(child: CodoKyApp()),
    ),
  );
}