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

  bool get isVietnamese => locale.languageCode == 'vi';

  String _t(String vi, String en) => isVietnamese ? vi : en;

  String get appName => 'CodoKy';
  String get map => _t('Bản đồ', 'Map');
  String get itinerary => _t('Lộ trình', 'Itinerary');
  String get explore => _t('Khám phá', 'Explore');
  String get review => _t('Đánh giá', 'Review');
  String get login => _t('Đăng nhập', 'Login');
  String get register => _t('Đăng ký', 'Register');
  String get logout => _t('Đăng xuất', 'Logout');
  String get profile => _t('Hồ sơ', 'Profile');
  String get settings => _t('Cài đặt', 'Settings');
  String get language => _t('Ngôn ngữ', 'Language');
  String get vietnamese => _t('Tiếng Việt', 'Vietnamese');
  String get english => _t('Tiếng Anh', 'English');
  String get search => _t('Tìm kiếm', 'Search');
  String get nearby => _t('Gần đây', 'Nearby');
  String get popular => _t('Phổ biến', 'Popular');
  String get restaurants => _t('Nhà hàng', 'Restaurants');
  String get attractions => _t('Địa điểm', 'Attractions');
  String get temples => _t('Chùa', 'Temples');
  String get tombs => _t('Lăng tẩm', 'Tombs');
  String get entertainment => _t('Giải trí', 'Entertainment');
  String get save => _t('Lưu', 'Save');
  String get cancel => _t('Hủy', 'Cancel');
  String get confirm => _t('Xác nhận', 'Confirm');
  String get loading => _t('Đang tải...', 'Loading...');
  String get error => _t('Có lỗi xảy ra', 'An error occurred');
  String get retry => _t('Thử lại', 'Retry');
  String get noData => _t('Không có dữ liệu', 'No data available');
  String get email => _t('Email', 'Email');
  String get password => _t('Mật khẩu', 'Password');
  String get confirmPassword => _t('Xác nhận mật khẩu', 'Confirm Password');
  String get fullName => _t('Họ và tên', 'Full Name');
  String get phoneNumber => _t('Số điện thoại', 'Phone Number');
  String get forgotPassword => _t('Quên mật khẩu?', 'Forgot Password?');
  String get dontHaveAccount => _t('Chưa có tài khoản?', "Don't have an account?");
  String get alreadyHaveAccount => _t('Đã có tài khoản?', 'Already have an account?');
  String get signIn => _t('Đăng nhập', 'Sign In');
  String get signUp => _t('Đăng ký', 'Sign Up');
  String get createItinerary => _t('Tạo lộ trình', 'Create Itinerary');
  String get myItineraries => _t('Lộ trình của tôi', 'My Itineraries');
  String get aiSuggestion => _t('Đề xuất AI', 'AI Suggestion');
  String get duration => _t('Thời gian', 'Duration');
  String get budget => _t('Ngân sách', 'Budget');
  String get rating => _t('Đánh giá', 'Rating');
  String get writeReview => _t('Viết đánh giá', 'Write Review');
  String get myReviews => _t('Đánh giá của tôi', 'My Reviews');

  String get homeTitle => _t('Trang chủ', 'Home');
  String get homeTodo => _t('TODO: Trang chủ (Home)', 'TODO: Home');
  String get offlineTitle => _t('Mất kết nối', 'Offline');
  String get offlineTodo => _t('TODO: Mất kết nối (Offline)', 'TODO: Offline');
  String get splashTagline => _t('DU LỊCH & KHÁM PHÁ CỐ ĐÔ HUẾ', 'TRAVEL & DISCOVER THE IMPERIAL CITY OF HUE');
  String get skip => _t('Bỏ qua', 'Skip');
  String get getStarted => _t('Bắt đầu ngay', 'Get Started');
  String get continueLabel => _t('Tiếp tục', 'Continue');

  String get onboardingTitle1 => _t('Bản Đồ Cố Đô Huế Thông Minh 🗺️', 'Smart Map of Imperial Hue 🗺️');
  String get onboardingSubtitle1 => _t(
      'Khám phá hơn 100+ lăng tẩm, Đại Nội, chùa chiền & quán cafe muối nổi tiếng hoàn toàn miễn phí.',
      'Explore 100+ tombs, the Imperial City, pagodas & famous salt coffee shops completely free.');
  String get onboardingTitle2 => _t('Trợ Lý Lập Lịch Trình AI 🤖', 'AI Itinerary Assistant 🤖');
  String get onboardingSubtitle2 => _t(
      'Tự động tạo lộ trình di sản & ẩm thực cá nhân hóa theo sở thích cá nhân chỉ trong 5 giây.',
      'Automatically generate heritage & food itineraries personalized to your tastes in just 5 seconds.');
  String get onboardingTitle3 => _t('Trải Nghiệm & Tích Điểm VIP 👑', 'Experiences & VIP Points 👑');
  String get onboardingSubtitle3 => _t(
      'Lưu địa điểm yêu thích, viết đánh giá du khách và thăng hạng nhận ưu đãi Thành viên Vàng.',
      'Save favorite places, write traveler reviews and level up to receive Gold Member benefits.');

  String get settingsTitle => _t('Cài đặt ứng dụng', 'App Settings');
  String get defaultUserName => _t('Người dùng CodoKy', 'CodoKy User');
  String get edit => _t('Sửa', 'Edit');
  String get appConfigSection => _t('CẤU HÌNH ỨNG DỤNG', 'APP CONFIGURATION');
  String get displayLanguage => _t('Ngôn ngữ hiển thị', 'Display Language');
  String get notificationsTitle => _t('Thông báo nhắc nhở', 'Reminder Notifications');
  String get notificationsSubtitle => _t(
      'Nhận gợi ý địa điểm & nhắc lịch trình', 'Get place suggestions & itinerary reminders');
  String get gpsAccess => _t('Quyền truy cập GPS', 'GPS Access');
  String get gpsSubtitle => _t(
      'Tự động xác định vị trí trên bản đồ Huế', 'Automatically detect location on the Hue map');
  String get darkModeToggle => _t('Chế độ Tối (Dark Mode)', 'Dark Mode');
  String get infoHelpSection => _t('THÔNG TIN & TRỢ GIÚP', 'INFO & HELP');
  String get privacyPolicy => _t('Chính sách bảo mật', 'Privacy Policy');
  String get privacyPolicyMessage => _t(
      'Ứng dụng CodoKy tuân thủ chính sách bảo mật thông tin người dùng.',
      'The CodoKy app complies with user information privacy policies.');
  String get appVersion => _t('Phiên bản ứng dụng', 'App Version');

  String get navMap => _t('Bản đồ', 'Map');
  String get navExplore => _t('Khám phá', 'Explore');
  String get navCamera => _t('Camera', 'Camera');
  String get navItinerary => _t('Lịch trình', 'Itinerary');
  String get navProfile => _t('Hồ sơ', 'Profile');

  String get searchPlacesHint => _t('Tìm kiếm địa điểm, món ăn...', 'Search places, food...');
  String get travelWalking => _t('Đi bộ', 'Walking');
  String get travelMotorbike => _t('Xe máy', 'Motorbike');
  String get travelDriving => _t('Ô tô', 'Driving');

  String get recentSearches => _t('TÌM KIẾM GẦN ĐÂY', 'RECENT SEARCHES');
  String get clearAll => _t('Xóa tất cả', 'Clear all');
  String get searchCleared => _t('Đã xóa lịch sử tìm kiếm.', 'Search history cleared.');
  String get popularKeywords => _t('TỪ KHÓA ĐƯỢC TÌM NHIỀU 🔥', 'POPULAR SEARCHES 🔥');
  String get searchHint => _t('Tìm địa điểm, quán ăn, di tích Huế...', 'Search Hue places, restaurants, monuments...');
  String noResultsFor(String query) => _t(
      'Không tìm thấy địa điểm nào khớp với "$query"',
      'No places match "$query"');
  String get fallbackPlaceName => _t('Địa điểm Huế', 'Hue place');
  String get fallbackAddress => _t('Thừa Thiên Huế', 'Thua Thien Hue');

  String get greetingMorning => _t('Chào buổi sáng', 'Good morning');
  String get greetingAfternoon => _t('Chào buổi chiều', 'Good afternoon');
  String get greetingEvening => _t('Chào buổi tối', 'Good evening');

  String get continueWithGoogle => _t('Tiếp tục với Google', 'Continue with Google');
  String get continueWithApple => _t('Tiếp tục với Apple', 'Continue with Apple');
  String get continueWithPhone => _t('Tiếp tục với Số điện thoại', 'Continue with Phone');

  String get routeNotFound => _t('Không tìm thấy trang: ', 'Page not found: ');

  String get categoryAll => _t('Tất cả', 'All');
  String get categorySites => _t('Di tích', 'Sites');
  String get categoryFood => _t('Ẩm thực', 'Food');
  String get categoryCafe => _t('Cà phê', 'Cafe');
  String get categoryStay => _t('Lưu trú', 'Stay');

  String get chipRestaurant => _t('Quán ăn', 'Restaurant');
  String get chipAttraction => _t('Địa điểm', 'Place');
  String get chipTemple => _t('Chùa chiền', 'Temple');
  String get chipTomb => _t('Lăng tẩm', 'Tomb');
  String get chipSightseeing => _t('Tham quan', 'Sightseeing');

  String get exploreHeroTitle => _t('Khám phá Cố đô Huế 🌸', 'Discover Imperial Hue 🌸');
  String get exploreHeroSubtitle => _t('Di sản, ẩm thực & nét đẹp sông Hương', 'Heritage, cuisine & the beauty of the Perfume River');
  String get exploreSearchHint => _t('Tìm địa điểm, món ăn, lăng tẩm Huế...', 'Search places, food, Hue tombs...');
  String get featuredCategories => _t('DANH MỤC NỔI BẬT HUẾ', 'FEATURED HUE CATEGORIES');
  String themesCount(int count) => _t('$count Chủ đề', '$count Themes');
  String placeCount(int count) => _t('$count địa điểm', '$count places');
  String get hotPlaces => _t('ĐỊA ĐIỂM HOT CẦN GHÉ', 'MUST-VISIT HOT PLACES');
  String get seeAll => _t('Xem tất cả >', 'See all >');
  String get experiences => _t('TRẢI NGHIỆM ĐẶC SẮC CỐ ĐÔ', 'SIGNATURE IMPERIAL EXPERIENCES');
  String get experienceTeaTitle => _t('Thưởng Trà chiều bên Sông Hương', 'Afternoon Tea by the Perfume River');
  String get experienceTeaSubtitle => _t('Ngắm hoàng hôn thơ mộng và nghe nhã nhạc Huế', 'Watch the romantic sunset and listen to Hue court music');
  String get experienceChill => _t('Trải nghiệm Chill', 'Chill Experience');
  String get experienceHatTitle => _t('Làng Nghề Làm Nón Lá Thủy Xuân', 'Thuy Xuan Conical Hat Village');
  String get experienceHatSubtitle => _t('Con đường chân nón rực rỡ sắc màu check-in', 'A colorful check-in worthy hat-palm road');
  String get checkinHot => _t('Check-in Hot', 'Check-in Hot');

  String get categoryHeritageTitle => _t('Di sản & Lịch sử', 'Heritage & History');
  String get categoryHeritageSubtitle => _t('Đại Nội, Lăng tẩm & Di tích', 'Imperial City, Tombs & Monuments');
  String get categoryFoodTitle => _t('Ẩm thực Cố đô', 'Imperial Cuisine');
  String get categoryFoodSubtitle => _t('Bún bò, Cơm hến & Bánh Huế', 'Beef noodle, mussel rice & Hue cakes');
  String get categorySpiritualTitle => _t('Tâm linh & Chùa', 'Spirituality & Pagodas');
  String get categorySpiritualSubtitle => _t('Chùa Thiên Mụ, Từ Hiếu', 'Thien Mu Pagoda, Tu Hieu');
  String get categoryCafeTitle => _t('Đời sống & Cafe', 'Lifestyle & Cafes');
  String get categoryCafeSubtitle => _t('Cafe muối, Trà đình & Góc phố', 'Salt coffee, tea houses & street corners');
  String get categoryShoppingTitle => _t('Phố đêm & Mua sắm', 'Nightlife & Shopping');
  String get categoryShoppingSubtitle => _t('Chợ Đông Ba, Phố đi bộ', 'Dong Ba Market, Walking Street');
  String get categoryCultureTitle => _t('Nghệ thuật & Trải nghiệm', 'Art & Experiences');
  String get categoryCultureSubtitle => _t('Ca Huế sông Hương, Làng nón', 'Hue court music on the Perfume River, hat village');

  String get categoryFoodHeaderTitle => _t('Ẩm thực Cố đô Huế 🍜', 'Hue Imperial Cuisine 🍜');
  String get categoryFoodHeaderSubtitle => _t('Đặc sản Bún bò, Cơm hến & Bánh Huế truyền thống', 'Specialty beef noodle, mussel rice & traditional Hue cakes');
  String get categoryTempleHeaderTitle => _t('Tâm linh & Chùa Huế ⛩️', 'Hue Spirituality & Pagodas ⛩️');
  String get categoryTempleHeaderSubtitle => _t('Khám phá các ngôi chùa cổ thanh tịnh linh thiêng', 'Discover the sacred serene ancient pagodas');
  String get categoryTombHeaderTitle => _t('Lăng tẩm Triều Nguyễn 🏛️', 'Nguyen Dynasty Tombs 🏛️');
  String get categoryTombHeaderSubtitle => _t('Khải Định, Tự Đức, Minh Mạng & Di tích lịch sử', 'Khai Dinh, Tu Duc, Minh Mang & historical monuments');
  String get categoryCafeHeaderTitle => _t('Đời sống & Cafe Huế ☕', 'Hue Lifestyle & Cafes ☕');
  String get categoryCafeHeaderSubtitle => _t('Thưởng thức Cafe muối & Trà đình thơ mộng', 'Enjoy salt coffee & dreamy tea houses');
  String get categoryShoppingHeaderTitle => _t('Phố đêm & Mua sắm 🛍️', 'Nightlife & Shopping 🛍️');
  String get categoryShoppingHeaderSubtitle => _t('Chợ Đông Ba & Phố đi bộ sôi động', 'Dong Ba Market & vibrant walking street');
  String get categoryCultureHeaderTitle => _t('Nghệ thuật & Trải nghiệm 🎶', 'Art & Experiences 🎶');
  String get categoryCultureHeaderSubtitle => _t('Ca Huế sông Hương & Làng nghề truyền thống', 'Hue court music on the Perfume River & traditional crafts');
  String get categoryDefaultHeaderTitle => _t('Di sản & Lịch sử Huế 🏰', 'Hue Heritage & History 🏰');
  String get categoryDefaultHeaderSubtitle => _t('Hoàng Thành, Lăng tẩm triều Nguyễn & Di tích', 'Imperial City, Nguyen Dynasty tombs & monuments');
  String get categorySearchHint => _t('Tìm kiếm trong danh mục này...', 'Search within this category...');
  String placesFound(int count) => _t('$count địa điểm được tìm thấy', '$count places found');
  String get topRated => _t('Đánh giá cao ★', 'Top Rated ★');
  String get noPlacesFound => _t('Không tìm thấy địa điểm phù hợp.', 'No matching places found.');
  String get fallbackTicketLabel => _t('Tham quan di tích', 'Sightseeing');
  String get fallbackTag => _t('📍 Điểm đến Huế', '📍 Hue destination');

  String get appleAndroidWarning => _t(
      'Đăng nhập Apple trên Android cần cấu hình Service ID trên Apple Developer Portal.',
      'Apple Sign-In on Android requires a Service ID configured in the Apple Developer Portal.');
  String get welcomeTitle => _t('Chào mừng tới CodoKy', 'Welcome to CodoKy');
  String get welcomeSubtitle => _t('Khám phá di sản • Văn hóa • Ẩm thực Huế', 'Discover heritage • Culture • Hue cuisine');
  String get termsPrefix => _t('Bằng việc tiếp tục, bạn đồng ý với ', 'By continuing, you agree to the ');
  String get termsOfService => _t('Điều khoản dịch vụ', 'Terms of Service');
  String get termsAnd => _t(' & ', ' & ');
  String get termsSuffix => _t(' của CodoKy.', ' of CodoKy.');
  String get forgotPasswordTitle => _t('Quên mật khẩu', 'Forgot Password');
  String get resetPassword => _t('Đặt lại mật khẩu', 'Reset Password');
  String get forgotPasswordSubtitle => _t(
      'Nhập email đã đăng ký tài khoản CodoKy của bạn để nhận liên kết khôi phục mật khẩu.',
      'Enter your registered CodoKy account email to receive a password recovery link.');
  String get emailRegistered => _t('Email đăng ký', 'Registered Email');
  String get emailHint => _t('Nhập địa chỉ email của bạn', 'Enter your email address');
  String get sendResetRequest => _t('Gửi yêu cầu khôi phục', 'Send Recovery Request');
  String get resetEmailSent => _t(
      'Đã gửi email khôi phục mật khẩu. Vui lòng kiểm tra hộp thư của bạn!',
      'Password recovery email sent. Please check your inbox!');
  String get registerAppBar => _t('Đăng ký tài khoản', 'Register Account');
  String get createNewAccount => _t('Tạo tài khoản mới', 'Create New Account');
  String get registerSubtitle => _t('Bắt đầu hành trình khám phá Huế cùng CodoKy', 'Start your Hue discovery journey with CodoKy');
  String get fullNameHint => _t('Nhập họ và tên của bạn', 'Enter your full name');
  String get emailAddressHint => _t('Nhập địa chỉ email', 'Enter your email address');
  String get phoneHint => _t('Nhập số điện thoại (VD: 0912345678)', 'Enter phone number (e.g. 0912345678)');
  String get passwordHint => _t('Nhập mật khẩu (tối thiểu 8 ký tự)', 'Enter password (minimum 8 characters)');
  String get confirmPasswordHint => _t('Nhập lại mật khẩu', 'Re-enter password');
  String get orRegisterWith => _t('Hoặc đăng ký với', 'Or register with');
  String get loginNow => _t('Đăng nhập ngay', 'Login Now');

  String get onboardingCatFoodLabel => _t('Ẩm thực Huế', 'Hue Cuisine');
  String get onboardingCatFoodDesc => _t('Cơm hến, Bún bò, Bánh lọc, Trà cung đình', 'Mussel rice, beef noodle, filter cakes, court tea');
  String get onboardingCatHistoryLabel => _t('Lịch sử & Di sản', 'History & Heritage');
  String get onboardingCatHistoryDesc => _t('Đại Nội, Lăng tẩm các vua Nguyễn', 'Imperial City, Nguyen royal tombs');
  String get onboardingCatSpiritualLabel => _t('Tâm linh & Chùa', 'Spirituality & Pagodas');
  String get onboardingCatSpiritualDesc => _t('Chùa Thiên Mụ, Chùa Từ Đàm, Thiền viện', 'Thien Mu Pagoda, Tu Dam Pagoda, Meditation centers');
  String get onboardingCatNatureLabel => _t('Thiên nhiên & Cảnh quan', 'Nature & Scenery');
  String get onboardingCatNatureDesc => _t('Sông Hương, Núi Ngự Bình, Đồi Vọng Cảnh', 'Perfume River, Ngu Binh Mountain, Vong Canh Hill');
  String get onboardingCatCafeLabel => _t('Đời sống & Cafe', 'Lifestyle & Cafes');
  String get onboardingCatCafeDesc => _t('Quán cafe góc phố, Trà chiều Huế', 'Street corner cafes, Hue afternoon tea');
  String get onboardingCatShoppingLabel => _t('Mua sắm & Phố đêm', 'Shopping & Nightlife');
  String get onboardingCatShoppingDesc => _t('Chợ Đông Ba, Phố đi bộ Nguyễn Đình Chiểu', 'Dong Ba Market, Nguyen Dinh Chieu walking street');
  String get onboardingCatArtLabel => _t('Nghệ thuật & Nhã nhạc', 'Art & Court Music');
  String get onboardingCatArtDesc => _t('Ca Huế trên sông Hương, Làng nghề truyền thống', 'Hue court music on the Perfume River, traditional crafts');
  String get selectAtLeastOnePreference => _t(
      'Vui lòng chọn ít nhất 1 sở thích để AI gợi ý lịch trình tốt nhất cho bạn!',
      'Please select at least 1 interest so AI can suggest the best itinerary for you!');
  String get cantSavePreferences => _t('Không thể lưu sở thích.', 'Could not save preferences.');
  String get travelPreferences => _t('Sở thích du lịch', 'Travel Preferences');
  String get whichExperience => _t('Bạn yêu thích trải nghiệm nào ở Huế?', 'Which experiences in Hue do you love?');
  String get preferencesSubtitle => _t(
      'Chọn các chủ đề bạn quan tâm để CodoKy AI cá nhân hóa lịch trình cho riêng bạn.',
      'Select topics you care about so CodoKy AI personalizes itineraries just for you.');
  String saveAndExplore(int count) => _t(
      'Lưu & Khám phá ngay ($count)', 'Save & Explore Now ($count)');

  String get updateProfileSuccess => _t('Đã cập nhật thông tin hồ sơ và sở thích thành công!', 'Profile and preferences updated successfully!');
  String get updateProfileFailed => _t('Cập nhật hồ sơ thất bại.', 'Profile update failed.');
  String get editProfile => _t('Chỉnh sửa hồ sơ', 'Edit Profile');
  String get personalInfo => _t('Thông tin cá nhân', 'Personal Information');
  String get fullNameNewHint => _t('Nhập họ và tên mới', 'Enter new full name');
  String get phoneNewHint => _t('Nhập số điện thoại mới', 'Enter new phone number');
  String get avatarUrlLabel => _t('Đường dẫn ảnh đại diện (Avatar URL)', 'Avatar image URL');
  String get avatarUrlHint => _t('https://example.com/avatar.jpg', 'https://example.com/avatar.jpg');
  String get personalInterests => _t('Sở thích du lịch cá nhân', 'Personal Travel Interests');
  String get interestsSubtitle => _t('Chọn các chủ đề để AI gợi ý lịch trình chính xác:', 'Select topics so AI can suggest accurate itineraries:');
  String get saveChanges => _t('Lưu thay đổi', 'Save Changes');

  String get profileTitle => _t('Hồ sơ cá nhân', 'Personal Profile');
  String get guestWelcome => _t('Khách ghé thăm', 'Guest Visitor');
  String get guestSubtitle => _t('Đăng nhập để lưu hành trình & nhận thưởng', 'Log in to save itineraries & earn rewards');
  String get guestFeature1 => _t('Lưu lại các địa điểm và nhà hàng yêu thích ở Huế', 'Save your favorite places and restaurants in Hue');
  String get guestFeature2 => _t('Lên lịch trình bằng công cụ AI tự động', 'Plan itineraries with the automatic AI tool');
  String get guestFeature3 => _t('Tích điểm thành viên, nhận ưu đãi độc quyền', 'Earn member points, get exclusive offers');
  String get loginRegister => _t('Đăng nhập / Đăng ký', 'Login / Register');
  String get noEmailYet => _t('Chưa cập nhật email', 'Email not updated yet');
  String get goldMember => _t('Thành viên Vàng', 'Gold Member');
  String get regularMember => _t('Thành viên Thường', 'Regular Member');
  String get statItinerary => _t('Lịch trình', 'Itineraries');
  String get statSaved => _t('Đã lưu', 'Saved');
  String get statReviews => _t('Đánh giá', 'Reviews');
  String get statOfMine => _t('Của tôi', 'Of Mine');
  String get statPoints => _t('Điểm thưởng', 'Points');
  String get journeyData => _t('HÀNH TRÌNH & DỮ LIỆU', 'JOURNEY & DATA');
  String get mySavedTripsSubtitle => _t('Các chuyến đi đã lưu trữ', 'Stored trips');
  String get myReviewsSubtitle => _t('Nhận xét & review địa điểm', 'Comments & place reviews');
  String get savedPlaces => _t('Địa điểm đã lưu', 'Saved Places');
  String get savedPlacesSubtitle => _t('Xem lại các điểm check-in yêu thích', 'Review your favorite check-ins');
  String get personalInfoHeader => _t('THÔNG TIN CÁ NHÂN', 'PERSONAL INFORMATION');
  String get notUpdated => _t('Chưa cập nhật', 'Not updated');
  String get joinedDate => _t('Ngày tham gia', 'Join Date');
  String get appearanceSettings => _t('GIAO DIỆN & CÀI ĐẶT', 'APPEARANCE & SETTINGS');
  String get systemMode => _t('Theo hệ thống 📱', 'System 📱');
  String get lightMode => _t('Giao diện sáng ☀️', 'Light Mode ☀️');
  String get darkModeTheme => _t('Đêm Hoàng Thành (Dark Mode) 🌙', 'Imperial Night (Dark Mode) 🌙');
  String get appTheme => _t('Giao diện ứng dụng', 'App Appearance');
  String get logoutConfirmTitle => _t('Đăng xuất tài khoản?', 'Log out of account?');
  String get logoutConfirmMessage => _t('Bạn có chắc muốn đăng xuất khỏi ứng dụng CodoKy?', 'Are you sure you want to log out of CodoKy?');
  String get themeSheetTitle => _t('Giao diện ứng dụng', 'App Appearance');
  String get themeLightTitle => _t('Giao diện sáng', 'Light Mode');
  String get themeLightSubtitle => _t('Nền Kem Đất Nung sang trọng', 'Elegant terracotta cream background');
  String get themeDarkTitle => _t('Chế độ tối (Đêm Hoàng Thành)', 'Dark Mode (Imperial Night)');
  String get themeDarkSubtitle => _t('Dịu mắt ban đêm', 'Easy on the eyes at night');
  String get themeSystemTitle => _t('Theo cài đặt hệ thống', 'Follow System Settings');
  String get themeSystemSubtitle => _t('Tự động đồng bộ theo thiết bị', 'Automatically sync with your device');

  String get cameraTapHint => _t('Chạm để tải ảnh di sản quét AI', 'Tap to load a heritage photo for AI scanning');
  String get cameraDevHint => _t('(Chế độ Dev Windows / Thư viện)', '(Dev Mode Windows / Library)');
  String get cameraAnalyzing => _t('AI Gemini đang phân tích di sản...', 'AI Gemini is analyzing the heritage...');
  String get cameraSaved => _t('✨ Đã lưu vào bộ sưu tập hành trình Huế của bạn!', '✨ Saved to your Hue journey collection!');
  String cameraShared(String name) => _t('Đã chia sẻ bài viết $name!', 'Shared $name post!');
  String get heritageHue => _t('di sản Huế', 'Hue heritage');
  String get cameraNoPhoto => _t('Vui lòng chụp ảnh để quét AI', 'Please take a photo to scan with AI');
  String cameraCaptureError(String error) => _t('Không thể chụp ảnh: $error', 'Could not take photo: $error');
  String get cameraLandmarkFoodName => _t('Bún Bò Huế Chuẩn Vị Imperial', 'Imperial-Style Hue Beef Noodle');
  String get cameraLandmarkFoodDesc => _t(
      'Món ăn đặc sản Cố đô với nước dùng đậm đà sả ớt, chả quết tươi và sợi bánh to trứ danh.',
      'The signature dish of the Imperial City with a rich lemongrass-chili broth, fresh pork balls and famous thick noodles.');
  String get cameraLandmarkAoDaiName => _t('Áo Dài Nhật Bình Triều Nguyễn', 'Nhat Binh Ao Dai of the Nguyen Dynasty');
  String get cameraLandmarkAoDaiDesc => _t(
      'Trang phục triều đình Huế dành cho Hoàng hậu và Công chúa với hoa văn thêu tay tinh xảo.',
      'Hue court attire for Empresses and Princesses with exquisite hand-embroidered patterns.');
  String get cameraLandmarkCitadelName => _t('Đại Nội Huế (Hoàng Thành Huế)', 'Imperial City of Hue');
  String get cameraLandmarkCitadelDesc => _t(
      'Kinh thành triều Nguyễn xây dựng từ năm 1804, di sản văn hóa thế giới được UNESCO công nhận năm 1993.',
      'The Nguyen Dynasty capital built from 1804, a UNESCO World Cultural Heritage site recognized in 1993.');

  String get duration1d => _t('1 Ngày (Nhanh)', '1 Day (Fast)');
  String get duration2d => _t('2 Ngày 1 Đêm', '2 Days 1 Night');
  String get duration3d => _t('3 Ngày 2 Đêm (Khuyên dùng)', '3 Days 2 Nights (Recommended)');
  String get duration4d => _t('4 Ngày 3 Đêm (Trọn vẹn)', '4 Days 3 Nights (Complete)');
  String get companionSolo => _t('Một mình 🎒', 'Solo 🎒');
  String get companionCouple => _t('Cặp đôi 👩‍❤️‍👨', 'Couple 👩‍❤️‍👨');
  String get companionFamily => _t('Gia đình 👨‍👩‍👧‍👦', 'Family 👨‍👩‍👧‍👦');
  String get companionFriends => _t('Nhóm bạn 🚗', 'Friends Group 🚗');
  String get styleHeritage => _t('🏰 Di sản & Lịch sử', '🏰 Heritage & History');
  String get styleFood => _t('🍜 Ẩm thực Cố đô', '🍜 Imperial Cuisine');
  String get styleChill => _t('☕ Chill & Cafe muối', '☕ Chill & Salt Coffee');
  String get styleSpiritual => _t('⛩️ Tâm linh & Chùa cổ', '⛩️ Spirituality & Ancient Pagodas');
  String get styleCheckin => _t('📸 Check-in sống ảo', '📸 Instagram Check-ins');
  String get styleNature => _t('🌿 Sông Hương & Thiên nhiên', '🌿 Perfume River & Nature');
  String get budgetSaving => _t('Tiết kiệm 💡', 'Budget Friendly 💡');
  String get budgetSavingDesc => _t('~ 300k - 500k/ngày', '~ 300k - 500k/day');
  String get budgetStandard => _t('Tiêu chuẩn ⭐', 'Standard ⭐');
  String get budgetStandardDesc => _t('~ 600k - 1tr/ngày', '~ 600k - 1M/day');
  String get budgetVip => _t('Thoải mái VIP 💎', 'Comfortable VIP 💎');
  String get budgetVipDesc => _t('> 1.2tr/ngày', '> 1.2M/day');
  String quotaWarning(int quota) => _t(
      '⚠️ Cảnh báo: Lượt tạo AI của hệ thống sắp hết ($quota/1000)',
      '⚠️ Warning: System AI generation quota is almost exhausted ($quota/1000)');
  String get aiSetupTitle => _t('Thiết lập lịch trình AI', 'AI Itinerary Setup');
  String get heroTitle => _t('CodoKy AI Travel Planner', 'CodoKy AI Travel Planner');
  String get heroSubtitle => _t(
      'Chỉ mất 5 giây để AI thiết kế chuyến đi Huế hoàn hảo dựa trên thời gian, ngân sách và sở thích riêng của bạn.',
      'It takes just 5 seconds for AI to design the perfect Hue trip based on your time, budget and personal interests.');
  String get sectionDuration => _t('1. BẠN SẼ NGHỈ DƯỠNG Ở HUẾ BAO LÂU?', '1. HOW LONG WILL YOU STAY IN HUE?');
  String get sectionCompanion => _t('2. BẠN ĐI CHUYẾN ĐI NÀY CÙNG AI?', '2. WHO ARE YOU TRAVELING WITH?');
  String get sectionStyle => _t('3. PHONG CÁCH DU LỊCH YÊU THÍCH (CHỌN NHIỀU)', '3. FAVORITE TRAVEL STYLES (MULTIPLE)');
  String get sectionBudget => _t('4. DỰ TRÙ NGÂN SÁCH CHI TIÊU', '4. PLANNED BUDGET');
  String get aiGenerating => _t('AI đang lập lịch trình...', 'AI is planning your itinerary...');
  String get createAiItinerary => _t('Tạo Lịch Trình Tự Động AI', 'Generate AI Itinerary');

  String get aiItineraryTitle => _t('Lịch trình AI Huế', 'Hue AI Itinerary');
  String get noItineraryYet => _t('Chưa có lộ trình AI nào được khởi tạo.', 'No AI itinerary has been created yet.');
  String get noItineraryDesc => _t(
      'Hãy thiết lập nhu cầu du lịch để AI đề xuất lịch trình tối ưu nhất.',
      'Set your travel needs so AI can suggest the most optimal itinerary.');
  String get createItineraryNow => _t('Tạo Lộ Trình Ngay ✨', 'Create Itinerary Now ✨');
  String get savedToYourList => _t('Đã lưu lịch trình vào danh sách của bạn!', 'Itinerary saved to your list!');
  String get unsavedFromList => _t('Đã bỏ lưu lịch trình.', 'Itinerary removed from saved list.');
  String get geminiBadge => _t('🌸 Lịch trình Gemini AI', '🌸 Gemini AI Itinerary');
  String durationDaysLabel(int count) => _t('$count Ngày', '$count Days');
  String stopsCount(int count) => _t('$count Điểm dừng', '$count Stops');
  String budgetLabel(int value) => _t('${value}k VNĐ', '${value}k VND');
  String dayTab(int day) => _t('Ngày $day', 'Day $day');
  String get cantEditCompleted => _t('Không thể sửa lộ trình đã hoàn thành.', 'Cannot edit a completed itinerary.');
  String get lateWarning => _t('⚠️ Cảnh báo: Lịch trình vượt quá 22:00 do thay đổi.', '⚠️ Warning: Itinerary exceeds 22:00 due to changes.');
  String errorWith(String message) => _t('Lỗi: $message', 'Error: $message');
  String get noActivitiesForDay => _t('Không có hoạt động nào cho ngày này.', 'No activities for this day.');
  String get addPlaceToItinerary => _t('Thêm điểm đến vào lộ trình', 'Add place to itinerary');
  String get invalidPlaceData => _t('Dữ liệu địa điểm không hợp lệ, vui lòng thử lại', 'Invalid place data, please try again');
  String get lateWarningAdd => _t('⚠️ Cảnh báo: Lịch trình vượt quá 22:00 do thêm địa điểm mới.', '⚠️ Warning: Itinerary exceeds 22:00 due to new place added.');
  String cantAddPlace(String message) => _t('Không thể thêm địa điểm: $message', 'Could not add place: $message');
  String get deleteConfirmTitle => _t('Xác nhận xóa', 'Confirm Deletion');
  String deleteConfirmMessage(String name) => _t(
      'Bạn có chắc chắn muốn xóa "$name" khỏi lộ trình ngày này?',
      'Are you sure you want to remove "$name" from this day\'s itinerary?');
  String get delete => _t('Xóa', 'Delete');
  String cantDeleteActivity(String message) => _t('Không thể xóa hoạt động: $message', 'Could not delete activity: $message');
  String get categoryFoodShort => _t('🍜 Ẩm thực', '🍜 Food');
  String get categorySpiritualShort => _t('⛩️ Tâm linh', '⛩️ Spiritual');
  String get categoryHeritageShort => _t('🏰 Di sản', '🏰 Heritage');
  String get hueLandmark => _t('Điểm tham quan Huế', 'Hue sightseeing spot');
  String get notesPrefix => _t('💡 ', '💡 ');

  String get savedTripsTitle => _t('Lịch trình đã lưu', 'Saved Itineraries');
  String savedTripsCount(int count) => _t('$count CHUYẾN ĐI ĐÃ LƯU', '$count SAVED TRIPS');
  String get createNewAi => _t('Tạo mới AI', 'New AI');
  String get noSavedTrips => _t('Chưa có lịch trình du lịch nào được lưu.', 'No saved travel itineraries yet.');
  String get tripStatusOngoing => _t('Đang diễn ra', 'Ongoing');
  String get tripStatusCompleted => _t('Đã hoàn thành', 'Completed');
  String get tripStatusSaved => _t('Đã lưu', 'Saved');

  String get interestFood => _t('Ăn uống', 'Food & Dining');
  String get interestCulture => _t('Văn hóa - Lịch sử', 'Culture - History');
  String get interestSpiritual => _t('Thiền - Tâm linh', 'Meditation - Spirituality');
  String get interestRelax => _t('Nghỉ dưỡng', 'Relaxation');
  String get interestCheckin => _t('Check-in sống ảo', 'Instagram Check-ins');
  String get interestAdventure => _t('Mạo hiểm', 'Adventure');
  String get aiCreateItinerary => _t('AI Tạo lộ trình', 'AI Create Itinerary');
  String get aiDialogDesc => _t(
      'Nhập thông tin để AI đề xuất lộ trình phù hợp nhất cho bạn',
      'Enter details for AI to suggest the most suitable itinerary for you');
  String get daysLabel => _t('Số ngày:', 'Number of days:');
  String daysCount(int count) => _t('$count ngày', '$count days');
  String get budgetLabelText => _t('Ngân sách dự kiến:', 'Estimated budget:');
  String get vnd => _t('VNĐ', 'VND');
  String get budgetHint => _t('Nhập ngân sách', 'Enter budget');
  String get interestsLabel => _t('Sở thích:', 'Interests:');
  String get aiCreating => _t('AI đang tạo lộ trình...', 'AI is creating your itinerary...');

  String get aiBadge => _t('AI', 'AI');
  String durationDays(int count) => _t('$count ngày', '$count days');
  String reviewCountLabel(int count) => _t('$count đánh giá', '$count reviews');

  String get pickPlaceTitle => _t('Chọn điểm đến Huế ✨', 'Pick a Hue destination ✨');
  String get searchPlaceHint => _t('Tìm địa điểm, di sản, quán ăn...', 'Search places, heritage, restaurants...');
  String get noPlacesEmpty => _t('Không tìm thấy địa điểm nào', 'No places found');
  String get placeLabel => _t('Địa điểm', 'Place');
  String get addLabel => _t('+ Thêm', '+ Add');

  String get stopDetailTitle => _t('Chi tiết điểm dừng', 'Stop Details');
  String recommendedTime(String hours) => _t('⏱️ Thời gian khuyên dùng: $hours Giờ', '⏱️ Recommended time: $hours Hours');
  String get aiTipsHeader => _t('GỢI Ý TỪ TRỢ LÝ AI', 'AI ASSISTANT TIPS');
  String get startGpsNavigation => _t('Chỉ đường GPS', 'GPS Directions');

  String ttsApproach(int meters, String instruction) => _t(
      'Sau ${meters}mét nữa, $instruction',
      'In $meters meters, $instruction');
  String get ttsRecalculating => _t('Đang tính lại tuyến đường mới', 'Recalculating a new route');
  String get recalculatingSnackbar => _t('🔄 Đang tự động tính lại tuyến mới...', '🔄 Automatically recalculating a new route...');
  String get ttsArrived => _t(
      'Bạn đã đến điểm đến! Chúc bạn có trải nghiệm tuyệt vời tại Cố đô Huế.',
      'You have arrived! Have a wonderful experience in Imperial Hue.');
  String get arrivedTitle => _t('Đã Đến Điểm Đến!', 'You Have Arrived!');
  String get arrivedMessage => _t(
      '🎉 Bạn đã đến địa điểm an toàn. Chúc bạn có những phút giây khám phá Cố đô Huế tuyệt vời!',
      '🎉 You have arrived safely. Enjoy wonderful moments exploring Imperial Hue!');
  String get close => _t('Đóng', 'Close');
  String etaLabel(String eta) => _t('Đến lúc $eta', 'Arriving at $eta');
  String get routeCancelled => _t('Đã hủy lộ trình chỉ đường', 'Navigation cancelled');
  String distanceKm(String value) => _t('$value km', '$value km');
  String distanceM(String value) => _t('$value m', '$value m');
  String remainingDistance(String distText) => _t('Còn $distText', '$distText remaining');
  String get voiceOn => _t('Bật âm thanh', 'Turn sound on');
  String get voiceOff => _t('Tắt âm thanh', 'Turn sound off');

  String get mapSearchHint => _t('Tìm kiếm địa điểm...', 'Search places...');
  String filterLabel(int count) => _t('Lọc ($count)', 'Filter ($count)');
  String get filterLabelNoCount => _t('Bộ lọc', 'Filter');
  String get featured => _t('Nổi bật', 'Featured');
  String savedCountLabel(int count) => _t('Đã lưu ($count)', 'Saved ($count)');
  String get all => _t('Tất cả', 'All');
  String get restaurant => _t('Quán ăn', 'Restaurant');
  String get place => _t('Địa điểm', 'Place');
  String get tomb => _t('Lăng tẩm', 'Tomb');
  String get temple => _t('Chùa', 'Pagoda');

  String get mapStyleTooltip => _t('Đổi phong cách bản đồ', 'Change map style');
  String get recenterTooltip => _t('Theo dõi lại vị trí', 'Re-center to my location');
  String get myLocationTooltip => _t('Vị trí của tôi', 'My location');
  String get iconStyleTitle => _t('Tùy Chỉnh Phong Cách Icon', 'Customize Icon Style');
  String get iconStyleSubtitle => _t('Chọn phong cách biểu tượng hiện đại & trẻ trung', 'Choose a modern & youthful icon style');
  String get styleGlowTitle => _t('Gradient Vibrant Glow', 'Gradient Vibrant Glow');
  String get styleGlowSubtitle => _t('Màu sắc đổ bóng rực rỡ, năng động & nổi bật', 'Vibrant glow colors, energetic & standout');
  String get styleDuotoneTitle => _t('Glassmorphic Duotone', 'Glassmorphic Duotone');
  String get styleDuotoneSubtitle => _t('Trong suốt 2 tông màu tinh tế, sang trọng', 'Subtle, elegant two-tone transparency');
  String get style3dTitle => _t('3D Playful Pop', '3D Playful Pop');
  String get style3dSubtitle => _t('Khối 3D bo tròn đầy năng lượng tuổi trẻ', 'Rounded 3D blocks full of youthful energy');

  String get savedCategory => _t('Địa điểm đã lưu', 'Saved Places');
  String get attractionCategory => _t('Địa điểm & Di tích', 'Attractions & Monuments');
  String get restaurantCategory => _t('Nhà hàng & Ẩm thực', 'Restaurants & Cuisine');
  String get templeCategory => _t('Chùa & Tâm linh', 'Pagodas & Spirituality');
  String get tombCategory => _t('Lăng tẩm Triều Nguyễn', 'Nguyen Dynasty Tombs');
  String get cafeCategory => _t('Cafe & Trà Huế', 'Hue Cafes & Tea');
  String get shoppingCategory => _t('Chợ & Mua sắm', 'Markets & Shopping');
  String get cultureCategory => _t('Nghệ thuật & Văn hóa', 'Art & Culture');
  String get filterTitle => _t('Bộ lọc danh mục', 'Category Filters');
  String get filterSubtitle => _t('Chọn một hoặc nhiều danh mục để lọc marker trên bản đồ:', 'Select one or more categories to filter markers on the map:');
  String get reset => _t('Đặt lại', 'Reset');
  String get apply => _t('Áp dụng', 'Apply');

  String get fallbackPlaceName2 => _t('Địa điểm du lịch Huế', 'Hue tourist spot');
  String get fallbackAddress2 => _t('Thành phố Huế, Thừa Thiên Huế', 'Hue City, Thua Thien Hue');
  String get fallbackHours => _t('07:30 - 17:30 (Thứ 2 - Chủ Nhật)', '07:30 - 17:30 (Mon - Sun)');
  String get fallbackTicket => _t('Miễn phí / Hoặc vé tham quan di tích', 'Free / Or monument admission ticket');
  String get fallbackDescription => _t(
      'Quần thể di sản và điểm đến nổi tiếng hàng đầu tại Cố đô Huế. Nơi đây lưu giữ nét đẹp văn hóa, kiến trúc lịch sử đặc sắc của triều đại nhà Nguyễn cùng không gian thơ mộng bên dòng sông Hương.',
      'A premier heritage complex and destination in Imperial Hue. It preserves the distinctive cultural beauty and historical architecture of the Nguyen Dynasty alongside the dreamy scenery of the Perfume River.');
  String get fallbackTag1 => _t('🏰 Di sản Huế', '🏰 Hue Heritage');
  String get fallbackTag2 => _t('📸 Check-in đẹp', '📸 Great Check-in');
  String get fallbackTag3 => _t('🏛️ Kiến trúc Cố đô', '🏛️ Imperial Architecture');
  String get fallbackTag4 => _t('🌿 Cảnh quan thơ mộng', '🌿 Dreamy Landscape');
  String get mockPlaceName => _t('Đại Nội Huế (Hoàng Thành Huế)', 'Imperial City of Hue');
  String get mockAddress => _t('Đường 23/8, Phường Thuận Hòa, Thành phố Huế', '23/8 Street, Thuan Hoa Ward, Hue City');
  String get mockHours => _t('07:00 - 17:30 (Thứ 2 - Chủ Nhật)', '07:00 - 17:30 (Mon - Sun)');
  String get mockTicket => _t('200.000 VNĐ / Người lớn • 40.000 VNĐ / Trẻ em', '200,000 VND / Adult • 40,000 VND / Child');
  String get mockDescription => _t(
      'Đại Nội Huế là quần thể di tích kiến trúc đồ sộ nhất Việt Nam, được UNESCO công nhận là Di sản Văn hóa Thế giới năm 1993. Nơi đây là trung tâm chính trị, văn hóa, tôn giáo của triều đại nhà Nguyễn trong suốt 143 năm tồn tại. Du khách có thể chiêm ngưỡng Ngọ Môn, Điện Thái Hòa, Tử Cấm Thành và rất nhiều công trình kiến trúc cung đình độc đáo khác.',
      'The Imperial City of Hue is Vietnam\'s largest architectural heritage complex, recognized by UNESCO as a World Cultural Heritage site in 1993. It was the political, cultural and religious center of the Nguyen Dynasty for 143 years. Visitors can admire Ngo Mon Gate, Thai Hoa Palace, the Forbidden Purple City and many other unique court architectures.');
  String get mockTag1 => _t('🏰 Di sản UNESCO', '🏰 UNESCO Heritage');
  String get mockTag2 => _t('👑 Hoàng thành', '👑 Imperial City');
  String get mockTag3 => _t('📸 Check-in Huế', '📸 Hue Check-in');
  String get mockTag4 => _t('🏛️ Triều Nguyễn', '🏛️ Nguyen Dynasty');
  String get cantOpenMap => _t('Không thể mở bản đồ chỉ đường.', 'Could not open the directions map.');
  String reviewCountFromTravelers(int count) => _t('($count Đánh giá từ du khách)', '($count traveler reviews)');
  String get directions => _t('Chỉ đường', 'Directions');
  String get contact => _t('Liên hệ', 'Contact');
  String get saveLabel => _t('Lưu lại', 'Save');
  String get savedLabel => _t('Đã lưu', 'Saved');
  String get savedToFavorites => _t('Đã lưu địa điểm vào mục yêu thích!', 'Place saved to favorites!');
  String get removedFromSaved => _t('Đã xóa khỏi danh sách lưu.', 'Removed from saved list.');
  String get addToItinerary => _t('+ Lịch trình', '+ Itinerary');
  String get cantModifyCompletedItinerary => _t('Không thể sửa lịch trình đã hoàn thành.', 'Cannot modify a completed itinerary.');
  String get itinerarySavedSnackbar => _t('Đã lưu lịch trình vào danh sách của bạn!', 'Itinerary saved to your list!');
  String get itineraryUnsavedSnackbar => _t('Đã bỏ lưu lịch trình.', 'Itinerary removed from your list.');
  String get aiSuggestionDialogSubtitle => _t('Nhập thông tin để AI đề xuất lịch trình phù hợp nhất cho bạn', 'Enter details so AI can suggest the best itinerary for you');
  String get selectPlaceTitle => _t('Chọn điểm đến Huế 🗺️', 'Select Hue Destination 🗺️');
  String get addButton => _t('+ Thêm', '+ Add');
  String get openingHours => _t('Giờ mở cửa', 'Opening Hours');
  String get openNow => _t('ĐANG MỞ CỬA', 'OPEN NOW');
  String get ticketPrice => _t('Giá vé / Chi phí', 'Ticket / Cost');
  String get introHistory => _t('GIỚI THIỆU & LỊCH SỬ', 'INTRODUCTION & HISTORY');
  String get locationOnMap => _t('VỊ TRÍ TRÊN BẢN ĐỒ HUẾ', 'LOCATION ON HUE MAP');
  String get openDirections => _t('Mở chỉ đường', 'Open Directions');
  String get travelerReviews => _t('ĐÁNH GIÁ TỪ DU KHÁCH', 'TRAVELER REVIEWS');
  String get noReviewsForPlace => _t('Chưa có đánh giá nào cho địa điểm này.', 'No reviews for this place yet.');
  String get beFirstReviewer => _t('Hãy là người đầu tiên chia sẻ cảm nhận!', 'Be the first to share your thoughts!');
  String get writeReviewNow => _t('Viết Đánh Giá Ngay', 'Write a Review Now');
  String get savedPlaceTopbar => _t('Đã lưu địa điểm!', 'Place saved!');
  String get unsavedPlaceTopbar => _t('Đã bỏ lưu địa điểm.', 'Place removed from saved.');
  String sharePlace(String name) => _t(
      'Khám phá $name cùng ứng dụng du lịch Huế CodoKy!',
      'Discover $name with the CodoKy Hue travel app!');
  String get linkCopied => _t('Đã sao chép liên kết địa điểm!', 'Place link copied!');
  String get navigateHereNow => _t('Chỉ đường tới đây ngay', 'Navigate Here Now');
  String get categoryHeritageBadge => _t('🏰 Di tích & Di sản Lịch sử', '🏰 Monuments & Historical Heritage');
  String get categoryFoodBadge => _t('🍜 Ẩm thực Cố đô Huế', '🍜 Hue Imperial Cuisine');
  String get categorySpiritualBadge => _t('⛩️ Tâm linh & Chùa Huế', '⛩️ Hue Spirituality & Pagodas');
  String get categoryCafeBadge => _t('☕ Cafe & Đời sống Huế', '☕ Hue Cafes & Lifestyle');
  String get categoryDefaultBadge => _t('📍 Địa điểm du lịch Huế', '📍 Hue tourist spot');

  String get ttAddressFallback => _t('Thừa Thiên Huế', 'Thua Thien Hue');
  String get fallbackHoursDaily => _t('07:30 - 17:30 (Hằng ngày)', '07:30 - 17:30 (Daily)');
  String get fallbackTicket2 => _t('Miễn phí / Vé tham quan di tích', 'Free / Monument admission ticket');
  String navigatingTo(String address) => _t('Đang di chuyển đến điểm này • $address', 'Navigating to this place • $address');
  String get openNowCompact => _t('Đang mở cửa', 'Open now');
  String get calculating => _t('Đang tính...', 'Calculating...');
  String get startMoving => _t('Bắt đầu di chuyển', 'Start Navigation');
  String get route => _t('Đường đi', 'Route');
  String ratingReviews(double rating, int count) => _t('$rating ($count đánh giá)', '$rating ($count reviews)');
  String get call => _t('Gọi điện', 'Call');
  String get externalMap => _t('Bản đồ ngoài', 'External Map');
  String get share => _t('Chia sẻ', 'Share');
  String shareLinkCopied(String name) => _t('Đã sao chép liên kết địa điểm "$name"', 'Copied the link for "$name"');
  String get address => _t('Địa chỉ', 'Address');
  String get ticketFee => _t('Giá vé / Phí tham quan', 'Ticket / Entry Fee');
  String get hotline => _t('Liên hệ hotline', 'Hotline');
  String get introHistoryTitle => _t('Giới thiệu & Lịch sử', 'Introduction & History');
  String get tagHeritage => _t('🏰 Di sản Cố Đô', '🏰 Imperial Heritage');
  String get tagCheckin => _t('📸 Check-in đẹp', '📸 Great Check-in');
  String get tagArchitecture => _t('🏛️ Kiến trúc Triều Nguyễn', '🏛️ Nguyen Architecture');
  String get tagScenery => _t('🌿 Không gian thơ mộng', '🌿 Dreamy Space');
  String get reviewsExperiences => _t('Đánh giá & Trải nghiệm', 'Reviews & Experiences');
  String get noReviewsYet => _t('Chưa có bài đánh giá nào. Hãy là người đầu tiên chia sẻ cảm nhận!', 'No reviews yet. Be the first to share your thoughts!');
  String get routeFastest => _t('⚡ Nhanh nhất', '⚡ Fastest');
  String get routeShortest => _t('📍 Ngắn nhất', '📍 Shortest');
  String get routeAlternative => _t('🔄 Tuyến thay thế', '🔄 Alternative Route');
  String get chooseRoute => _t('Chọn tuyến đường', 'Choose Route');
  String extraMinutes(int minutes) => _t('+$minutes ph', '+$minutes min');
  String get catRestaurant => _t('Quán ăn Huế', 'Hue Restaurant');
  String get catHeritagePlace => _t('Địa điểm di sản', 'Heritage Site');
  String get catTemple => _t('Chùa chiền', 'Temple');
  String get catTomb => _t('Lăng tẩm', 'Tomb');
  String get catSightseeing => _t('Tham quan', 'Sightseeing');

  String get reviewsWritten => _t('Đánh giá đã viết', 'Reviews Written');
  String get likesReceived => _t('Lượt thích nhận được', 'Likes Received');
  String get noReviewsContributed => _t('Bạn chưa đóng góp đánh giá nào.', 'You have not contributed any reviews yet.');
  String get shareExperiencePrompt => _t('Hãy chia sẻ trải nghiệm về địa điểm Huế bạn đã ghé thăm!', 'Share your experience about the Hue places you visited!');
  String get reviewListTitle => _t('Đánh giá từ du khách', 'Traveler Reviews');
  String ratingBar(int stars) => _t('$stars ⭐', '$stars ⭐');
  String get beFirstShare => _t('Hãy là người đầu tiên chia sẻ cảm nhận của bạn!', 'Be the first to share your feedback!');

  String get aspectScenery => _t('🏰 Cảnh quan đẹp', '🏰 Beautiful Scenery');
  String get aspectFood => _t('🍜 Món ăn ngon', '🍜 Delicious Food');
  String get aspectPrice => _t('💰 Giá hợp lý', '💰 Reasonable Price');
  String get aspectService => _t('🤝 Phục vụ chu đáo', '🤝 Attentive Service');
  String get aspectPhoto => _t('📸 Góc chụp check-in', '📸 Check-in Photo Spot');
  String get aspectPeace => _t('🌿 Yên tĩnh thư thái', '🌿 Peaceful & Relaxing');
  String get rating1 => _t('Rất thất vọng 😡', 'Very Disappointed 😡');
  String get rating2 => _t('Chưa hài lòng 🙁', 'Not Satisfied 🙁');
  String get rating3 => _t('Bình thường 😐', 'Neutral 😐');
  String get rating4 => _t('Hài lòng 😊', 'Satisfied 😊');
  String get rating5 => _t('Rất tuyệt vời! 😍', 'Absolutely Amazing! 😍');
  String get reviewRequired => _t('Vui lòng viết vài dòng chia sẻ nhận xét của bạn.', 'Please write a few lines sharing your feedback.');
  String get reviewSuccess => _t('Cảm ơn bạn! Đánh giá đã gửi thành công (+20 điểm thưởng VIP).', 'Thank you! Your review was submitted successfully (+20 VIP points).');
  String get writeReviewTitle => _t('Viết đánh giá địa điểm', 'Write a Place Review');
  String get satisfactionLevel => _t('ĐÁNH GIÁ MỨC ĐỘ HÀI LÒNG', 'SATISFACTION LEVEL');
  String get recommendedCriteria => _t('TIÊU CHÍ NỔI BẬT KHUYÊN THÍCH', 'RECOMMENDED HIGHLIGHTS');
  String get detailedContent => _t('NỘI DUNG NHẬN XÉT CHI TIẾT', 'DETAILED REVIEW CONTENT');
  String get reviewHint => _t(
      'Chia sẻ nhận xét thực tế về trải nghiệm, không gian, vị trí hoặc lưu ý khi ghé thăm...',
      'Share real feedback about your experience, atmosphere, location or tips when visiting...');
  String get submitReview => _t('Gửi đánh giá (+20 điểm)', 'Submit Review (+20 points)');

  String get commentsComingSoon => _t('Tính năng bình luận chi tiết đang phát triển.', 'Detailed commenting feature is under development.');
  String shareTemplate(String place, String content, String user) => _t(
      '$place: "$content" - Đánh giá từ $user trên CodoKy',
      '$place: "$content" - Review from $user on CodoKy');
  String get copiedToClipboard => _t('Đã sao chép nội dung đánh giá vào bộ nhớ tạm!', 'Review content copied to clipboard!');

  String get chooseReviewPlace => _t('Chọn địa điểm đánh giá', 'Choose a place to review');
  String get choosePlaceHint => _t('Chọn địa điểm', 'Choose a place');
  String get yourReview => _t('Đánh giá của bạn', 'Your Review');
  String get titleLabel => _t('Tiêu đề', 'Title');
  String get titleHint => _t('Viết tiêu đề đánh giá...', 'Write a review title...');
  String get contentLabel => _t('Nội dung', 'Content');
  String get contentHint => _t('Chia sẻ trải nghiệm của bạn về địa điểm này...', 'Share your experience about this place...');
  String get postReview => _t('Đăng đánh giá', 'Post Review');
  String get chooseRatingFirst => _t('Vui lòng chọn số sao đánh giá', 'Please select a star rating');
  String get travelerName => _t('Du khách Huế', 'Hue Traveler');
  String get reviewPosted => _t('Đăng đánh giá thành công!', 'Review posted successfully!');
  String get userHue => _t('Người dùng Huế', 'Hue User');
  String cannotSubmitReview(String error) => _t('Không thể gửi đánh giá: $error', 'Could not submit review: $error');
  String get noPermissionEdit => _t('Bạn không có quyền chỉnh sửa đánh giá này.', 'You do not have permission to edit this review.');
  String cannotUpdateReview(String error) => _t('Không thể cập nhật đánh giá: $error', 'Could not update review: $error');
  String cannotDeleteReview(String error) => _t('Không thể xóa đánh giá: $error', 'Could not delete review: $error');

  String get validEmailRequired => _t('Vui lòng nhập địa chỉ email', 'Please enter your email address');
  String get validEmailInvalid => _t('Email không đúng định dạng', 'Email is not in a valid format');
  String get validPasswordRequired => _t('Vui lòng nhập mật khẩu', 'Please enter your password');
  String validPasswordMinLength(int minLength) => _t(
      'Mật khẩu phải có tối thiểu $minLength ký tự',
      'Password must be at least $minLength characters');
  String get validConfirmPasswordRequired => _t('Vui lòng xác nhận lại mật khẩu', 'Please confirm your password');
  String get validConfirmPasswordMismatch => _t('Mật khẩu xác nhận không khớp', 'Passwords do not match');
  String get validFieldDefaultName => _t('Trường này', 'This field');
  String validFieldRequired(String fieldName) => _t('$fieldName không được để trống', '$fieldName cannot be empty');
  String get validPhoneRequired => _t('Vui lòng nhập số điện thoại', 'Please enter your phone number');
  String get validPhoneInvalid => _t('Số điện thoại không hợp lệ (VD: 0912345678)', 'Invalid phone number (e.g. 0912345678)');
  String validFieldMinLength(String fieldName, int minLength) => _t(
      '$fieldName phải có ít nhất $minLength ký tự',
      '$fieldName must be at least $minLength characters');
  String validFieldMaxLength(String fieldName, int maxLength) => _t(
      '$fieldName không được vượt quá $maxLength ký tự',
      '$fieldName must not exceed $maxLength characters');
  String get validRatingRequired => _t('Vui lòng chọn số sao đánh giá', 'Please select a star rating');
  String get validRatingRange => _t('Đánh giá phải từ 1 đến 5 sao', 'Rating must be between 1 and 5 stars');

  String get authErrorAccountFetch => _t('Không lấy được thông tin tài khoản', 'Could not fetch account information');
  String get authErrorLoginFailed => _t(
      'Đăng nhập thất bại. Vui lòng kiểm tra lại email và mật khẩu.',
      'Login failed. Please check your email and password.');
  String get authErrorRegisterFailed => _t('Không thể tạo tài khoản', 'Could not create account');
  String get authErrorRegisterGeneric => _t('Đăng ký thất bại. Vui lòng thử lại sau.', 'Registration failed. Please try again later.');
  String get authErrorResetEmail => _t('Không thể gửi email đặt lại mật khẩu.', 'Could not send password reset email.');
  String get authErrorGoogleUnsupported => _t(
      'Đăng nhập Google chưa được hỗ trợ trên nền tảng này. Vui lòng đăng nhập bằng Email/Mật khẩu.',
      'Google Sign-In is not supported on this platform. Please log in with Email/Password.');
  String get authErrorGoogleGeneric => _t(
      'Không thể hoàn tất xác thực Google. Vui lòng thử lại sau.',
      'Could not complete Google authentication. Please try again later.');
  String authErrorGoogleDetail(String rawError) => _t(
      'Đăng nhập bằng Google không thành công. Lỗi: $rawError',
      'Google Sign-In failed. Error: $rawError');
  String get authErrorApple => _t('Đăng nhập bằng Apple không thành công.', 'Apple Sign-In failed.');
  String get authErrorSavePreferences => _t('Không thể lưu sở thích.', 'Could not save preferences.');
  String get authErrorUpdateProfile => _t('Cập nhật hồ sơ thất bại.', 'Profile update failed.');
  String get authErrorRecentLogin => _t(
      'Vì lý do bảo mật, vui lòng đăng xuất và đăng nhập lại trước khi xóa tài khoản.',
      'For security reasons, please log out and log back in before deleting your account.');
  String cannotDeleteAccount(String error) => _t('Không thể xóa tài khoản: $error', 'Could not delete account: $error');
  String get authErrorDeleteGeneric => _t('Xóa tài khoản thất bại. Vui lòng thử lại sau.', 'Account deletion failed. Please try again later.');
  String get authErrorApiKeyInvalid => _t(
      'Lỗi Firebase: FIREBASE_API_KEY chưa hợp lệ (API_KEY_INVALID). Vui lòng dán API Key thật từ Firebase Console vào file .env.dev.',
      'Firebase error: FIREBASE_API_KEY is invalid (API_KEY_INVALID). Please paste the real API Key from the Firebase Console into .env.dev.');
  String get authErrorOperationNotAllowed => _t(
      'Lỗi Firebase: Đăng nhập Google chưa được bật (Enable) trong Firebase Console > Authentication > Sign-in method.',
      'Firebase error: Google Sign-In is not enabled in Firebase Console > Authentication > Sign-in method.');
  String get authErrorUnauthorizedDomain => _t(
      'Lỗi Firebase: Domain hiện tại chưa được thêm vào Authorized Domains (Firebase Console > Authentication > Settings).',
      'Firebase error: The current domain is not added to Authorized Domains (Firebase Console > Authentication > Settings).');
  String get authErrorUserNotFound => _t('Tài khoản email này chưa được đăng ký.', 'This email account is not registered.');
  String get authErrorWrongPassword => _t('Mật khẩu hoặc thông tin đăng nhập không chính xác.', 'Incorrect password or login credentials.');
  String get authErrorEmailInUse => _t('Địa chỉ email này đã được đăng ký tài khoản khác.', 'This email address is already registered to another account.');
  String get authErrorInvalidEmail => _t('Địa chỉ email không đúng định dạng.', 'Invalid email address format.');
  String get authErrorWeakPassword => _t('Mật khẩu quá yếu (tối thiểu 8 ký tự).', 'Password is too weak (minimum 8 characters).');
  String get authErrorUserDisabled => _t('Tài khoản này đã bị tạm khóa.', 'This account has been temporarily disabled.');
  String get authErrorTooManyRequests => _t('Thử quá nhiều lần thất bại. Vui lòng thử lại sau ít phút.', 'Too many failed attempts. Please try again in a few minutes.');
  String get authErrorNetwork => _t('Lỗi kết nối mạng. Vui lòng kiểm tra kết nối Internet.', 'Network error. Please check your Internet connection.');
  String authErrorFirebaseConfig(String code) => _t(
      'Lỗi xác thực Firebase [$code]. Vui lòng kiểm tra lại cấu hình Firebase.',
      'Firebase authentication error [$code]. Please check your Firebase configuration.');
  String authErrorFirebaseRaw(String code, String msg) => _t('[$code] $msg', '[$code] $msg');

  // ── Weather Panel ───────────────────────────────────────────────────────────
  String get weatherPanelTitle => _t('Thời tiết Huế', 'Hue Weather');
  String weatherFeelsLike(int temp) => _t('Cảm như $temp°C', 'Feels like $temp°C');
  String get weatherHumidity => _t('Độ ẩm', 'Humidity');
  String get weatherWind => _t('Tốc độ gió', 'Wind Speed');
  String weatherWindUnit(double speed) => '${speed.round()} km/h';
  String get weatherUvIndex => _t('Chỉ số UV', 'UV Index');
  String get weatherAirQuality => _t('Không khí', 'Air Quality');
  String weatherAqiLabel(int value) => 'AQI $value';
  String get weatherAqiGood => _t('Tốt ✅', 'Good ✅');
  String get weatherAqiModerate => _t('Trung bình', 'Moderate');
  String get weatherAqiUnhealthy => _t('Kém', 'Unhealthy');
  String get weatherHourlyForecast => _t('Dự báo hôm nay', "Today's Forecast");
  String get weatherDailyForecast => _t('7 ngày tới', 'Next 7 Days');
  String get weatherClose => _t('Đóng bảng thời tiết', 'Close weather panel');
  String get weatherToday => _t('Hôm nay', 'Today');
  String get weatherTomorrow => _t('Ngày mai', 'Tomorrow');
  String weatherUpdatedAt(String time) => _t('Cập nhật lúc $time', 'Updated at $time');
  String weatherRainProb(int prob) => _t('$prob% mưa', '$prob% rain');
  String get weatherLocationHue => _t('Thành phố Huế', 'Hue City');
  String get weatherUvLow => _t('Thấp', 'Low');
  String get weatherUvModerate => _t('Trung bình', 'Moderate');
  String get weatherUvHigh => _t('Cao', 'High');
  String get weatherUvVeryHigh => _t('Rất cao', 'Very High');
  String get weatherUvExtreme => _t('Cực cao', 'Extreme');

  // ── AI Travel Advisor ──────────────────────────────────────────────────────
  String get travelAdvisorTitle => _t('Gợi Ý Trợ Lý Du Lịch AI', 'AI Travel Companion Advisory');
  String travelAdvisorRainAdvice(int prob) => _t(
      'Có khả năng mưa rào ($prob%). Hãy mang theo ô/áo mưa và ưu tiên tham quan điểm trong nhà như Bảo tàng Cổ vật.',
      'High chance of rain ($prob%). Carry an umbrella/raincoat and prioritize indoor spots like the Royal Fine Arts Museum.');
  String travelAdvisorSunnyAdvice(double uv) => _t(
      'Nắng gắt (UV ${uv.toStringAsFixed(1)}). Thích hợp tham quan sớm hoặc chiều mát, nhớ trang bị nón lá & bôi kem chống nắng.',
      'Strong sun (UV ${uv.toStringAsFixed(1)}). Best for early morning or late afternoon visits. Wear a conical hat & sunscreen.');
  String get travelAdvisorIdealAdvice => _t(
      'Thời tiết Cố đô tuyệt đẹp! Rất lý tưởng dạo quanh Đại Nội, các Lăng tẩm hoặc đi thuyền Rồng Sông Hương.',
      'Imperial weather is lovely! Ideal for strolling around the Citadel, Royal Tombs, or taking a Dragon Boat trip on Perfume River.');
  String get travelAdvisorCoolAdvice => _t(
      'Thời tiết se lạnh. Rất thích hợp thưởng thức trà sen, chè Huế và đi dạo Cố đô về đêm.',
      'Chilly weather. Perfect for enjoying lotus tea, Hue sweet soup, and evening walks around the Citadel.');
  String get travelAdvisorBringUmbrella => _t('Nên mang ô/dù', 'Bring umbrella');
  String get travelAdvisorSunProtection => _t('Đội nón / Chống nắng', 'Sun protection needed');
  String get travelAdvisorIndoorPriority => _t('Ưu tiên điểm trong nhà', 'Indoor spots recommended');
  String get travelAdvisorOutdoorIdeal => _t('Lý tưởng tham quan ngoài trời', 'Great for outdoor sightseeing');
}

extension AppLocalizationsContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
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
