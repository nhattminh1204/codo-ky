import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:codoky/core/network/api_client.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/features/itinerary/data/models/itinerary_model.dart';
import 'package:codoky/features/itinerary/data/services/ai_remote_service.dart';
import 'package:codoky/features/itinerary/presentation/providers/itinerary_provider.dart';
import 'package:codoky/features/itinerary/presentation/screens/itinerary_setup_screen.dart';
import 'package:codoky/features/map/data/datasources/osrm_remote_service.dart';
import 'package:codoky/features/map/data/models/osrm_route_model.dart';

class MockAiService extends AiRemoteService {
  @override
  Future<ItineraryModel> generateItinerary({
    required int durationDays,
    required double budget,
    required List<String> interests,
    String companion = 'cặp đôi',
  }) async {
    final now = DateTime.now();
    return ItineraryModel(
      id: 'mock_itin_1',
      title: 'Lộ trình Huế 3 ngày 2 đêm',
      description: 'Lộ trình thử nghiệm UI',
      durationDays: durationDays,
      budget: budget,
      interests: interests,
      days: [],
      createdAt: now,
      updatedAt: now,
    );
  }
}

class MockOsrmService implements OsrmRemoteService {
  @override
  ApiClient get apiClient => throw UnimplementedError();

  @override
  Future<List<OsrmRoute>> getRoutes({required LatLng start, required LatLng end, String profile = 'driving', bool alternatives = true}) async {
    return [];
  }

  @override
  Future<OsrmRoute> getDrivingRoute({required LatLng start, required LatLng end, String profile = 'driving'}) async {
    return OsrmRoute(points: [], distanceMeters: 0, durationSeconds: 0);
  }

  @override
  Future<OsrmRoute> getMultiWaypointRoute({required List<LatLng> waypoints, String profile = 'driving'}) async {
    return OsrmRoute(points: [], distanceMeters: 0, durationSeconds: 0, legDurations: []);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ItinerarySetupScreen Widget & User Flow Tests', () {
    testWidgets('1. ItinerarySetupScreen renders options and setup title', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiRemoteServiceProvider.overrideWithValue(MockAiService()),
            osrmRemoteServiceProvider.overrideWithValue(MockOsrmService()),
          ],
          child: const MaterialApp(
            locale: Locale('vi'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: ItinerarySetupScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header title and setup options exist
      expect(find.textContaining('Thiết lập lịch trình AI'), findsOneWidget);
      expect(find.textContaining('CodoKy AI Travel Planner'), findsOneWidget);
      expect(find.textContaining('Tạo Lịch Trình Tự Động AI'), findsOneWidget);
    });

    testWidgets('2. Tapping submit button invokes AI itinerary generation flow', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));

      final container = ProviderContainer(
        overrides: [
          aiRemoteServiceProvider.overrideWithValue(MockAiService()),
          osrmRemoteServiceProvider.overrideWithValue(MockOsrmService()),
        ],
      );

      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: Locale('vi'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: ItinerarySetupScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final submitBtn = find.textContaining('Tạo Lịch Trình Tự Động AI');
      expect(submitBtn, findsOneWidget);

      await tester.tap(submitBtn, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify AI suggestions state in Riverpod notifier is populated
      final itineraryState = container.read(itineraryProvider);
      expect(itineraryState.aiSuggestions, isNotEmpty);
      expect(itineraryState.aiSuggestions.first.title, equals('Lộ trình Huế 3 ngày 2 đêm'));
    });
  });
}
