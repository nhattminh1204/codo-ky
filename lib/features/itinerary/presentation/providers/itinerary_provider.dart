import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/network/api_client.dart';
import 'package:codoky/features/itinerary/data/models/itinerary_model.dart';
import 'package:codoky/features/itinerary/data/services/ai_remote_service.dart';
import 'package:codoky/features/map/data/datasources/osrm_remote_service.dart';
import 'package:latlong2/latlong.dart';

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
  final OsrmRemoteService? _osrmRemoteService;

  ItineraryNotifier({
    AiRemoteService? aiRemoteService,
    OsrmRemoteService? osrmRemoteService,
  })  : _aiRemoteService = aiRemoteService ?? AiRemoteService(),
        // ignore: prefer_initializing_formals
        _osrmRemoteService = osrmRemoteService,
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

  Future<bool> reorderActivity(String itineraryId, int dayIndex, int oldIndex, int newIndex) async {
    int iterIndex = state.aiSuggestions.indexWhere((it) => it.id == itineraryId);
    bool isAiSuggestion = true;
    if (iterIndex == -1) {
      iterIndex = state.myItineraries.indexWhere((it) => it.id == itineraryId);
      isAiSuggestion = false;
    }
    if (iterIndex == -1) return false;

    final itinerary = isAiSuggestion ? state.aiSuggestions[iterIndex] : state.myItineraries[iterIndex];
    if (itinerary.status == 'completed') throw Exception("Cannot modify completed itinerary");
    if (dayIndex < 0 || dayIndex >= itinerary.days.length) return false;

    final day = itinerary.days[dayIndex];
    if (oldIndex < 0 || oldIndex >= day.activities.length || newIndex < 0 || newIndex > day.activities.length) return false;

    final activities = List<ItineraryActivityModel>.from(day.activities);
    if (activities[oldIndex].status == 'completed') throw Exception("Cannot modify completed activity");
    
    final item = activities.removeAt(oldIndex);
    activities.insert(newIndex, item);

    final updatedDay = day.copyWith(activities: activities);
    final finalDay = await _recalculateDayRoute(updatedDay);

    final updatedDays = List<ItineraryDayModel>.from(itinerary.days);
    updatedDays[dayIndex] = finalDay;
    final updatedItinerary = itinerary.copyWith(days: updatedDays);

    if (isAiSuggestion) {
      final updatedList = List<ItineraryModel>.from(state.aiSuggestions);
      updatedList[iterIndex] = updatedItinerary;
      state = state.copyWith(aiSuggestions: updatedList);
    } else {
      final updatedList = List<ItineraryModel>.from(state.myItineraries);
      updatedList[iterIndex] = updatedItinerary;
      state = state.copyWith(myItineraries: updatedList);
    }
    
    if (finalDay.activities.isEmpty) return false;
    final firstActivity = finalDay.activities.first;
    final lastActivity = finalDay.activities.last;
    bool isLate = lastActivity.endTime.hour >= 22 || lastActivity.endTime.day != firstActivity.startTime.day;
    return isLate;
  }

  Future<bool> removeActivity(String itineraryId, int dayIndex, String activityId) async {
    int iterIndex = state.aiSuggestions.indexWhere((it) => it.id == itineraryId);
    bool isAiSuggestion = true;
    if (iterIndex == -1) {
      iterIndex = state.myItineraries.indexWhere((it) => it.id == itineraryId);
      isAiSuggestion = false;
    }
    if (iterIndex == -1) return false;

    final itinerary = isAiSuggestion ? state.aiSuggestions[iterIndex] : state.myItineraries[iterIndex];
    if (itinerary.status == 'completed') throw Exception("Cannot modify completed itinerary");
    if (dayIndex < 0 || dayIndex >= itinerary.days.length) return false;

    final day = itinerary.days[dayIndex];
    final activities = List<ItineraryActivityModel>.from(day.activities);
    
    final targetActivity = activities.firstWhere((a) => a.id == activityId, orElse: () => throw Exception("Activity not found"));
    if (targetActivity.status == 'completed') throw Exception("Cannot remove completed activity");
    
    activities.removeWhere((a) => a.id == activityId);
    
    final updatedDay = day.copyWith(activities: activities);
    final finalDay = await _recalculateDayRoute(updatedDay);

    final updatedDays = List<ItineraryDayModel>.from(itinerary.days);
    updatedDays[dayIndex] = finalDay;
    final updatedItinerary = itinerary.copyWith(days: updatedDays);

    if (isAiSuggestion) {
      final updatedList = List<ItineraryModel>.from(state.aiSuggestions);
      updatedList[iterIndex] = updatedItinerary;
      state = state.copyWith(aiSuggestions: updatedList);
    } else {
      final updatedList = List<ItineraryModel>.from(state.myItineraries);
      updatedList[iterIndex] = updatedItinerary;
      state = state.copyWith(myItineraries: updatedList);
    }

    if (finalDay.activities.isEmpty) return false;
    final firstActivity = finalDay.activities.first;
    final lastActivity = finalDay.activities.last;
    bool isLate = lastActivity.endTime.hour >= 22 || lastActivity.endTime.day != firstActivity.startTime.day;
    return isLate;
  }

  Future<ItineraryDayModel> _recalculateDayRoute(ItineraryDayModel day) async {
    if (_osrmRemoteService == null) return day;
    if (day.activities.length < 2) return day;

    final waypoints = day.activities.map((a) => LatLng(a.latitude, a.longitude)).toList();
    
    try {
      final route = await _osrmRemoteService.getMultiWaypointRoute(waypoints: waypoints);
      if (route.legDurations.length != day.activities.length - 1) return day;
      
      final updatedActivities = List<ItineraryActivityModel>.from(day.activities);
      
      for (int i = 1; i < updatedActivities.length; i++) {
        final prevActivity = updatedActivities[i - 1];
        final currentActivity = updatedActivities[i];
        
        final travelDurationSeconds = route.legDurations[i - 1].toInt();
        
        final newStartTime = prevActivity.endTime.add(Duration(seconds: travelDurationSeconds));
        final originalDuration = currentActivity.endTime.difference(currentActivity.startTime);
        final newEndTime = newStartTime.add(originalDuration);
        
        updatedActivities[i] = currentActivity.copyWith(
          startTime: newStartTime,
          endTime: newEndTime,
        );
      }
      
      return day.copyWith(activities: updatedActivities);
    } catch (e) {
      return day;
    }
  }
}

final itineraryProvider = StateNotifierProvider<ItineraryNotifier, ItineraryState>((ref) {
  final aiService = ref.watch(aiRemoteServiceProvider);
  final osrmService = ref.watch(osrmRemoteServiceProvider);
  return ItineraryNotifier(
    aiRemoteService: aiService,
    osrmRemoteService: osrmService,
  );
});