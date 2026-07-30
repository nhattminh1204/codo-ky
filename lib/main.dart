import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:codoky/core/config/app_config.dart';
import 'package:codoky/core/logging/app_logger.dart';
import 'firebase_options.dart';

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
  HttpOverrides.global = DevHttpOverrides();

  // Load environment configuration safely
  try {
    await AppConfig.initialize();
    AppConfig.debugPrintConfig();
  } catch (e) {
    AppLogger.e('Error initializing AppConfig: $e');
  }

  // Initialize Firebase Core with DefaultFirebaseOptions
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.i('Firebase Core initialized successfully');
  } catch (e) {
    AppLogger.w('Firebase initializeApp note: $e');
  }

  runApp(const ProviderScope(child: CodoKyApp()));
}