import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default FirebaseOptions for use with [Firebase.initializeApp].
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      case TargetPlatform.windows:
        return web;
      default:
        return web;
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? 'AIzaSyAoKw9Ot5haGmN_Kyl45pdbuoECslMn_iU',
        appId: dotenv.env['FIREBASE_APP_ID'] ?? '1:923223944723:web:2a5510b00af3ca510659e6',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '923223944723',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? 'codo-ky',
        authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? 'codo-ky.firebaseapp.com',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'codo-ky.firebasestorage.app',
        measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'] ?? 'G-3V04R47T84',
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? 'AIzaSyAoKw9Ot5haGmN_Kyl45pdbuoECslMn_iU',
        appId: dotenv.env['FIREBASE_APP_ID'] ?? '1:923223944723:web:2a5510b00af3ca510659e6',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '923223944723',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? 'codo-ky',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'codo-ky.firebasestorage.app',
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY'] ?? 'AIzaSyAoKw9Ot5haGmN_Kyl45pdbuoECslMn_iU',
        appId: dotenv.env['FIREBASE_APP_ID'] ?? '1:923223944723:web:2a5510b00af3ca510659e6',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '923223944723',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? 'codo-ky',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'codo-ky.firebasestorage.app',
        iosBundleId: 'com.example.codoky',
      );
}
