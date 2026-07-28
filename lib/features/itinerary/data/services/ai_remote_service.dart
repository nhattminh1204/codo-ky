import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:codoky/core/config/app_config.dart';
import 'package:codoky/core/logging/app_logger.dart';
import 'package:codoky/core/network/api_client.dart';
import 'package:codoky/core/network/network_exceptions.dart';
import 'package:codoky/features/itinerary/data/models/itinerary_model.dart';

class AiApiException implements Exception {
  final String message;
  final int? statusCode;

  AiApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AiRemoteService {
  final ApiClient _apiClient;

  AiRemoteService({ApiClient? apiClient, Dio? dio})
      : _apiClient = apiClient ??
            ApiClient(
              dio ??
                  Dio(
                    BaseOptions(
                      connectTimeout: const Duration(seconds: 20),
                      receiveTimeout: const Duration(seconds: 20),
                      headers: {'Content-Type': 'application/json'},
                    ),
                  ),
            );

  /// Generate AI Itinerary for Hue travel
  Future<ItineraryModel> generateItinerary({
    required int durationDays,
    required double budget,
    required List<String> interests,
    String companion = 'cặp đôi',
  }) async {
    // 1. Load places seed data
    List<dynamic> places = [];
    try {
      final jsonString = await rootBundle.loadString('assets/data/hue_places_seed.json');
      places = json.decode(jsonString) as List<dynamic>;
    } catch (e) {
      AppLogger.w('Failed to load places seed for AI prompt: $e');
    }

    final samplePlaces = places.take(15).map((p) => {
      'id': p['id']?.toString(),
      'name': p['name']?.toString(),
      'category': p['category']?.toString(),
      'lat': p['latitude'],
      'lng': p['longitude'],
      'rating': p['rating'],
      'address': p['address']?.toString(),
    }).toList();

    // 2. Try calling Cloud Function backend if configured
    final functionUrl = AppConfig.apiBaseUrl.isNotEmpty
        ? '${AppConfig.apiBaseUrl}/generateItinerary'
        : 'https://asia-southeast1-codoky.cloudfunctions.net/generateItinerary';

    try {
      AppLogger.i('Calling Cloud Function AI Backend at $functionUrl...');
      final cfResponseData = await _apiClient.post(
        functionUrl,
        data: {
          'durationDays': durationDays,
          'budget': budget,
          'interests': interests,
          'companion': companion,
          'places': samplePlaces,
        },
        options: Options(receiveTimeout: const Duration(seconds: 22)),
      );

      if (cfResponseData != null) {
        final Map<String, dynamic> decoded = cfResponseData is String
            ? json.decode(cfResponseData)
            : Map<String, dynamic>.from(cfResponseData as Map);
        return ItineraryModel.fromJson(decoded);
      }
    } catch (e) {
      AppLogger.w('Cloud Function call skipped or failed ($e). Falling back to direct Gemini API call...');
    }

    // 3. Fallback direct Gemini REST API call
    var apiKey = AppConfig.geminiApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_DEV_GEMINI_API_KEY') {
      apiKey = 'AIzaSyDipy8Mfljw8yn-l5ftOQQscugUIGsv7X0';
    }

    final prompt = '''
Bạn là chuyên gia lập lộ trình du lịch Huế thông minh cho ứng dụng CodoKy.
Hãy tạo một lộ trình du lịch Huế tối ưu dựa trên thông tin sau:
- Số ngày: $durationDays ngày
- Ngân sách dự kiến: ${budget.toInt()} VNĐ
- Đối tượng đi cùng: $companion
- Sở thích: ${interests.join(', ')}

Danh sách một số địa điểm có sẵn tại Huế:
${json.encode(samplePlaces)}

YÊU CẦU BẮT BUỘC:
- Tạo đúng $durationDays ngày (mỗi ngày có tiêu đề và danh sách các hoạt động "activities").
- Ưu tiên chọn các địa điểm từ danh sách trên hoặc các địa điểm có thật nổi tiếng tại Huế.
- Phân bổ thời gian hợp lý (sáng, trưa, chiều, tối).
- Chỉ trả về duy nhất 1 JSON object thuần túy theo đúng định dạng sau, KHÔNG kèm markdown `json` hay giải thích:

{
  "title": "Lộ trình Du lịch Huế $durationDays ngày",
  "description": "Mô tả ngắn gọn hấp dẫn về lịch trình...",
  "duration_days": $durationDays,
  "budget": ${budget.toInt()},
  "interests": ${json.encode(interests)},
  "days": [
    {
      "day_number": 1,
      "title": "Ngày 1: Tiêu đề ngày...",
      "description": "Mô tả ngày...",
      "activities": [
        {
          "id": "p1",
          "name": "Đại Nội Huế",
          "description": "Tham quan Ngọ Môn...",
          "place_id": "1",
          "place_name": "Đại Nội Huế",
          "latitude": 16.468,
          "longitude": 107.578,
          "start_time": "08:00",
          "end_time": "11:00",
          "type": "visit",
          "estimated_cost": 200000,
          "notes": "Ghi chú mẹo đi..."
        }
      ]
    }
  ]
}
''';

    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$apiKey';

    final payload = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'response_mime_type': 'application/json',
      }
    };

    try {
      final responseData = await _apiClient.post(url, data: payload);

      if (responseData == null) {
        throw AiApiException('Không nhận được phản hồi từ AI.');
      }

      final data = responseData as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw AiApiException('Hệ thống AI không thể tạo lộ trình lúc này.');
      }

      final text = candidates.first['content']['parts'][0]['text']?.toString() ?? '';
      if (text.trim().isEmpty) {
        throw AiApiException('Dữ liệu AI trả về rỗng.');
      }

      // Clean JSON string if any surrounding text exists
      String jsonStr = text.trim();
      if (jsonStr.startsWith('```json')) {
        jsonStr = jsonStr.substring(7);
      } else if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.substring(3);
      }
      if (jsonStr.endsWith('```')) {
        jsonStr = jsonStr.substring(0, jsonStr.length - 3);
      }
      jsonStr = jsonStr.trim();

      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      return ItineraryModel.fromJson(decoded);
    } on NetworkExceptions catch (e) {
      AppLogger.e('Network exception calling AI API: ${e.message}', e);
      throw AiApiException(e.message);
    } on DioException catch (e) {
      AppLogger.e('Dio error calling AI API: ${e.message}', e);
      final netExp = NetworkExceptions.getDioException(e);
      throw AiApiException(netExp.message);
    } on FormatException catch (e) {
      AppLogger.e('JSON Parse error from AI response: $e');
      throw AiApiException('Định dạng phản hồi AI không đúng chuẩn JSON.');
    } catch (e) {
      AppLogger.e('Unexpected error generating AI itinerary: $e');
      if (e is AiApiException) rethrow;
      throw AiApiException('Đã xảy ra lỗi khi khởi tạo lộ trình AI: $e');
    }
  }
}

