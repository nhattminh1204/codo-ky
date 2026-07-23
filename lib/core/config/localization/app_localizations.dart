import 'package:flutter/material.dart';
import 'dart:async';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const List<Locale> supportedLocales = [
    Locale('vi'),
    Locale('en'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get appName => 'CodoKy';
  String get map => locale.languageCode == 'vi' ? 'Bản đồ' : 'Map';
  String get itinerary => locale.languageCode == 'vi' ? 'Lộ trình' : 'Itinerary';
  String get explore => locale.languageCode == 'vi' ? 'Khám phá' : 'Explore';
  String get review => locale.languageCode == 'vi' ? 'Đánh giá' : 'Review';
  String get login => locale.languageCode == 'vi' ? 'Đăng nhập' : 'Login';
  String get register => locale.languageCode == 'vi' ? 'Đăng ký' : 'Register';
  String get logout => locale.languageCode == 'vi' ? 'Đăng xuất' : 'Logout';
  String get profile => locale.languageCode == 'vi' ? 'Hồ sơ' : 'Profile';
  String get settings => locale.languageCode == 'vi' ? 'Cài đặt' : 'Settings';
  String get language => locale.languageCode == 'vi' ? 'Ngôn ngữ' : 'Language';
  String get vietnamese => locale.languageCode == 'vi' ? 'Tiếng Việt' : 'Vietnamese';
  String get english => locale.languageCode == 'vi' ? 'Tiếng Anh' : 'English';
  String get search => locale.languageCode == 'vi' ? 'Tìm kiếm' : 'Search';
  String get nearby => locale.languageCode == 'vi' ? 'Gần đây' : 'Nearby';
  String get popular => locale.languageCode == 'vi' ? 'Phổ biến' : 'Popular';
  String get restaurants => locale.languageCode == 'vi' ? 'Nhà hàng' : 'Restaurants';
  String get attractions => locale.languageCode == 'vi' ? 'Địa điểm' : 'Attractions';
  String get temples => locale.languageCode == 'vi' ? 'Chùa' : 'Temples';
  String get tombs => locale.languageCode == 'vi' ? 'Lăng tẩm' : 'Tombs';
  String get entertainment => locale.languageCode == 'vi' ? 'Giải trí' : 'Entertainment';
  String get save => locale.languageCode == 'vi' ? 'Lưu' : 'Save';
  String get cancel => locale.languageCode == 'vi' ? 'Hủy' : 'Cancel';
  String get confirm => locale.languageCode == 'vi' ? 'Xác nhận' : 'Confirm';
  String get loading => locale.languageCode == 'vi' ? 'Đang tải...' : 'Loading...';
  String get error => locale.languageCode == 'vi' ? 'Có lỗi xảy ra' : 'An error occurred';
  String get retry => locale.languageCode == 'vi' ? 'Thử lại' : 'Retry';
  String get noData => locale.languageCode == 'vi' ? 'Không có dữ liệu' : 'No data available';
  String get email => locale.languageCode == 'vi' ? 'Email' : 'Email';
  String get password => locale.languageCode == 'vi' ? 'Mật khẩu' : 'Password';
  String get confirmPassword => locale.languageCode == 'vi' ? 'Xác nhận mật khẩu' : 'Confirm Password';
  String get fullName => locale.languageCode == 'vi' ? 'Họ và tên' : 'Full Name';
  String get phoneNumber => locale.languageCode == 'vi' ? 'Số điện thoại' : 'Phone Number';
  String get forgotPassword => locale.languageCode == 'vi' ? 'Quên mật khẩu?' : 'Forgot Password?';
  String get dontHaveAccount => locale.languageCode == 'vi' ? 'Chưa có tài khoản?' : "Don't have an account?";
  String get alreadyHaveAccount => locale.languageCode == 'vi' ? 'Đã có tài khoản?' : 'Already have an account?';
  String get signIn => locale.languageCode == 'vi' ? 'Đăng nhập' : 'Sign In';
  String get signUp => locale.languageCode == 'vi' ? 'Đăng ký' : 'Sign Up';
  String get createItinerary => locale.languageCode == 'vi' ? 'Tạo lộ trình' : 'Create Itinerary';
  String get myItineraries => locale.languageCode == 'vi' ? 'Lộ trình của tôi' : 'My Itineraries';
  String get aiSuggestion => locale.languageCode == 'vi' ? 'Đề xuất AI' : 'AI Suggestion';
  String get duration => locale.languageCode == 'vi' ? 'Thời gian' : 'Duration';
  String get budget => locale.languageCode == 'vi' ? 'Ngân sách' : 'Budget';
  String get rating => locale.languageCode == 'vi' ? 'Đánh giá' : 'Rating';
  String get writeReview => locale.languageCode == 'vi' ? 'Viết đánh giá' : 'Write Review';
  String get myReviews => locale.languageCode == 'vi' ? 'Đánh giá của tôi' : 'My Reviews';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .map((l) => l.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}