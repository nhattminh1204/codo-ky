import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/features/itinerary/data/models/itinerary_model.dart';
import 'package:codoky/features/itinerary/data/services/itinerary_firestore_service.dart';

ItineraryModel _buildItinerary({
  String id = 'it_1',
  String title = 'Lộ trình Cố đô 2 ngày',
}) {
  return ItineraryModel(
    id: id,
    title: title,
    description: 'Khám phá di sản Huế',
    durationDays: 2,
    budget: 1500000,
    interests: const ['di sản', 'ẩm thực'],
    days: [
      ItineraryDayModel(
        dayNumber: 1,
        title: 'Ngày 1',
        description: 'Tham quan trung tâm',
        activities: [
          ItineraryActivityModel(
            id: 'act_1',
            name: 'Đại Nội Huế',
            description: 'Tham quan Hoàng Thành',
            placeId: '669249193',
            placeName: 'Đại Nội Huế',
            latitude: 16.469,
            longitude: 107.577,
            startTime: DateTime(2026, 8, 4, 8, 0),
            endTime: DateTime(2026, 8, 4, 10, 30),
            type: 'attraction',
            estimatedCost: 150000,
            notes: 'Mang mũ nón',
            status: 'draft',
          ),
        ],
      ),
    ],
    imageUrl: 'https://example.com/img.png',
    thumbnailUrl: 'https://example.com/thumb.png',
    rating: 4.8,
    reviewCount: 12,
    isAIGenerated: true,
    status: 'draft',
    createdAt: DateTime(2026, 8, 4, 7, 0),
    updatedAt: DateTime(2026, 8, 4, 7, 30),
  );
}

void main() {
  late FakeFirebaseFirestore firestore;
  late ItineraryFirestoreService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    service = ItineraryFirestoreService(firestore: firestore);
  });

  group('ItineraryFirestoreService', () {
    test('save rồi get lại trả về đúng toàn bộ dữ liệu (kể cả nested days/activities)',
        () async {
      final itinerary = _buildItinerary();

      await service.saveItinerary(itinerary, 'user_A');

      final results = await service.getMyItineraries('user_A');
      expect(results, hasLength(1));

      final saved = results.first;
      expect(saved.id, 'it_1');
      expect(saved.title, 'Lộ trình Cố đô 2 ngày');
      expect(saved.description, 'Khám phá di sản Huế');
      expect(saved.durationDays, 2);
      expect(saved.budget, 1500000);
      expect(saved.interests, ['di sản', 'ẩm thực']);
      expect(saved.imageUrl, 'https://example.com/img.png');
      expect(saved.thumbnailUrl, 'https://example.com/thumb.png');
      expect(saved.rating, 4.8);
      expect(saved.reviewCount, 12);
      expect(saved.isAIGenerated, isTrue);
      expect(saved.status, 'draft');
      expect(saved.createdAt, DateTime(2026, 8, 4, 7, 0));
      expect(saved.updatedAt, DateTime(2026, 8, 4, 7, 30));

      expect(saved.days, hasLength(1));
      final day = saved.days.first;
      expect(day.dayNumber, 1);
      expect(day.title, 'Ngày 1');
      expect(day.description, 'Tham quan trung tâm');

      expect(day.activities, hasLength(1));
      final act = day.activities.first;
      expect(act.id, 'act_1');
      expect(act.name, 'Đại Nội Huế');
      expect(act.description, 'Tham quan Hoàng Thành');
      expect(act.placeId, '669249193');
      expect(act.placeName, 'Đại Nội Huế');
      expect(act.latitude, 16.469);
      expect(act.longitude, 107.577);
      expect(act.startTime, DateTime(2026, 8, 4, 8, 0));
      expect(act.endTime, DateTime(2026, 8, 4, 10, 30));
      expect(act.type, 'attraction');
      expect(act.estimatedCost, 150000);
      expect(act.notes, 'Mang mũ nón');
      expect(act.status, 'draft');
    });

    test('save 2 lần cùng id ghi đè, không tạo bản trùng', () async {
      await service.saveItinerary(_buildItinerary(id: 'it_1'), 'user_A');
      await service.saveItinerary(
        _buildItinerary(id: 'it_1', title: 'Lộ trình đã chỉnh sửa'),
        'user_A',
      );

      final results = await service.getMyItineraries('user_A');
      expect(results, hasLength(1));
      expect(results.first.title, 'Lộ trình đã chỉnh sửa');
    });

    test('delete xong get không còn thấy lộ trình', () async {
      await service.saveItinerary(_buildItinerary(id: 'it_1'), 'user_A');
      await service.saveItinerary(_buildItinerary(id: 'it_2'), 'user_A');

      await service.deleteItinerary('it_1');

      final results = await service.getMyItineraries('user_A');
      expect(results, hasLength(1));
      expect(results.first.id, 'it_2');
    });

    test('get chỉ trả về itinerary của đúng userId (không lẫn user khác)', () async {
      await service.saveItinerary(_buildItinerary(id: 'it_A1'), 'user_A');
      await service.saveItinerary(_buildItinerary(id: 'it_A2'), 'user_A');
      await service.saveItinerary(_buildItinerary(id: 'it_B1'), 'user_B');

      final resultsA = await service.getMyItineraries('user_A');
      final resultsB = await service.getMyItineraries('user_B');

      expect(resultsA.map((e) => e.id), ['it_A1', 'it_A2']);
      expect(resultsB.map((e) => e.id), ['it_B1']);
      expect(resultsA.every((e) => e.id.startsWith('it_A')), isTrue);
      expect(resultsB.every((e) => e.id.startsWith('it_B')), isTrue);
    });
  });
}
