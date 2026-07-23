// Riverpod global providers
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/network/api_client.dart';
import 'package:codoky/core/config/constants/app_constants.dart';
import 'package:flutter/material.dart';

// App lifecycle
import 'package:flutter/widgets.dart';

final appLifecycleProvider = StateProvider<AppLifecycleState>((ref) => AppLifecycleState.resumed);

// Locale
final localeProvider = StateProvider<String>((ref) => AppConstants.defaultLocale);

// Theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Auth token
final authTokenProvider = StateProvider<String?>((ref) => null);

// User data
final userProvider = StateProvider<dynamic>((ref) => null);

// Connectivity
final connectivityProvider = StateProvider<bool>((ref) => true);