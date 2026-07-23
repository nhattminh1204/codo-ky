import 'package:codoky/core/utils/extensions/extensions.dart';

class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ email';
    }
    if (!value.trim().isValidEmail()) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < minLength) {
      return 'Mật khẩu phải có tối thiểu $minLength ký tự';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận lại mật khẩu';
    }
    if (value != password) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  static String? required(String? value, {String fieldName = 'Trường này'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    if (!value.trim().isValidPhoneNumber()) {
      return 'Số điện thoại không hợp lệ (VD: 0912345678)';
    }
    return null;
  }

  static String? minLength(String? value, int minLength, {String fieldName = 'Trường này'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName không được để trống';
    }
    if (value.length < minLength) {
      return '$fieldName phải có ít nhất $minLength ký tự';
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength, {String fieldName = 'Trường này'}) {
    if (value != null && value.length > maxLength) {
      return '$fieldName không được vượt quá $maxLength ký tự';
    }
    return null;
  }

  static String? rating(double? value) {
    if (value == null) {
      return 'Vui lòng chọn số sao đánh giá';
    }
    if (value < 1 || value > 5) {
      return 'Đánh giá phải từ 1 đến 5 sao';
    }
    return null;
  }
}