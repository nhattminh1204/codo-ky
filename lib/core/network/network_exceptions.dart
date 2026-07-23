import 'package:dio/dio.dart';

class NetworkExceptions {
  static const String timeout = 'Connection timeout';
  static const String noInternet = 'No internet connection';
  static const String serverError = 'Server error';
  static const String unauthorized = 'Unauthorized';
  static const String forbidden = 'Forbidden';
  static const String notFound = 'Not found';
  static const String badRequest = 'Bad request';
  static const String unknown = 'Unknown error';

  static NetworkExceptions getDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkExceptions._(timeout, error);
      case DioExceptionType.connectionError:
        return NetworkExceptions._(noInternet, error);
      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode, error);
      case DioExceptionType.cancel:
        return NetworkExceptions._('Request cancelled', error);
      case DioExceptionType.unknown:
        return NetworkExceptions._(unknown, error);
      default:
        return NetworkExceptions._(unknown, error);
    }
  }

  static NetworkExceptions _handleStatusCode(int? statusCode, DioException error) {
    switch (statusCode) {
      case 400:
        return NetworkExceptions._(badRequest, error);
      case 401:
        return NetworkExceptions._(unauthorized, error);
      case 403:
        return NetworkExceptions._(forbidden, error);
      case 404:
        return NetworkExceptions._(notFound, error);
      case 500:
      case 502:
      case 503:
      case 504:
        return NetworkExceptions._(serverError, error);
      default:
        return NetworkExceptions._('$serverError: $statusCode', error);
    }
  }

  final String message;
  final DioException? dioException;

  const NetworkExceptions._(this.message, this.dioException);

  @override
  String toString() => message;
}