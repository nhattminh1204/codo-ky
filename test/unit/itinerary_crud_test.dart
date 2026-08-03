import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:codoky/core/network/api_client.dart';
import 'package:codoky/features/itinerary/data/models/itinerary_model.dart';
import 'package:codoky/features/itinerary/data/services/ai_remote_service.dart';
import 'package:codoky/features/itinerary/presentation/providers/itinerary_provider.dart';
import 'package:codoky/features/map/data/datasources/osrm_remote_service.dart';
import 'package:codoky/features/map/data/models/osrm_route_model.dart';

class MockAiSuccess extends AiRemoteService {
  final ItineraryModel result;
  int generateCount = 0;
  MockAiSuccess(this.result);
  @override
  Future<ItineraryModel> generateItinerary({
    required int durationDays,
    required double budget,
    required List<String> interests,
    String companion = 'cặp đôi',
  }) async {
    generateCount++;
    return result;
  }
}

class MockOsrmWithLegDurations implements OsrmRemoteService {
  final List<double> legDurations;
  int callCount = 0;
  MockOsrmWithLegDurations(this.legDurations);

  @override
  ApiClient get apiClient => throw UnimplementedError();

  @override
  Future<List<OsrmRoute>> getRoutes({required LatLng start, required LatLng end, String profile = 'driving', bool alternatives = true}) async => [];

  @override
  Future<OsrmRoute> getDrivingRoute({required LatLng start, required LatLng end, String profile = 'driving'}) async {
    return OsrmRoute(points: [], distanceMeters: 0, durationSeconds: 0);
  }

  @override
  Future<OsrmRoute> getMultiWaypointRoute({required List<LatLng> waypoints, String profile = 'driving'}) async {
    callCount++;
    return OsrmRoute(
      points: waypoints,
      distanceMeters: 5000,
      durationSeconds: legDurations.fold(0, (a, b) => a + b),
      legDurations: legDurations,
    );
  }
}

ItineraryModel _buildTestItinerary({String status = 'draft'}) {
  final now = DateTime(2026, 8, 3, 8, 0); // 08:00
  final act1 = ItineraryActivityModel(
    id: 'act_1', name: 'Đại Nội Huế', description: '', placeId: 'p1', placeName: 'Đại Nội',
    latitude: 16.4697, longitude: 107.5786,
    startTime: now, endTime: now.add(const Duration(hours: 2)),
    type: 'visit', estimatedCost: 150000,
  );
  final act2 = ItineraryActivityModel(
    id: 'act_2', name: 'Chùa Thiên Mụ', description: '', placeId: 'p2', placeName: 'Chùa Thiên Mụ',
    latitude: 16.4537, longitude: 107.5423,
    startTime: now.add(const Duration(hours: 3)), endTime: now.add(const Duration(hours: 5)),
    type: 'visit', estimatedCost: 0,
  );
  final act3 = ItineraryActivityModel(
    id: 'act_3', name: 'Lăng Khải Định', description: '', placeId: 'p3', placeName: 'Lăng Khải Định',
    latitude: 16.3992, longitude: 107.5961,
    startTime: now.add(const Duration(hours: 6)), endTime: now.add(const Duration(hours: 8)),
    type: 'visit', estimatedCost: 100000,
  );
  final day1 = ItineraryDayModel(dayNumber: 1, title: 'Ngày 1', description: '', activities: [act1, act2, act3]);
  return ItineraryModel(
    id: 'itin_test',
    title: 'Test Itinerary',
    description: '',
    durationDays: 1,
    budget: 500000,
    interests: ['Di sản'],
    days: [day1],
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('ItineraryNotifier reorderActivity & removeActivity Tests', () {
    test('1. reorderActivity: moves act_1 to index 2, recalculates times via OSRM', () async {
      final itinerary = _buildTestItinerary();
      // OSRM trả 2 legs vì 3 waypoints: 600s và 1200s giữa các điểm
      final osrm = MockOsrmWithLegDurations([600, 1200]);
      final aiService = MockAiSuccess(itinerary);
      final notifier = ItineraryNotifier(
        aiRemoteService: aiService,
        osrmRemoteService: osrm,
      );
      await notifier.saveItinerary(itinerary);

      // Di chuyển act_1 từ index 0 xuống cuối list (index 2).
      // Off-by-one correction (newIndex -= 1 khi newIndex > oldIndex) bây giờ
      // được xử lý ở UI layer (itinerary_result_screen.dart:278-280),
      // nên provider nhận newIndex đã sẵn chính xác.
      final isLate = await notifier.reorderActivity('itin_test', 0, 0, 2);

      // OSRM called 1 time, Gemini called 0 times
      expect(osrm.callCount, equals(1));
      expect(aiService.generateCount, equals(0));
      expect(isLate, equals(false)); // endTime will be around 14:00, not late

      final updated = notifier.state.myItineraries.first;
      final day = updated.days.first;

      // Sau reorder, thứ tự phải là: act_2, act_3, act_1 (removeAt(0) rồi insert(2))
      expect(day.activities[0].id, equals('act_2'));
      expect(day.activities[1].id, equals('act_3'));
      expect(day.activities[2].id, equals('act_1'));

      // act_2 (index 0) giữ nguyên startTime
      // act_3 (index 1) startTime = act_2.endTime + 600s travel
      final act2EndTime = day.activities[0].endTime;
      final expectedAct3Start = act2EndTime.add(const Duration(seconds: 600));
      expect(day.activities[1].startTime, equals(expectedAct3Start));
    });

    test('2. removeActivity: xoá act_2, thứ tự còn act_1, act_3; times được tính lại', () async {
      final itinerary = _buildTestItinerary();
      // 3 điểm → 2 legs, nhưng sau xoá chỉ còn 2 điểm → 1 leg
      final osrm = MockOsrmWithLegDurations([900]);
      final aiService = MockAiSuccess(itinerary);
      final notifier = ItineraryNotifier(
        aiRemoteService: aiService,
        osrmRemoteService: osrm,
      );
      await notifier.saveItinerary(itinerary);

      final isLate = await notifier.removeActivity('itin_test', 0, 'act_2');

      // OSRM called 1 time, Gemini called 0 times
      expect(osrm.callCount, equals(1));
      expect(aiService.generateCount, equals(0));
      expect(isLate, equals(false));

      final updated = notifier.state.myItineraries.first;
      final day = updated.days.first;

      expect(day.activities.length, equals(2));
      expect(day.activities[0].id, equals('act_1'));
      expect(day.activities[1].id, equals('act_3'));

      // act_3 startTime = act_1.endTime + 900s
      final expectedAct3Start = day.activities[0].endTime.add(const Duration(seconds: 900));
      expect(day.activities[1].startTime, equals(expectedAct3Start));
    });

    test('3. reorderActivity bị chặn khi itinerary.status = completed', () async {
      final itinerary = _buildTestItinerary(status: 'completed');
      final notifier = ItineraryNotifier();
      await notifier.saveItinerary(itinerary);

      expect(
        () async => await notifier.reorderActivity('itin_test', 0, 0, 2),
        throwsA(isA<Exception>()),
      );
    });

    test('4. removeActivity bị chặn khi itinerary.status = completed', () async {
      final itinerary = _buildTestItinerary(status: 'completed');
      final notifier = ItineraryNotifier();
      await notifier.saveItinerary(itinerary);

      expect(
        () async => await notifier.removeActivity('itin_test', 0, 'act_1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
