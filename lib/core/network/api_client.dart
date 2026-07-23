import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/config/constants/app_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(seconds: AppConstants.defaultTimeout),
      receiveTimeout: Duration(seconds: AppConstants.defaultTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) {
        // Pass error through, conversion handled at call site
        return handler.next(error);
      },
      onRequest: (options, handler) {
        // Add auth token if available
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
    ),
  );

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(dioProvider));
});

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return response.data;
  }

  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.post(path, data: data, queryParameters: queryParameters);
    return response.data;
  }

  Future<dynamic> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.put(path, data: data, queryParameters: queryParameters);
    return response.data;
  }

  Future<dynamic> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.patch(path, data: data, queryParameters: queryParameters);
    return response.data;
  }

  Future<dynamic> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    final response = await _dio.delete(path, queryParameters: queryParameters);
    return response.data;
  }
}