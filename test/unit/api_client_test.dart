import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/core/network/api_client.dart';
import 'package:codoky/core/network/network_exceptions.dart';

void main() {
  group('ApiClient & NetworkExceptions Tests', () {
    late Dio dio;
    late ApiClient apiClient;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://example.com'));
      apiClient = ApiClient(dio);
    });

    test('NetworkExceptions maps DioExceptionType.connectionTimeout correctly', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final exception = NetworkExceptions.getDioException(dioException);

      expect(exception.message, equals(NetworkExceptions.timeout));
      expect(exception.toString(), contains('quá thời gian chờ'));
    });

    test('NetworkExceptions maps DioExceptionType.connectionError (offline) correctly', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      final exception = NetworkExceptions.getDioException(dioException);

      expect(exception.message, equals(NetworkExceptions.noInternet));
      expect(exception.toString(), equals('Không có kết nối Internet'));
    });

    test('NetworkExceptions maps HTTP 429 Rate Limit correctly', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 429,
        ),
      );

      final exception = NetworkExceptions.getDioException(dioException);

      expect(exception.message, equals(NetworkExceptions.rateLimit));
      expect(exception.toString(), contains('Rate Limit'));
    });

    test('NetworkExceptions maps HTTP 500 Server Error correctly', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
      );

      final exception = NetworkExceptions.getDioException(dioException);

      expect(exception.message, equals(NetworkExceptions.serverError));
    });

    test('NetworkExceptions maps HTTP 401 Unauthorized correctly', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      final exception = NetworkExceptions.getDioException(dioException);

      expect(exception.message, equals(NetworkExceptions.unauthorized));
    });

    test('ApiClient calls reject with 401 when token is invalid or missing', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Mock server rejecting request missing valid Bearer token
            if (options.headers['Authorization'] == null) {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  type: DioExceptionType.badResponse,
                  response: Response(
                    requestOptions: options,
                    statusCode: 401,
                  ),
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      expect(
        () async => await apiClient.get('/generateItinerary'),
        throwsA(isA<NetworkExceptions>().having((e) => e.message, 'message', NetworkExceptions.unauthorized)),
      );
    });

    test('ApiClient get() handles exceptions and converts DioException to NetworkExceptions', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionTimeout,
              ),
            );
          },
        ),
      );

      expect(
        () async => await apiClient.get('/places'),
        throwsA(isA<NetworkExceptions>()),
      );
    });

    test('ApiClient post() returns response data on successful request', () async {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'status': 'success', 'data': []},
              ),
            );
          },
        ),
      );

      final result = await apiClient.post('/generateItinerary', data: {});

      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], equals('success'));
    });
  });
}
