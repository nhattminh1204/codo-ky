import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/logging/app_logger.dart';
import 'package:codoky/core/network/api_client.dart';
import 'package:codoky/features/itinerary/data/models/itinerary_model.dart';
import 'package:codoky/features/itinerary/data/services/ai_remote_service.dart';
import 'package:codoky/features/itinerary/data/services/itinerary_firestore_service.dart';
import 'package:codoky/features/map/data/datasources/osrm_remote_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

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
  final ItineraryFirestoreService? _firestoreService;
  final FirebaseAuth? _auth;

  ItineraryNotifier({
    AiRemoteService? aiRemoteService,
    OsrmRemoteService? osrmRemoteService,
    ItineraryFirestoreService? firestoreService,
    FirebaseAuth? auth,
  })  : _aiRemoteService = aiRemoteService ?? AiRemoteService(),
        // ignore: prefer_initializing_formals
        _osrmRemoteService = osrmRemoteService,
        // ignore: prefer_initializing_formals
        _firestoreService = firestoreService,
        // ignore: prefer_initializing_formals
        _auth = auth,
        super(const ItineraryState());

  Future<void> loadMyItineraries() async {
    state = state.copyWith(isLoading: true, error: null);

    final uid = _auth?.currentUser?.uid;
    final service = _firestoreService;
    if (uid == null || service == null) {
      state = state.copyWith(isLoading: false, myItineraries: const []);
      return;
    }

    try {
      final mine = await service.getMyItineraries(uid);
      state = state.copyWith(isLoading: false, myItineraries: mine);
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

  /// Lưu lộ trình vào state local và đồng bộ lên Firestore (nếu có user đăng nhập).
  ///
  /// Trả về `savedToCloud = true` nếu ghi Firestore thành công, `false` nếu guest
  /// hoặc ghi cloud lỗi. State local luôn được giữ — lỗi cloud không throw.
  Future<bool> saveItinerary(ItineraryModel itinerary) async {
    state = state.copyWith(
      myItineraries: [...state.myItineraries, itinerary],
    );

    final uid = _auth?.currentUser?.uid;
    final service = _firestoreService;
    if (uid == null || service == null) return false;

    try {
      await service.saveItinerary(itinerary, uid);
      return true;
    } catch (e) {
      AppLogger.w('Không thể lưu lộ trình ${itinerary.id} lên Firestore: $e');
      return false;
    }
  }

  /// Đồng bộ ngầm itinerary lên Firestore sau mỗi thao tác CRUD.
  ///
  /// Chỉ sync khi itinerary đã từng được lưu (đang nằm trong `myItineraries`) và
  /// có user đăng nhập. Mọi lỗi sync đều được nuốt (chỉ log warning) để không làm
  /// hỏng kết quả trả về hay state local — bản ghi sẽ tự đồng bộ lại ở lần CRUD
  /// sau nhờ `.set(merge: true)`.
  Future<void> _syncItineraryIfSaved(ItineraryModel updated) async {
    final uid = _auth?.currentUser?.uid;
    final service = _firestoreService;
    if (uid == null || service == null) return;

    final isSaved = state.myItineraries.any((it) => it.id == updated.id);
    if (!isSaved) return;

    try {
      await service.saveItinerary(updated, uid);
    } catch (e) {
      AppLogger.w('Auto-sync itinerary ${updated.id} thất bại (giữ nguyên local): $e');
    }
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

    await _syncItineraryIfSaved(updatedItinerary);

    return _checkIsLate(finalDay);
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

    await _syncItineraryIfSaved(updatedItinerary);

    return _checkIsLate(finalDay);
  }

  Future<bool> addActivity(
    String itineraryId,
    int dayIndex, {
    required String placeId,
    required String placeName,
    required double latitude,
    required double longitude,
  }) async {
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

    // 1. Validate Radius (50km Haversine distance)
    if (activities.isNotEmpty) {
      const distanceCalc = Distance();
      final newPoint = LatLng(latitude, longitude);
      final isWithinRadius = activities.any((act) {
        final actPoint = LatLng(act.latitude, act.longitude);
        return distanceCalc.as(LengthUnit.Kilometer, newPoint, actPoint) <= 50.0;
      });
      if (!isWithinRadius) {
        throw Exception("Địa điểm quá xa (> 50km) so với các điểm dừng hiện có trong ngày");
      }
    }

    // 2. Nearest-Insertion: Determine optimal insertion index
    int bestIndex = activities.length;
    if (activities.isNotEmpty) {
      const distanceCalc = Distance();
      final newPoint = LatLng(latitude, longitude);
      double minTotalDist = double.infinity;

      for (int i = 0; i <= activities.length; i++) {
        final candidatePoints = <LatLng>[];
        for (int j = 0; j < activities.length; j++) {
          if (j == i) {
            candidatePoints.add(newPoint);
          }
          candidatePoints.add(LatLng(activities[j].latitude, activities[j].longitude));
        }
        if (i == activities.length) {
          candidatePoints.add(newPoint);
        }

        double candidateDist = 0.0;
        for (int k = 0; k < candidatePoints.length - 1; k++) {
          candidateDist += distanceCalc.as(LengthUnit.Meter, candidatePoints[k], candidatePoints[k + 1]);
        }

        if (candidateDist < minTotalDist) {
          minTotalDist = candidateDist;
          bestIndex = i;
        }
      }
    }

    // 3. Create new ItineraryActivityModel with UUID & default 1-hour duration
    final newId = const Uuid().v4();
    final dayDate = itinerary.createdAt.add(Duration(days: day.dayNumber > 0 ? day.dayNumber - 1 : 0));
    final DateTime defaultMorning = DateTime(dayDate.year, dayDate.month, dayDate.day, 8, 0);
    final DateTime newStartTime = (bestIndex == 0 && activities.isNotEmpty)
        ? activities.first.startTime
        : (activities.isEmpty ? defaultMorning : DateTime.now());
    final DateTime newEndTime = newStartTime.add(const Duration(hours: 1));

    final newActivity = ItineraryActivityModel(
      id: newId,
      name: placeName,
      description: '',
      placeId: placeId,
      placeName: placeName,
      latitude: latitude,
      longitude: longitude,
      startTime: newStartTime,
      endTime: newEndTime,
      type: 'visit',
      status: itinerary.status == 'completed' ? 'completed' : 'draft',
    );

    activities.insert(bestIndex, newActivity);

    // 4. Recalculate Day Route using OSRM
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

    await _syncItineraryIfSaved(updatedItinerary);

    return _checkIsLate(finalDay);
  }

  bool _checkIsLate(ItineraryDayModel day) {
    if (day.activities.isEmpty) return false;
    final firstActivity = day.activities.first;
    final lastActivity = day.activities.last;
    return lastActivity.endTime.hour >= 22 || lastActivity.endTime.day != firstActivity.startTime.day;
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
    firestoreService: ItineraryFirestoreService(firestore: FirebaseFirestore.instance),
    auth: FirebaseAuth.instance,
  );
});