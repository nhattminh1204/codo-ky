import 'package:dio/dio.dart';

class NetworkExceptions implements Exception {
  static const String timeout = 'Kết nối mạng quá thời gian chờ (Timeout)';
  static const String noInternet = 'Không có kết nối Internet';
  static const String serverError = 'Máy chủ gặp sự cố. Vui lòng thử lại sau';
  static const String unauthorized = 'Phiên làm việc đã hết hạn hoặc không có quyền';
  static const String forbidden = 'Truy cập bị từ chối';
  static const String notFound = 'Không tìm thấy dữ liệu yêu cầu';
  static const String badRequest = 'Yêu cầu không hợp lệ';
  static const String rateLimit = 'Hệ thống đang bận do nhận quá nhiều yêu cầu (Rate Limit). Vui lòng thử lại sau';
  static const String unknown = 'Đã xảy ra lỗi kết nối không xác định';

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
        return NetworkExceptions._('Yêu cầu đã bị hủy', error);
      case DioExceptionType.unknown:
        if (error.error != null && error.error.toString().contains('SocketException')) {
          return NetworkExceptions._(noInternet, error);
        }
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
      case 429:
        return NetworkExceptions._(rateLimit, error);
      case 500:
      case 502:
      case 503:
      case 504:
        return NetworkExceptions._(serverError, error);
      default:
        return NetworkExceptions._('Lỗi máy chủ ($statusCode)', error);
    }
  }

  final String message;
  final DioException? dioException;

  const NetworkExceptions._(this.message, this.dioException);

  @override
  String toString() => message;
}