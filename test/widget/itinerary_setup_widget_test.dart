import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/features/itinerary/data/models/itinerary_model.dart';
import 'package:codoky/features/itinerary/data/services/ai_remote_service.dart';
import 'package:codoky/features/itinerary/presentation/providers/itinerary_provider.dart';
import 'package:codoky/features/itinerary/presentation/screens/itinerary_setup_screen.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ItinerarySetupScreen Widget & User Flow Tests', () {
    testWidgets('1. ItinerarySetupScreen renders options and setup title', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiRemoteServiceProvider.overrideWithValue(MockAiService()),
          ],
          child: const MaterialApp(
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

      final mockAi = MockAiService();

      late ProviderContainer container;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container = ProviderContainer(
            overrides: [
              aiRemoteServiceProvider.overrideWithValue(mockAi),
            ],
          ),
          child: const MaterialApp(
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
