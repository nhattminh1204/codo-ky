import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/network/api_client.dart';
import 'package:codoky/features/itinerary/data/models/itinerary_model.dart';
import 'package:codoky/features/itinerary/data/services/ai_remote_service.dart';

final aiRemoteServiceProvider = Provider<AiRemoteService>((ref) {
  return AiRemoteService(apiClient: ref.watch(apiClientProvider));
});

class ItineraryState {
  final List<ItineraryModel> myItineraries;
  final List<ItineraryModel> aiSuggestions;
  final bool isLoading;
  final bool isLoadingSuggestions;
  final String? error;

  const ItineraryState({
    this.myItineraries = const [],
    this.aiSuggestions = const [],
    this.isLoading = false,
    this.isLoadingSuggestions = false,
    this.error,
  });

  ItineraryState copyWith({
    List<ItineraryModel>? myItineraries,
    List<ItineraryModel>? aiSuggestions,
    bool? isLoading,
    bool? isLoadingSuggestions,
    String? error,
  }) {
    return ItineraryState(
      myItineraries: myItineraries ?? this.myItineraries,
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingSuggestions: isLoadingSuggestions ?? this.isLoadingSuggestions,
      error: error,
    );
  }
}

class ItineraryNotifier extends StateNotifier<ItineraryState> {
  final AiRemoteService _aiRemoteService;

  ItineraryNotifier({AiRemoteService? aiRemoteService})
      : _aiRemoteService = aiRemoteService ?? AiRemoteService(),
        super(const ItineraryState());

  Future<void> loadMyItineraries() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future.delayed(const Duration(milliseconds: 200));
      state = state.copyWith(
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> generateAISuggestion({
    required int durationDays,
    required double budget,
    required List<String> interests,
    String companion = 'cặp đôi',
  }) async {
    state = state.copyWith(isLoadingSuggestions: true, error: null);

    try {
      final itinerary = await _aiRemoteService.generateItinerary(
        durationDays: durationDays,
        budget: budget,
        interests: interests,
        companion: companion,
      );

      state = state.copyWith(
        aiSuggestions: [itinerary, ...state.aiSuggestions],
        isLoadingSuggestions: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingSuggestions: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> saveItinerary(ItineraryModel itinerary) async {
    state = state.copyWith(
      myItineraries: [...state.myItineraries, itinerary],
    );
  }
}

final itineraryProvider = StateNotifierProvider<ItineraryNotifier, ItineraryState>((ref) {
  final aiService = ref.watch(aiRemoteServiceProvider);
  return ItineraryNotifier(aiRemoteService: aiService);
});