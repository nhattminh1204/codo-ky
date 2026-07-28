import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/features/itinerary/data/models/itinerary_model.dart';
import 'package:codoky/features/itinerary/data/services/ai_remote_service.dart';
import 'package:codoky/features/itinerary/presentation/providers/itinerary_provider.dart';

class MockAiRemoteServiceSuccess extends AiRemoteService {
  final ItineraryModel mockResult;
  MockAiRemoteServiceSuccess(this.mockResult);

  @override
  Future<ItineraryModel> generateItinerary({
    required int durationDays,
    required double budget,
    required List<String> interests,
    String companion = 'cặp đôi',
  }) async {
    return mockResult;
  }
}

class MockAiRemoteServiceFailure extends AiRemoteService {
  final String errorMessage;
  MockAiRemoteServiceFailure(this.errorMessage);

  @override
  Future<ItineraryModel> generateItinerary({
    required int durationDays,
    required double budget,
    required List<String> interests,
    String companion = 'cặp đôi',
  }) async {
    throw AiApiException(errorMessage);
  }
}

void main() {
  group('ItineraryNotifier Unit Tests', () {
    final now = DateTime.now();
    final sampleItinerary = ItineraryModel(
      id: 'itin_001',
      title: 'Lộ trình du lịch Huế 2 ngày',
      description: 'Khám phá văn hóa Cố đô',
      durationDays: 2,
      budget: 1500000,
      interests: ['Di sản', 'Ẩm thực'],
      days: [],
      createdAt: now,
      updatedAt: now,
    );

    test('1. Initial ItineraryState is empty with no errors', () {
      final notifier = ItineraryNotifier();
      final state = notifier.state;

      expect(state.myItineraries, isEmpty);
      expect(state.aiSuggestions, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.isLoadingSuggestions, isFalse);
      expect(state.error, isNull);
    });

    test('2. generateAISuggestion success updates aiSuggestions list', () async {
      final mockService = MockAiRemoteServiceSuccess(sampleItinerary);
      final notifier = ItineraryNotifier(aiRemoteService: mockService);

      await notifier.generateAISuggestion(
        durationDays: 2,
        budget: 1500000,
        interests: ['Di sản'],
      );

      final state = notifier.state;
      expect(state.isLoadingSuggestions, isFalse);
      expect(state.error, isNull);
      expect(state.aiSuggestions.length, equals(1));
      expect(state.aiSuggestions.first.title, equals('Lộ trình du lịch Huế 2 ngày'));
    });

    test('3. generateAISuggestion failure catches AiApiException and updates error state', () async {
      final mockService = MockAiRemoteServiceFailure('Hệ thống AI quá tải lượt gọi');
      final notifier = ItineraryNotifier(aiRemoteService: mockService);

      try {
        await notifier.generateAISuggestion(
          durationDays: 2,
          budget: 1500000,
          interests: ['Di sản'],
        );
      } catch (e) {
        expect(e, isA<AiApiException>());
      }

      final state = notifier.state;
      expect(state.isLoadingSuggestions, isFalse);
      expect(state.error, contains('Hệ thống AI quá tải lượt gọi'));
      expect(state.aiSuggestions, isEmpty);
    });

    test('4. saveItinerary adds itinerary to myItineraries list', () async {
      final notifier = ItineraryNotifier();
      await notifier.saveItinerary(sampleItinerary);

      expect(notifier.state.myItineraries.length, equals(1));
      expect(notifier.state.myItineraries.first, equals(sampleItinerary));
    });
  });
}
