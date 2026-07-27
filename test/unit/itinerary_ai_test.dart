import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/features/itinerary/data/models/itinerary_model.dart';
import 'package:codoky/features/itinerary/data/services/ai_remote_service.dart';

void main() {
  group('AI Itinerary Model & JSON Parsing Tests', () {
    test('valid AI JSON parses correctly into ItineraryModel', () {
      final jsonRaw = '''
      {
        "title": "Lộ trình Du lịch Huế 2 ngày",
        "description": "Hành trình di sản và ẩm thực Cố đô.",
        "duration_days": 2,
        "budget": 1500000,
        "interests": ["di sản", "ẩm thực"],
        "days": [
          {
            "day_number": 1,
            "title": "Ngày 1: Khám phá Đại Nội & Bún Bò Huế",
            "description": "Tham quan Hoàng Thành buổi sáng",
            "activities": [
              {
                "id": "1",
                "name": "Bún Bò Huế Mụ Rớt",
                "description": "Thưởng thức bún bò chuẩn vị",
                "place_id": "4",
                "place_name": "Bún Bò Huế Mụ Rớt",
                "latitude": 16.465,
                "longitude": 107.585,
                "start_time": "07:30",
                "end_time": "08:30",
                "type": "restaurant",
                "estimated_cost": 50000,
                "notes": "Đi sớm để không phải xếp hàng"
              },
              {
                "id": "2",
                "name": "Đại Nội Huế (Hoàng Thành)",
                "description": "Đi thăm Ngọ Môn và Điện Thái Hòa",
                "place_id": "1",
                "place_name": "Đại Nội Huế",
                "latitude": 16.468,
                "longitude": 107.578,
                "start_time": "09:00",
                "end_time": "11:30",
                "type": "attraction",
                "estimated_cost": 200000,
                "notes": "Nên mua vé gộp di tích"
              }
            ]
          }
        ]
      }
      ''';

      final Map<String, dynamic> decoded = json.decode(jsonRaw);
      final model = ItineraryModel.fromJson(decoded);

      expect(model.title, equals('Lộ trình Du lịch Huế 2 ngày'));
      expect(model.durationDays, equals(2));
      expect(model.budget, equals(1500000.0));
      expect(model.interests, contains('di sản'));
      expect(model.days.length, equals(1));

      final day1 = model.days.first;
      expect(day1.dayNumber, equals(1));
      expect(day1.activities.length, equals(2));

      final stop1 = day1.activities.first;
      expect(stop1.placeName, equals('Bún Bò Huế Mụ Rớt'));
      expect(stop1.latitude, equals(16.465));
      expect(stop1.notes, equals('Đi sớm để không phải xếp hàng'));
    });

    test('malformed or partial JSON handles defaults safely without crashing', () {
      final partialJson = {
        "title": "Lịch trình ngắn",
        "days": [
          {
            "items": [
              {
                "place_name": "Chùa Thiên Mụ",
                "lat": 16.453,
                "lng": 107.544
              }
            ]
          }
        ]
      };

      final model = ItineraryModel.fromJson(partialJson);

      expect(model.title, equals('Lịch trình ngắn'));
      expect(model.days.length, equals(1));
      expect(model.days.first.activities.length, equals(1));
      expect(model.days.first.activities.first.placeName, equals('Chùa Thiên Mụ'));
      expect(model.days.first.activities.first.latitude, equals(16.453));
    });

    test('invalid JSON string decoding throws FormatException correctly', () {
      const invalidJsonStr = '{ "title": "Lỗi JSON thiếu ngoặc" ';

      expect(
        () => json.decode(invalidJsonStr),
        throwsA(isA<FormatException>()),
      );
    });

    test('AiApiException formats error message properly', () {
      final exc = AiApiException('Hệ thống AI đang bận', statusCode: 429);
      expect(exc.toString(), equals('Hệ thống AI đang bận'));
      expect(exc.statusCode, equals(429));
    });
  });
}
