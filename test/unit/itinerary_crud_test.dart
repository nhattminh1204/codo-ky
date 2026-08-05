import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/mockito.dart';
import 'package:codoky/core/network/api_client.dart';
import 'package:codoky/features/itinerary/data/models/itinerary_model.dart';
import 'package:codoky/features/itinerary/data/services/ai_remote_service.dart';
import 'package:codoky/features/itinerary/data/services/itinerary_firestore_service.dart';
import 'package:codoky/features/itinerary/presentation/providers/itinerary_provider.dart';
import 'package:codoky/features/map/data/datasources/osrm_remote_service.dart';
import 'package:codoky/features/map/data/models/osrm_route_model.dart';
import '../mocks.mocks.dart';

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

class MockItineraryFirestoreService extends ItineraryFirestoreService {
  int saveCallCount = 0;
  int getCallCount = 0;
  String? lastUserId;
  final List<String> savedIds = [];
  Object? errorToThrow;

  MockItineraryFirestoreService() : super(firestore: FakeFirebaseFirestore());

  @override
  Future<void> saveItinerary(ItineraryModel itinerary, String userId) async {
    saveCallCount++;
    lastUserId = userId;
    savedIds.add(itinerary.id);
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
  }

  @override
  Future<List<ItineraryModel>> getMyItineraries(String userId) async {
    getCallCount++;
    return [];
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

    test('5. addActivity: chèn vị trí tối ưu (giữa act_1 và act_2), OSRM call count = 1, AI call count = 0', () async {
      final itinerary = _buildTestItinerary();
      // Sau khi chèn 1 điểm vào danh sách 3 điểm -> 4 waypoints -> 3 legDurations
      final osrm = MockOsrmWithLegDurations([300, 400, 800]);
      final aiService = MockAiSuccess(itinerary);
      final notifier = ItineraryNotifier(
        aiRemoteService: aiService,
        osrmRemoteService: osrm,
      );
      await notifier.saveItinerary(itinerary);

      // Điểm Kim Long (16.4630, 107.5600) nằm giữa Đại Nội (16.4697, 107.5786) và Chùa Thiên Mụ (16.4537, 107.5423)
      final isLate = await notifier.addActivity(
        'itin_test',
        0,
        placeId: 'p_kimlong',
        placeName: 'Chợ Kim Long',
        latitude: 16.4630,
        longitude: 107.5600,
      );

      expect(osrm.callCount, equals(1));
      expect(aiService.generateCount, equals(0));
      expect(isLate, equals(false));

      final updated = notifier.state.myItineraries.first;
      final day = updated.days.first;

      expect(day.activities.length, equals(4));
      // Điểm mới nằm ở vị trí index 1 (sau Đại Nội act_1, trước Chùa Thiên Mụ act_2)
      expect(day.activities[0].id, equals('act_1'));
      expect(day.activities[1].placeId, equals('p_kimlong'));
      expect(day.activities[2].id, equals('act_2'));
      expect(day.activities[3].id, equals('act_3'));
    });

    test('6. addActivity bị chặn khi itinerary.status = completed', () async {
      final itinerary = _buildTestItinerary(status: 'completed');
      final notifier = ItineraryNotifier();
      await notifier.saveItinerary(itinerary);

      expect(
        () async => await notifier.addActivity(
          'itin_test',
          0,
          placeId: 'p_kimlong',
          placeName: 'Chợ Kim Long',
          latitude: 16.4630,
          longitude: 107.5600,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('7. addActivity bị từ chối khi toạ độ cách xa > 50km', () async {
      final itinerary = _buildTestItinerary();
      final notifier = ItineraryNotifier();
      await notifier.saveItinerary(itinerary);

      // Toạ độ Đà Nẵng (~80km từ Huế)
      expect(
        () async => await notifier.addActivity(
          'itin_test',
          0,
          placeId: 'p_danang',
          placeName: 'Cầu Rồng Đà Nẵng',
          latitude: 16.0544,
          longitude: 108.2022,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('8. addActivity vào 1 ngày rỗng (danh sách activities trống) cho phép thêm tự do', () async {
      final emptyDayItinerary = ItineraryModel(
        id: 'itin_empty',
        title: 'Empty Itinerary',
        description: '',
        durationDays: 1,
        budget: 100000,
        interests: [],
        days: [ItineraryDayModel(dayNumber: 1, title: 'Ngày 1', description: '', activities: [])],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final notifier = ItineraryNotifier();
      await notifier.saveItinerary(emptyDayItinerary);

      final isLate = await notifier.addActivity(
        'itin_empty',
        0,
        placeId: 'p_first',
        placeName: 'Địa điểm đầu tiên',
        latitude: 16.4630,
        longitude: 107.5600,
      );

      expect(isLate, equals(false));
      final updated = notifier.state.myItineraries.first;
      expect(updated.days.first.activities.length, equals(1));
      expect(updated.days.first.activities.first.placeId, equals('p_first'));
    });

    test('9. addActivity chèn vào GIỮA: startTime điểm mới thực sự nằm giữa endTime điểm liền trước và startTime điểm liền sau', () async {
      final itinerary = _buildTestItinerary();
      // OSRM 3 leg durations: 300s, 400s, 800s
      final osrm = MockOsrmWithLegDurations([300, 400, 800]);
      final notifier = ItineraryNotifier(
        aiRemoteService: MockAiSuccess(itinerary),
        osrmRemoteService: osrm,
      );
      await notifier.saveItinerary(itinerary);

      final originalLastActivityEndTime = itinerary.days.first.activities.last.endTime;

      // Điểm Kim Long (16.4630, 107.5600) sẽ được nearest-insertion chèn vào index 1 (giữa act_1 và act_2)
      await notifier.addActivity(
        'itin_test',
        0,
        placeId: 'p_kimlong',
        placeName: 'Chợ Kim Long',
        latitude: 16.4630,
        longitude: 107.5600,
      );

      final updatedDay = notifier.state.myItineraries.first.days.first;
      final act1 = updatedDay.activities[0]; // act_1
      final actMid = updatedDay.activities[1]; // p_kimlong (điểm mới)
      final act2 = updatedDay.activities[2]; // act_2

      // 1. startTime của điểm mới phải sau endTime của điểm liền trước (act_1)
      expect(actMid.startTime.isAfter(act1.endTime), isTrue);
      // 2. startTime của điểm liền sau (act_2) phải sau endTime của điểm mới (actMid)
      expect(act2.startTime.isAfter(actMid.endTime), isTrue);
      // 3. startTime của điểm mới KHÔNG bị gán bằng endTime của điểm cuối danh sách gốc
      expect(actMid.startTime, isNot(equals(originalLastActivityEndTime)));

      // Kiểm tra chính xác mốc thời gian OSRM leg 1: act1.endTime + 300 giây
      expect(actMid.startTime, equals(act1.endTime.add(const Duration(seconds: 300))));
      // Kiểm tra chính xác mốc thời gian OSRM leg 2: actMid.endTime + 400 giây
      expect(act2.startTime, equals(actMid.endTime.add(const Duration(seconds: 400))));
    });

    test('10. addActivity chèn vào ĐẦU (bestIndex = 0): giữ nguyên mốc startTime đầu ngày của activity vốn là đầu ngày cũ', () async {
      final itinerary = _buildTestItinerary();
      final originalDayStart = itinerary.days.first.activities.first.startTime; // 08:00 AM
      final osrm = MockOsrmWithLegDurations([300, 400, 800]);
      final notifier = ItineraryNotifier(
        aiRemoteService: MockAiSuccess(itinerary),
        osrmRemoteService: osrm,
      );
      await notifier.saveItinerary(itinerary);

      // Điểm Cầu Tràng Tiền (16.4720, 107.5900) nằm rất gần Đại Nội (16.4697, 107.5786) -> nearest-insertion chọn index 0
      await notifier.addActivity(
        'itin_test',
        0,
        placeId: 'p_trangtien',
        placeName: 'Cầu Tràng Tiền',
        latitude: 16.4720,
        longitude: 107.5900,
      );

      final updatedDay = notifier.state.myItineraries.first.days.first;
      final newFirstAct = updatedDay.activities[0]; // p_trangtien (điểm mới tại index 0)
      final oldFirstAct = updatedDay.activities[1]; // act_1 (đầu ngày cũ, nay ở index 1)

      // 1. Điểm mới tại index 0 thừa hưởng mốc giờ xuất phát đầu ngày gốc (08:00 AM)
      expect(newFirstAct.placeId, equals('p_trangtien'));
      expect(newFirstAct.startTime, equals(originalDayStart));

      // 2. Điểm đầu ngày cũ (nay ở index 1) bị đẩy lùi bởi OSRM: newFirstAct.endTime + 300s
      expect(oldFirstAct.id, equals('act_1'));
      expect(oldFirstAct.startTime, equals(newFirstAct.endTime.add(const Duration(seconds: 300))));
    });

    test('11. saveItinerary có uid → gọi Firestore đúng 1 lần, trả savedToCloud = true', () async {
      final auth = MockFirebaseAuth();
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('user_A');
      when(auth.currentUser).thenReturn(mockUser);
      final firestore = MockItineraryFirestoreService();
      final notifier = ItineraryNotifier(
        firestoreService: firestore,
        auth: auth,
      );

      final saved = await notifier.saveItinerary(_buildTestItinerary());

      expect(saved, isTrue);
      expect(firestore.saveCallCount, equals(1));
      expect(firestore.lastUserId, equals('user_A'));
      expect(firestore.savedIds, contains('itin_test'));
      expect(notifier.state.myItineraries.length, equals(1));
    });

    test('12. saveItinerary uid null (guest) → KHÔNG gọi Firestore, trả savedToCloud = false', () async {
      final auth = MockFirebaseAuth();
      when(auth.currentUser).thenReturn(null);
      final firestore = MockItineraryFirestoreService();
      final notifier = ItineraryNotifier(
        firestoreService: firestore,
        auth: auth,
      );

      final saved = await notifier.saveItinerary(_buildTestItinerary());

      expect(saved, isFalse);
      expect(firestore.saveCallCount, equals(0));
      expect(notifier.state.myItineraries.length, equals(1));
    });

    test('13. reorderActivity trên itinerary đã có trong myItineraries + có uid → Firestore được gọi đúng 1 lần sau đó', () async {
      final itinerary = _buildTestItinerary();
      final osrm = MockOsrmWithLegDurations([600, 1200]);
      final auth = MockFirebaseAuth();
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('user_A');
      when(auth.currentUser).thenReturn(mockUser);
      final firestore = MockItineraryFirestoreService();
      final notifier = ItineraryNotifier(
        aiRemoteService: MockAiSuccess(itinerary),
        osrmRemoteService: osrm,
        firestoreService: firestore,
        auth: auth,
      );
      await notifier.saveItinerary(itinerary);
      expect(firestore.saveCallCount, equals(1));

      final isLate = await notifier.reorderActivity('itin_test', 0, 0, 2);

      expect(isLate, equals(false));
      expect(osrm.callCount, equals(1));
      expect(firestore.saveCallCount, equals(2));
      expect(firestore.savedIds.length, equals(2));
      // State local vẫn được cập nhật đúng thứ tự act_2, act_3, act_1
      final day = notifier.state.myItineraries.first.days.first;
      expect(day.activities[0].id, equals('act_2'));
      expect(day.activities[1].id, equals('act_3'));
      expect(day.activities[2].id, equals('act_1'));
    });

    test('14. Firestore sync lỗi → reorderActivity vẫn trả về isLate đúng, KHÔNG throw ra ngoài', () async {
      final itinerary = _buildTestItinerary();
      final osrm = MockOsrmWithLegDurations([600, 1200]);
      final auth = MockFirebaseAuth();
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('user_A');
      when(auth.currentUser).thenReturn(mockUser);
      final firestore = MockItineraryFirestoreService();
      final notifier = ItineraryNotifier(
        aiRemoteService: MockAiSuccess(itinerary),
        osrmRemoteService: osrm,
        firestoreService: firestore,
        auth: auth,
      );
      await notifier.saveItinerary(itinerary);
      expect(firestore.saveCallCount, equals(1));

      // Từ giờ mọi sync sẽ lỗi (mất mạng)
      firestore.errorToThrow = Exception('mất mạng');

      // Gọi sync lỗi nhưng KHÔNG được có exception nào lọt ra ngoài
      bool threw = false;
      try {
        final isLate = await notifier.reorderActivity('itin_test', 0, 0, 2);
        expect(isLate, equals(false));
      } catch (_) {
        threw = true;
      }
      expect(threw, isFalse);
      expect(osrm.callCount, equals(1));
      expect(firestore.saveCallCount, equals(2));

      // State local vẫn được cập nhật dù sync lỗi (không rollback)
      final day = notifier.state.myItineraries.first.days.first;
      expect(day.activities[0].id, equals('act_2'));
      expect(day.activities[1].id, equals('act_3'));
      expect(day.activities[2].id, equals('act_1'));
    });
  });
}
