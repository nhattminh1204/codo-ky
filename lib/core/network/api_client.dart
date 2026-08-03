import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/config/app_config.dart';
import 'package:codoky/core/config/constants/app_constants.dart';
import 'package:codoky/core/logging/app_logger.dart';
import 'package:codoky/core/network/network_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';

final dioProvider = Provider<Dio>((ref) {
  final baseUrl = AppConfig.apiBaseUrl.isNotEmpty
      ? AppConfig.apiBaseUrl
      : AppConstants.baseUrl;

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
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
      onRequest: (options, handler) async {
        try {
          final token = await FirebaseAuth.instance.currentUser?.getIdToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          AppLogger.w('Failed to attach Firebase token: $e');
        }
        AppLogger.i('🌐 HTTP REQUEST [${options.method}] => Path: ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.i('✅ HTTP RESPONSE [${response.statusCode}] <= Path: ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (error, handler) {
        AppLogger.e('❌ HTTP ERROR [${error.response?.statusCode}] <= Path: ${error.requestOptions.uri}: ${error.message}', error);
        return handler.next(error);
      },
    ),
  );

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// Getter for internal Dio instance if low-level options manipulation is needed
  Dio get dio => _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw NetworkExceptions.getDioException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw NetworkExceptions.getDioException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw NetworkExceptions.getDioException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw NetworkExceptions.getDioException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw NetworkExceptions.getDioException(e);
    } catch (e) {
      rethrow;
    }
  }
}