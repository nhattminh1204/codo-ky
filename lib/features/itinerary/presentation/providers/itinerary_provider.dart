import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/features/itinerary/data/models/itinerary_model.dart';

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
      error: error ?? this.error,
    );
  }
}

class ItineraryNotifier extends StateNotifier<ItineraryState> {
  ItineraryNotifier() : super(const ItineraryState());

  Future<void> loadMyItineraries() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // TODO: Load from API
      state = state.copyWith(
        myItineraries: [],
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
  }) async {
    state = state.copyWith(isLoadingSuggestions: true, error: null);

    try {
      await Future.delayed(const Duration(seconds: 2));
      // TODO: Call AI API
      state = state.copyWith(
        aiSuggestions: [],
        isLoadingSuggestions: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingSuggestions: false, error: e.toString());
    }
  }

  Future<void> saveItinerary(ItineraryModel itinerary) async {
    // TODO: Save to API
    state = state.copyWith(
      myItineraries: [...state.myItineraries, itinerary],
    );
  }
}

final itineraryProvider = StateNotifierProvider<ItineraryNotifier, ItineraryState>((ref) {
  return ItineraryNotifier();
});