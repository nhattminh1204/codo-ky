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
  
  // Stores the latest quota returned from the server
  int currentQuota = 0;

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

  /// Detect HTTP 429 Rate Limit or RESOURCE_EXHAUSTED errors
  bool _isRateLimitError(dynamic e) {
    if (e is DioException) {
      if (e.response?.statusCode == 429) return true;
      final str = e.response?.toString() ?? e.message ?? '';
      if (str.contains('429') || str.contains('RESOURCE_EXHAUSTED')) return true;
    }
    if (e is NetworkExceptions) {
      final msg = e.message.toLowerCase();
      if (msg.contains('429') || msg.contains('rate limit') || msg.contains('quá tải')) return true;
    }
    if (e is AiApiException) {
      if (e.statusCode == 429 || e.message.contains('429') || e.message.contains('quá tải')) return true;
    }
    final s = e.toString().toLowerCase();
    return s.contains('429') || s.contains('resource_exhausted');
  }

  /// Perform POST request with exponential backoff retry for HTTP 429 / Rate limit errors
  Future<dynamic> _postWithExponentialBackoff(
    String url, {
    dynamic data,
    Options? options,
    int maxRetries = 2,
    int initialDelayMs = 1000,
  }) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        return await _apiClient.post(url, data: data, options: options);
      } catch (e) {
        if (_isRateLimitError(e) && attempt <= maxRetries) {
          final delayMs = initialDelayMs * (1 << (attempt - 1)); // 1000ms, 2000ms
          AppLogger.w('⚠️ Gemini API 429 Rate Limit (RESOURCE_EXHAUSTED). Attempt $attempt/$maxRetries failed. Retrying in ${delayMs}ms...');
          await Future.delayed(Duration(milliseconds: delayMs));
          continue;
        }
        rethrow;
      }
    }
  }

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
      final cfResponseData = await _postWithExponentialBackoff(
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
            
        if (decoded.containsKey('currentCount')) {
          currentQuota = decoded['currentCount'] as int;
          AppLogger.i('📊 [Gemini Quota Tracker] Server Count: $currentQuota / 1000 RPD');
        }
            
        return ItineraryModel.fromJson(decoded);
      }
      
      throw AiApiException('Không nhận được phản hồi từ AI.');
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

