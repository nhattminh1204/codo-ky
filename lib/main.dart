import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:codoky/core/config/app_config.dart';
import 'package:codoky/core/logging/app_logger.dart';
import 'firebase_options.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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