import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'CodoKy'**
  String get appName;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @itinerary.
  ///
  /// In en, this message translates to:
  /// **'Itinerary'**
  String get itinerary;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @restaurants.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get restaurants;

  /// No description provided for @attractions.
  ///
  /// In en, this message translates to:
  /// **'Attractions'**
  String get attractions;

  /// No description provided for @temples.
  ///
  /// In en, this message translates to:
  /// **'Temples'**
  String get temples;

  /// No description provided for @tombs.
  ///
  /// In en, this message translates to:
  /// **'Tombs'**
  String get tombs;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @createItinerary.
  ///
  /// In en, this message translates to:
  /// **'Create Itinerary'**
  String get createItinerary;

  /// No description provided for @myItineraries.
  ///
  /// In en, this message translates to:
  /// **'My Itineraries'**
  String get myItineraries;

  /// No description provided for @aiSuggestion.
  ///
  /// In en, this message translates to:
  /// **'AI Suggestion'**
  String get aiSuggestion;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write Review'**
  String get writeReview;

  /// No description provided for @myReviews.
  ///
  /// In en, this message translates to:
  /// **'My Reviews'**
  String get myReviews;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeTodo.
  ///
  /// In en, this message translates to:
  /// **'TODO: Home'**
  String get homeTodo;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offlineTitle;

  /// No description provided for @offlineTodo.
  ///
  /// In en, this message translates to:
  /// **'TODO: Offline'**
  String get offlineTodo;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'TOURISM & EXPLORING THE IMPERIAL CITY OF HUE'**
  String get splashTagline;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Smart Map of Imperial Hue 🗺️'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Discover 100+ tombs, the Imperial City, temples & famous salted coffee shops, completely free.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'AI Itinerary Assistant 🤖'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Automatically generates personalized heritage & cuisine itineraries based on your tastes in just 5 seconds.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Experience & VIP Rewards 👑'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Save favorite places, write traveler reviews and level up to enjoy Gold Member perks.'**
  String get onboardingSubtitle3;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get settingsTitle;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'CodoKy User'**
  String get defaultUserName;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @appConfigSection.
  ///
  /// In en, this message translates to:
  /// **'APP CONFIGURATION'**
  String get appConfigSection;

  /// No description provided for @displayLanguage.
  ///
  /// In en, this message translates to:
  /// **'Display Language'**
  String get displayLanguage;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive place suggestions & itinerary reminders'**
  String get notificationsSubtitle;

  /// No description provided for @gpsAccess.
  ///
  /// In en, this message translates to:
  /// **'GPS Access'**
  String get gpsAccess;

  /// No description provided for @gpsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-detect location on the Hue map'**
  String get gpsSubtitle;

  /// No description provided for @darkModeToggle.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeToggle;

  /// No description provided for @infoHelpSection.
  ///
  /// In en, this message translates to:
  /// **'INFO & HELP'**
  String get infoHelpSection;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyMessage.
  ///
  /// In en, this message translates to:
  /// **'The CodoKy app complies with user information privacy policy.'**
  String get privacyPolicyMessage;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// No description provided for @navCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get navCamera;

  /// No description provided for @navItinerary.
  ///
  /// In en, this message translates to:
  /// **'Itinerary'**
  String get navItinerary;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @searchPlacesHint.
  ///
  /// In en, this message translates to:
  /// **'Search places, dishes...'**
  String get searchPlacesHint;

  /// No description provided for @travelWalking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get travelWalking;

  /// No description provided for @travelMotorbike.
  ///
  /// In en, this message translates to:
  /// **'Motorbike'**
  String get travelMotorbike;

  /// No description provided for @travelDriving.
  ///
  /// In en, this message translates to:
  /// **'Driving'**
  String get travelDriving;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'RECENT SEARCHES'**
  String get recentSearches;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @searchCleared.
  ///
  /// In en, this message translates to:
  /// **'Search history cleared.'**
  String get searchCleared;

  /// No description provided for @popularKeywords.
  ///
  /// In en, this message translates to:
  /// **'POPULAR KEYWORDS 🔥'**
  String get popularKeywords;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search places, restaurants, Hue monuments...'**
  String get searchHint;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No places found matching \"\$query\"'**
  String get noResultsFor;

  /// No description provided for @fallbackPlaceName.
  ///
  /// In en, this message translates to:
  /// **'Hue Place'**
  String get fallbackPlaceName;

  /// No description provided for @fallbackAddress.
  ///
  /// In en, this message translates to:
  /// **'Thua Thien Hue'**
  String get fallbackAddress;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Continue with Phone'**
  String get continueWithPhone;

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found: '**
  String get routeNotFound;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categorySites.
  ///
  /// In en, this message translates to:
  /// **'Sites'**
  String get categorySites;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryCafe.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get categoryCafe;

  /// No description provided for @categoryStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get categoryStay;

  /// No description provided for @chipRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get chipRestaurant;

  /// No description provided for @chipAttraction.
  ///
  /// In en, this message translates to:
  /// **'Attraction'**
  String get chipAttraction;

  /// No description provided for @chipTemple.
  ///
  /// In en, this message translates to:
  /// **'Temple'**
  String get chipTemple;

  /// No description provided for @chipTomb.
  ///
  /// In en, this message translates to:
  /// **'Tomb'**
  String get chipTomb;

  /// No description provided for @chipSightseeing.
  ///
  /// In en, this message translates to:
  /// **'Sightseeing'**
  String get chipSightseeing;

  /// No description provided for @exploreHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Imperial Hue 🌸'**
  String get exploreHeroTitle;

  /// No description provided for @exploreHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Heritage, cuisine & the beauty of the Perfume River'**
  String get exploreHeroSubtitle;

  /// No description provided for @exploreSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search places, dishes, Hue tombs...'**
  String get exploreSearchHint;

  /// No description provided for @featuredCategories.
  ///
  /// In en, this message translates to:
  /// **'FEATURED HUE CATEGORIES'**
  String get featuredCategories;

  /// No description provided for @themesCount.
  ///
  /// In en, this message translates to:
  /// **'\$count Themes'**
  String get themesCount;

  /// No description provided for @placeCount.
  ///
  /// In en, this message translates to:
  /// **'\$count places'**
  String get placeCount;

  /// No description provided for @hotPlaces.
  ///
  /// In en, this message translates to:
  /// **'HOT PLACES TO VISIT'**
  String get hotPlaces;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all >'**
  String get seeAll;

  /// No description provided for @experiences.
  ///
  /// In en, this message translates to:
  /// **'SIGNATURE EXPERIENCES OF THE ANCIENT CAPITAL'**
  String get experiences;

  /// No description provided for @experienceTeaTitle.
  ///
  /// In en, this message translates to:
  /// **'Afternoon Tea by the Perfume River'**
  String get experienceTeaTitle;

  /// No description provided for @experienceTeaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Watch the dreamy sunset and listen to Hue royal music'**
  String get experienceTeaSubtitle;

  /// No description provided for @experienceChill.
  ///
  /// In en, this message translates to:
  /// **'Chill Experience'**
  String get experienceChill;

  /// No description provided for @experienceHatTitle.
  ///
  /// In en, this message translates to:
  /// **'Thuy Xuan Conical Hat Making Village'**
  String get experienceHatTitle;

  /// No description provided for @experienceHatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The colorful hat road perfect for check-ins'**
  String get experienceHatSubtitle;

  /// No description provided for @checkinHot.
  ///
  /// In en, this message translates to:
  /// **'Check-in Hot'**
  String get checkinHot;

  /// No description provided for @categoryHeritageTitle.
  ///
  /// In en, this message translates to:
  /// **'Heritage & History'**
  String get categoryHeritageTitle;

  /// No description provided for @categoryHeritageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Imperial City, Tombs & Sites'**
  String get categoryHeritageSubtitle;

  /// No description provided for @categoryFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Ancient Capital Cuisine'**
  String get categoryFoodTitle;

  /// No description provided for @categoryFoodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Beef noodle soup, Baby clam rice & Hue cakes'**
  String get categoryFoodSubtitle;

  /// No description provided for @categorySpiritualTitle.
  ///
  /// In en, this message translates to:
  /// **'Spiritual & Temples'**
  String get categorySpiritualTitle;

  /// No description provided for @categorySpiritualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thien Mu Pagoda, Tu Hieu'**
  String get categorySpiritualSubtitle;

  /// No description provided for @categoryCafeTitle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle & Coffee'**
  String get categoryCafeTitle;

  /// No description provided for @categoryCafeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Salted coffee, Tea house & Street corners'**
  String get categoryCafeSubtitle;

  /// No description provided for @categoryShoppingTitle.
  ///
  /// In en, this message translates to:
  /// **'Night market & Shopping'**
  String get categoryShoppingTitle;

  /// No description provided for @categoryShoppingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dong Ba Market, Walking street'**
  String get categoryShoppingSubtitle;

  /// No description provided for @categoryCultureTitle.
  ///
  /// In en, this message translates to:
  /// **'Art & Experiences'**
  String get categoryCultureTitle;

  /// No description provided for @categoryCultureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hue song on Perfume River, Hat village'**
  String get categoryCultureSubtitle;

  /// No description provided for @categoryFoodHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Ancient Capital Hue Cuisine 🍜'**
  String get categoryFoodHeaderTitle;

  /// No description provided for @categoryFoodHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Specialties: Beef noodle soup, Baby clam rice & traditional Hue cakes'**
  String get categoryFoodHeaderSubtitle;

  /// No description provided for @categoryTempleHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Spiritual & Hue Temples ⛩️'**
  String get categoryTempleHeaderTitle;

  /// No description provided for @categoryTempleHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore ancient peaceful sacred pagodas'**
  String get categoryTempleHeaderSubtitle;

  /// No description provided for @categoryTombHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Nguyen Dynasty Tombs 🏛️'**
  String get categoryTombHeaderTitle;

  /// No description provided for @categoryTombHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Khai Dinh, Tu Duc, Minh Mang & Historical sites'**
  String get categoryTombHeaderSubtitle;

  /// No description provided for @categoryCafeHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle & Hue Coffee ☕'**
  String get categoryCafeHeaderTitle;

  /// No description provided for @categoryCafeHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoy salted coffee & dreamy tea houses'**
  String get categoryCafeHeaderSubtitle;

  /// No description provided for @categoryShoppingHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Night market & Shopping 🛍️'**
  String get categoryShoppingHeaderTitle;

  /// No description provided for @categoryShoppingHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dong Ba Market & lively walking street'**
  String get categoryShoppingHeaderSubtitle;

  /// No description provided for @categoryCultureHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Art & Experiences 🎶'**
  String get categoryCultureHeaderTitle;

  /// No description provided for @categoryCultureHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hue song on Perfume River & traditional crafts villages'**
  String get categoryCultureHeaderSubtitle;

  /// No description provided for @categoryDefaultHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Heritage & Hue History 🏰'**
  String get categoryDefaultHeaderTitle;

  /// No description provided for @categoryDefaultHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Imperial City, Nguyen dynasty tombs & sites'**
  String get categoryDefaultHeaderSubtitle;

  /// No description provided for @categorySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search within this category...'**
  String get categorySearchHint;

  /// No description provided for @placesFound.
  ///
  /// In en, this message translates to:
  /// **'\$count places found'**
  String get placesFound;

  /// No description provided for @topRated.
  ///
  /// In en, this message translates to:
  /// **'Top Rated ★'**
  String get topRated;

  /// No description provided for @noPlacesFound.
  ///
  /// In en, this message translates to:
  /// **'No matching places found.'**
  String get noPlacesFound;

  /// No description provided for @fallbackTicketLabel.
  ///
  /// In en, this message translates to:
  /// **'Visit heritage site'**
  String get fallbackTicketLabel;

  /// No description provided for @fallbackTag.
  ///
  /// In en, this message translates to:
  /// **'📍 Hue destination'**
  String get fallbackTag;

  /// No description provided for @appleAndroidWarning.
  ///
  /// In en, this message translates to:
  /// **'Apple login on Android requires configuring a Service ID on the Apple Developer Portal.'**
  String get appleAndroidWarning;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to CodoKy'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Heritage • Culture • Hue Cuisine'**
  String get welcomeSubtitle;

  /// No description provided for @termsPrefix.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to CodoKy\'s '**
  String get termsPrefix;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsAnd.
  ///
  /// In en, this message translates to:
  /// **' & '**
  String get termsAnd;

  /// No description provided for @termsSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get termsSuffix;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the email registered with your CodoKy account to receive a password recovery link.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @emailRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered email'**
  String get emailRegistered;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get emailHint;

  /// No description provided for @sendResetRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Recovery Request'**
  String get sendResetRequest;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password recovery email sent. Please check your inbox!'**
  String get resetEmailSent;

  /// No description provided for @registerAppBar.
  ///
  /// In en, this message translates to:
  /// **'Register Account'**
  String get registerAppBar;

  /// No description provided for @createNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createNewAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your Hue discovery journey with CodoKy'**
  String get registerSubtitle;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameHint;

  /// No description provided for @emailAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get emailAddressHint;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number (e.g. 0912345678)'**
  String get phoneHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password (minimum 8 characters)'**
  String get passwordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @orRegisterWith.
  ///
  /// In en, this message translates to:
  /// **'Or register with'**
  String get orRegisterWith;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get loginNow;

  /// No description provided for @onboardingCatFoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Hue Cuisine'**
  String get onboardingCatFoodLabel;

  /// No description provided for @onboardingCatFoodDesc.
  ///
  /// In en, this message translates to:
  /// **'Baby clam rice, Beef noodle soup, Hue cakes, Royal tea'**
  String get onboardingCatFoodDesc;

  /// No description provided for @onboardingCatHistoryLabel.
  ///
  /// In en, this message translates to:
  /// **'History & Heritage'**
  String get onboardingCatHistoryLabel;

  /// No description provided for @onboardingCatHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Imperial City, Tombs of Nguyen kings'**
  String get onboardingCatHistoryDesc;

  /// No description provided for @onboardingCatSpiritualLabel.
  ///
  /// In en, this message translates to:
  /// **'Spiritual & Temples'**
  String get onboardingCatSpiritualLabel;

  /// No description provided for @onboardingCatSpiritualDesc.
  ///
  /// In en, this message translates to:
  /// **'Thien Mu Pagoda, Tu Dam Pagoda, Zen monasteries'**
  String get onboardingCatSpiritualDesc;

  /// No description provided for @onboardingCatNatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Nature & Scenery'**
  String get onboardingCatNatureLabel;

  /// No description provided for @onboardingCatNatureDesc.
  ///
  /// In en, this message translates to:
  /// **'Perfume River, Ngu Binh Mountain, Vong Canh Hill'**
  String get onboardingCatNatureDesc;

  /// No description provided for @onboardingCatCafeLabel.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle & Coffee'**
  String get onboardingCatCafeLabel;

  /// No description provided for @onboardingCatCafeDesc.
  ///
  /// In en, this message translates to:
  /// **'Street corner cafes, Hue afternoon tea'**
  String get onboardingCatCafeDesc;

  /// No description provided for @onboardingCatShoppingLabel.
  ///
  /// In en, this message translates to:
  /// **'Shopping & Night Market'**
  String get onboardingCatShoppingLabel;

  /// No description provided for @onboardingCatShoppingDesc.
  ///
  /// In en, this message translates to:
  /// **'Dong Ba Market, Nguyen Dinh Chieu walking street'**
  String get onboardingCatShoppingDesc;

  /// No description provided for @onboardingCatArtLabel.
  ///
  /// In en, this message translates to:
  /// **'Art & Royal Music'**
  String get onboardingCatArtLabel;

  /// No description provided for @onboardingCatArtDesc.
  ///
  /// In en, this message translates to:
  /// **'Hue song on the Perfume River, Traditional crafts villages'**
  String get onboardingCatArtDesc;

  /// No description provided for @selectAtLeastOnePreference.
  ///
  /// In en, this message translates to:
  /// **'Please select at least 1 preference so the AI can suggest the best itinerary for you!'**
  String get selectAtLeastOnePreference;

  /// No description provided for @cantSavePreferences.
  ///
  /// In en, this message translates to:
  /// **'Could not save preferences.'**
  String get cantSavePreferences;

  /// No description provided for @travelPreferences.
  ///
  /// In en, this message translates to:
  /// **'Travel Preferences'**
  String get travelPreferences;

  /// No description provided for @whichExperience.
  ///
  /// In en, this message translates to:
  /// **'Which experiences do you love in Hue?'**
  String get whichExperience;

  /// No description provided for @preferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the topics you care about so CodoKy AI can personalize your itinerary.'**
  String get preferencesSubtitle;

  /// No description provided for @saveAndExplore.
  ///
  /// In en, this message translates to:
  /// **'Save & Explore Now (\$count)'**
  String get saveAndExplore;

  /// No description provided for @updateProfileSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile and preferences updated successfully!'**
  String get updateProfileSuccess;

  /// No description provided for @updateProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'Profile update failed.'**
  String get updateProfileFailed;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @fullNameNewHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your new full name'**
  String get fullNameNewHint;

  /// No description provided for @phoneNewHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your new phone number'**
  String get phoneNewHint;

  /// No description provided for @avatarUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Avatar URL'**
  String get avatarUrlLabel;

  /// No description provided for @avatarUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://example.com/avatar.jpg'**
  String get avatarUrlHint;

  /// No description provided for @personalInterests.
  ///
  /// In en, this message translates to:
  /// **'Personal Travel Interests'**
  String get personalInterests;

  /// No description provided for @interestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select topics so AI can suggest accurate itineraries:'**
  String get interestsSubtitle;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Profile'**
  String get profileTitle;

  /// No description provided for @guestWelcome.
  ///
  /// In en, this message translates to:
  /// **'Guest Visitor'**
  String get guestWelcome;

  /// No description provided for @guestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to save itineraries & earn rewards'**
  String get guestSubtitle;

  /// No description provided for @guestFeature1.
  ///
  /// In en, this message translates to:
  /// **'Save your favorite places and restaurants in Hue'**
  String get guestFeature1;

  /// No description provided for @guestFeature2.
  ///
  /// In en, this message translates to:
  /// **'Build itineraries with automatic AI tools'**
  String get guestFeature2;

  /// No description provided for @guestFeature3.
  ///
  /// In en, this message translates to:
  /// **'Earn member points, get exclusive perks'**
  String get guestFeature3;

  /// No description provided for @loginRegister.
  ///
  /// In en, this message translates to:
  /// **'Login / Register'**
  String get loginRegister;

  /// No description provided for @noEmailYet.
  ///
  /// In en, this message translates to:
  /// **'Email not yet updated'**
  String get noEmailYet;

  /// No description provided for @goldMember.
  ///
  /// In en, this message translates to:
  /// **'Gold Member'**
  String get goldMember;

  /// No description provided for @regularMember.
  ///
  /// In en, this message translates to:
  /// **'Regular Member'**
  String get regularMember;

  /// No description provided for @statItinerary.
  ///
  /// In en, this message translates to:
  /// **'Itineraries'**
  String get statItinerary;

  /// No description provided for @statSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get statSaved;

  /// No description provided for @statReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get statReviews;

  /// No description provided for @statOfMine.
  ///
  /// In en, this message translates to:
  /// **'Mine'**
  String get statOfMine;

  /// No description provided for @statPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get statPoints;

  /// No description provided for @journeyData.
  ///
  /// In en, this message translates to:
  /// **'JOURNEY & DATA'**
  String get journeyData;

  /// No description provided for @mySavedTripsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your stored trips'**
  String get mySavedTripsSubtitle;

  /// No description provided for @myReviewsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Place comments & reviews'**
  String get myReviewsSubtitle;

  /// No description provided for @savedPlaces.
  ///
  /// In en, this message translates to:
  /// **'Saved Places'**
  String get savedPlaces;

  /// No description provided for @savedPlacesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review your favorite check-in spots'**
  String get savedPlacesSubtitle;

  /// No description provided for @personalInfoHeader.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL INFORMATION'**
  String get personalInfoHeader;

  /// No description provided for @notUpdated.
  ///
  /// In en, this message translates to:
  /// **'Not updated'**
  String get notUpdated;

  /// No description provided for @joinedDate.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joinedDate;

  /// No description provided for @appearanceSettings.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE & SETTINGS'**
  String get appearanceSettings;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'System 📱'**
  String get systemMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode ☀️'**
  String get lightMode;

  /// No description provided for @darkModeTheme.
  ///
  /// In en, this message translates to:
  /// **'Imperial Night (Dark Mode) 🌙'**
  String get darkModeTheme;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out of account?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of the CodoKy app?'**
  String get logoutConfirmMessage;

  /// No description provided for @themeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get themeSheetTitle;

  /// No description provided for @themeLightTitle.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get themeLightTitle;

  /// No description provided for @themeLightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Elegant terracotta cream background'**
  String get themeLightSubtitle;

  /// No description provided for @themeDarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode (Imperial Night)'**
  String get themeDarkTitle;

  /// No description provided for @themeDarkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Easy on the eyes at night'**
  String get themeDarkSubtitle;

  /// No description provided for @themeSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow system settings'**
  String get themeSystemTitle;

  /// No description provided for @themeSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-sync with your device'**
  String get themeSystemSubtitle;

  /// No description provided for @cameraTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to load a heritage photo for AI scan'**
  String get cameraTapHint;

  /// No description provided for @cameraDevHint.
  ///
  /// In en, this message translates to:
  /// **'(Dev Windows mode / Library)'**
  String get cameraDevHint;

  /// No description provided for @cameraAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'AI Gemini is analyzing the heritage...'**
  String get cameraAnalyzing;

  /// No description provided for @cameraSaved.
  ///
  /// In en, this message translates to:
  /// **'✨ Saved to your Hue journey collection!'**
  String get cameraSaved;

  /// No description provided for @cameraShared.
  ///
  /// In en, this message translates to:
  /// **'Shared post \$name!'**
  String get cameraShared;

  /// No description provided for @heritageHue.
  ///
  /// In en, this message translates to:
  /// **'Hue heritage'**
  String get heritageHue;

  /// No description provided for @cameraNoPhoto.
  ///
  /// In en, this message translates to:
  /// **'Please take a photo to run the AI scan'**
  String get cameraNoPhoto;

  /// No description provided for @cameraCaptureError.
  ///
  /// In en, this message translates to:
  /// **'Could not capture photo: \$error'**
  String get cameraCaptureError;

  /// No description provided for @cameraLandmarkFoodName.
  ///
  /// In en, this message translates to:
  /// **'Imperial Signature Hue Beef Noodle Soup'**
  String get cameraLandmarkFoodName;

  /// No description provided for @cameraLandmarkFoodDesc.
  ///
  /// In en, this message translates to:
  /// **'The iconic ancient capital dish with rich lemongrass-chili broth, fresh fired pork loaf and signature thick noodles.'**
  String get cameraLandmarkFoodDesc;

  /// No description provided for @cameraLandmarkAoDaiName.
  ///
  /// In en, this message translates to:
  /// **'Nguyen Dynasty Nhat Binh Ao Dai'**
  String get cameraLandmarkAoDaiName;

  /// No description provided for @cameraLandmarkAoDaiDesc.
  ///
  /// In en, this message translates to:
  /// **'Hue court attire for Empresses and Princesses with exquisite hand-embroidered patterns.'**
  String get cameraLandmarkAoDaiDesc;

  /// No description provided for @cameraLandmarkCitadelName.
  ///
  /// In en, this message translates to:
  /// **'Imperial City of Hue (Hue Citadel)'**
  String get cameraLandmarkCitadelName;

  /// No description provided for @cameraLandmarkCitadelDesc.
  ///
  /// In en, this message translates to:
  /// **'The Nguyen dynasty imperial capital built in 1804, a UNESCO World Cultural Heritage Site since 1993.'**
  String get cameraLandmarkCitadelDesc;

  /// No description provided for @duration1d.
  ///
  /// In en, this message translates to:
  /// **'1 Day (Quick)'**
  String get duration1d;

  /// No description provided for @duration2d.
  ///
  /// In en, this message translates to:
  /// **'2 Days 1 Night'**
  String get duration2d;

  /// No description provided for @duration3d.
  ///
  /// In en, this message translates to:
  /// **'3 Days 2 Nights (Recommended)'**
  String get duration3d;

  /// No description provided for @duration4d.
  ///
  /// In en, this message translates to:
  /// **'4 Days 3 Nights (Complete)'**
  String get duration4d;

  /// No description provided for @companionSolo.
  ///
  /// In en, this message translates to:
  /// **'Solo 🎒'**
  String get companionSolo;

  /// No description provided for @companionCouple.
  ///
  /// In en, this message translates to:
  /// **'Couple 👩‍❤️‍👨'**
  String get companionCouple;

  /// No description provided for @companionFamily.
  ///
  /// In en, this message translates to:
  /// **'Family 👨‍👩‍👧‍👦'**
  String get companionFamily;

  /// No description provided for @companionFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends 🚗'**
  String get companionFriends;

  /// No description provided for @styleHeritage.
  ///
  /// In en, this message translates to:
  /// **'🏰 Heritage & History'**
  String get styleHeritage;

  /// No description provided for @styleFood.
  ///
  /// In en, this message translates to:
  /// **'🍜 Ancient Capital Cuisine'**
  String get styleFood;

  /// No description provided for @styleChill.
  ///
  /// In en, this message translates to:
  /// **'☕ Chill & Salted coffee'**
  String get styleChill;

  /// No description provided for @styleSpiritual.
  ///
  /// In en, this message translates to:
  /// **'⛩️ Spiritual & Ancient temples'**
  String get styleSpiritual;

  /// No description provided for @styleCheckin.
  ///
  /// In en, this message translates to:
  /// **'📸 Photo check-in'**
  String get styleCheckin;

  /// No description provided for @styleNature.
  ///
  /// In en, this message translates to:
  /// **'🌿 Perfume River & Nature'**
  String get styleNature;

  /// No description provided for @budgetSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving 💡'**
  String get budgetSaving;

  /// No description provided for @budgetSavingDesc.
  ///
  /// In en, this message translates to:
  /// **'~ 300k - 500k/day'**
  String get budgetSavingDesc;

  /// No description provided for @budgetStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard ⭐'**
  String get budgetStandard;

  /// No description provided for @budgetStandardDesc.
  ///
  /// In en, this message translates to:
  /// **'~ 600k - 1M/day'**
  String get budgetStandardDesc;

  /// No description provided for @budgetVip.
  ///
  /// In en, this message translates to:
  /// **'VIP Comfort 💎'**
  String get budgetVip;

  /// No description provided for @budgetVipDesc.
  ///
  /// In en, this message translates to:
  /// **'> 1.2M/day'**
  String get budgetVipDesc;

  /// No description provided for @quotaWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Warning: AI generation quota is almost exhausted (\$quota/1000)'**
  String get quotaWarning;

  /// No description provided for @aiSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Itinerary Setup'**
  String get aiSetupTitle;

  /// No description provided for @heroTitle.
  ///
  /// In en, this message translates to:
  /// **'CodoKy AI Travel Planner'**
  String get heroTitle;

  /// No description provided for @heroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'In just 5 seconds AI designs your perfect Hue trip based on your time, budget and preferences.'**
  String get heroSubtitle;

  /// No description provided for @sectionDuration.
  ///
  /// In en, this message translates to:
  /// **'1. HOW LONG WILL YOU STAY IN HUE?'**
  String get sectionDuration;

  /// No description provided for @sectionCompanion.
  ///
  /// In en, this message translates to:
  /// **'2. WHO ARE YOU TRAVELING WITH?'**
  String get sectionCompanion;

  /// No description provided for @sectionStyle.
  ///
  /// In en, this message translates to:
  /// **'3. FAVORITE TRAVEL STYLE (MULTIPLE)'**
  String get sectionStyle;

  /// No description provided for @sectionBudget.
  ///
  /// In en, this message translates to:
  /// **'4. PLANNED SPENDING BUDGET'**
  String get sectionBudget;

  /// No description provided for @aiGenerating.
  ///
  /// In en, this message translates to:
  /// **'AI is building your itinerary...'**
  String get aiGenerating;

  /// No description provided for @createAiItinerary.
  ///
  /// In en, this message translates to:
  /// **'Generate AI Itinerary'**
  String get createAiItinerary;

  /// No description provided for @aiItineraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Hue AI Itinerary'**
  String get aiItineraryTitle;

  /// No description provided for @noItineraryYet.
  ///
  /// In en, this message translates to:
  /// **'No AI itinerary has been created yet.'**
  String get noItineraryYet;

  /// No description provided for @noItineraryDesc.
  ///
  /// In en, this message translates to:
  /// **'Set up your travel needs so AI can suggest the optimal itinerary.'**
  String get noItineraryDesc;

  /// No description provided for @createItineraryNow.
  ///
  /// In en, this message translates to:
  /// **'Create Itinerary Now ✨'**
  String get createItineraryNow;

  /// No description provided for @savedToYourList.
  ///
  /// In en, this message translates to:
  /// **'Itinerary saved to your list!'**
  String get savedToYourList;

  /// No description provided for @unsavedFromList.
  ///
  /// In en, this message translates to:
  /// **'Itinerary removed from your list.'**
  String get unsavedFromList;

  /// No description provided for @geminiBadge.
  ///
  /// In en, this message translates to:
  /// **'🌸 Gemini AI Itinerary'**
  String get geminiBadge;

  /// No description provided for @durationDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'\$count Days'**
  String get durationDaysLabel;

  /// No description provided for @stopsCount.
  ///
  /// In en, this message translates to:
  /// **'\$count Stops'**
  String get stopsCount;

  /// No description provided for @budgetLabel.
  ///
  /// In en, this message translates to:
  /// **'\${value}k VND'**
  String budgetLabel(Object value);

  /// No description provided for @dayTab.
  ///
  /// In en, this message translates to:
  /// **'Day \$day'**
  String get dayTab;

  /// No description provided for @cantEditCompleted.
  ///
  /// In en, this message translates to:
  /// **'Cannot edit a completed itinerary.'**
  String get cantEditCompleted;

  /// No description provided for @lateWarning.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Warning: Itinerary exceeds 22:00 due to changes.'**
  String get lateWarning;

  /// No description provided for @errorWith.
  ///
  /// In en, this message translates to:
  /// **'Error: \$message'**
  String get errorWith;

  /// No description provided for @noActivitiesForDay.
  ///
  /// In en, this message translates to:
  /// **'No activities for this day.'**
  String get noActivitiesForDay;

  /// No description provided for @addPlaceToItinerary.
  ///
  /// In en, this message translates to:
  /// **'Add a destination to the itinerary'**
  String get addPlaceToItinerary;

  /// No description provided for @invalidPlaceData.
  ///
  /// In en, this message translates to:
  /// **'Invalid place data, please try again'**
  String get invalidPlaceData;

  /// No description provided for @lateWarningAdd.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Warning: Itinerary exceeds 22:00 due to adding a new place.'**
  String get lateWarningAdd;

  /// No description provided for @cantAddPlace.
  ///
  /// In en, this message translates to:
  /// **'Could not add place: \$message'**
  String get cantAddPlace;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"\$name\" from this day\'s itinerary?'**
  String get deleteConfirmMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cantDeleteActivity.
  ///
  /// In en, this message translates to:
  /// **'Could not delete activity: \$message'**
  String get cantDeleteActivity;

  /// No description provided for @categoryFoodShort.
  ///
  /// In en, this message translates to:
  /// **'🍜 Food'**
  String get categoryFoodShort;

  /// No description provided for @categorySpiritualShort.
  ///
  /// In en, this message translates to:
  /// **'⛩️ Spiritual'**
  String get categorySpiritualShort;

  /// No description provided for @categoryHeritageShort.
  ///
  /// In en, this message translates to:
  /// **'🏰 Heritage'**
  String get categoryHeritageShort;

  /// No description provided for @hueLandmark.
  ///
  /// In en, this message translates to:
  /// **'Hue Sightseeing Spot'**
  String get hueLandmark;

  /// No description provided for @notesPrefix.
  ///
  /// In en, this message translates to:
  /// **'💡 '**
  String get notesPrefix;

  /// No description provided for @savedTripsTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Itineraries'**
  String get savedTripsTitle;

  /// No description provided for @savedTripsCount.
  ///
  /// In en, this message translates to:
  /// **'\$count SAVED TRIPS'**
  String get savedTripsCount;

  /// No description provided for @createNewAi.
  ///
  /// In en, this message translates to:
  /// **'New AI'**
  String get createNewAi;

  /// No description provided for @noSavedTrips.
  ///
  /// In en, this message translates to:
  /// **'No saved travel itineraries yet.'**
  String get noSavedTrips;

  /// No description provided for @tripStatusOngoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get tripStatusOngoing;

  /// No description provided for @tripStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get tripStatusCompleted;

  /// No description provided for @tripStatusSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get tripStatusSaved;

  /// No description provided for @interestFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get interestFood;

  /// No description provided for @interestCulture.
  ///
  /// In en, this message translates to:
  /// **'Culture - History'**
  String get interestCulture;

  /// No description provided for @interestSpiritual.
  ///
  /// In en, this message translates to:
  /// **'Zen - Spiritual'**
  String get interestSpiritual;

  /// No description provided for @interestRelax.
  ///
  /// In en, this message translates to:
  /// **'Relaxation'**
  String get interestRelax;

  /// No description provided for @interestCheckin.
  ///
  /// In en, this message translates to:
  /// **'Photo check-in'**
  String get interestCheckin;

  /// No description provided for @interestAdventure.
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get interestAdventure;

  /// No description provided for @aiCreateItinerary.
  ///
  /// In en, this message translates to:
  /// **'AI Create Itinerary'**
  String get aiCreateItinerary;

  /// No description provided for @aiDialogDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter info so AI can suggest the most suitable itinerary for you'**
  String get aiDialogDesc;

  /// No description provided for @daysLabel.
  ///
  /// In en, this message translates to:
  /// **'Days:'**
  String get daysLabel;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'\$count days'**
  String get daysCount;

  /// No description provided for @budgetLabelText.
  ///
  /// In en, this message translates to:
  /// **'Estimated budget:'**
  String get budgetLabelText;

  /// No description provided for @vnd.
  ///
  /// In en, this message translates to:
  /// **'VND'**
  String get vnd;

  /// No description provided for @budgetHint.
  ///
  /// In en, this message translates to:
  /// **'Enter budget'**
  String get budgetHint;

  /// No description provided for @interestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Interests:'**
  String get interestsLabel;

  /// No description provided for @aiCreating.
  ///
  /// In en, this message translates to:
  /// **'AI is creating your itinerary...'**
  String get aiCreating;

  /// No description provided for @aiBadge.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get aiBadge;

  /// No description provided for @durationDays.
  ///
  /// In en, this message translates to:
  /// **'\$count days'**
  String get durationDays;

  /// No description provided for @reviewCountLabel.
  ///
  /// In en, this message translates to:
  /// **'\$count reviews'**
  String get reviewCountLabel;

  /// No description provided for @pickPlaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a Hue destination ✨'**
  String get pickPlaceTitle;

  /// No description provided for @searchPlaceHint.
  ///
  /// In en, this message translates to:
  /// **'Search places, heritage, restaurants...'**
  String get searchPlaceHint;

  /// No description provided for @noPlacesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No places found'**
  String get noPlacesEmpty;

  /// No description provided for @placeLabel.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get placeLabel;

  /// No description provided for @addLabel.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get addLabel;

  /// No description provided for @stopDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop Details'**
  String get stopDetailTitle;

  /// No description provided for @recommendedTime.
  ///
  /// In en, this message translates to:
  /// **'⏱️ Recommended time: \$hours Hours'**
  String get recommendedTime;

  /// No description provided for @aiTipsHeader.
  ///
  /// In en, this message translates to:
  /// **'AI ASSISTANT TIPS'**
  String get aiTipsHeader;

  /// No description provided for @startGpsNavigation.
  ///
  /// In en, this message translates to:
  /// **'Start GPS Navigation'**
  String get startGpsNavigation;

  /// No description provided for @ttsApproach.
  ///
  /// In en, this message translates to:
  /// **'In \$meters meters, \$instruction'**
  String get ttsApproach;

  /// No description provided for @ttsRecalculating.
  ///
  /// In en, this message translates to:
  /// **'Recalculating the new route'**
  String get ttsRecalculating;

  /// No description provided for @recalculatingSnackbar.
  ///
  /// In en, this message translates to:
  /// **'🔄 Automatically recalculating a new route...'**
  String get recalculatingSnackbar;

  /// No description provided for @ttsArrived.
  ///
  /// In en, this message translates to:
  /// **'You have arrived at your destination! Have a wonderful experience in the Imperial City of Hue.'**
  String get ttsArrived;

  /// No description provided for @arrivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Arrived at Destination!'**
  String get arrivedTitle;

  /// No description provided for @arrivedMessage.
  ///
  /// In en, this message translates to:
  /// **'🎉 You have arrived safely. Enjoy your exploration of the Imperial City of Hue!'**
  String get arrivedMessage;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @etaLabel.
  ///
  /// In en, this message translates to:
  /// **'Arriving at \$eta'**
  String get etaLabel;

  /// No description provided for @routeCancelled.
  ///
  /// In en, this message translates to:
  /// **'Navigation route cancelled'**
  String get routeCancelled;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'\${value} km'**
  String distanceKm(Object value);

  /// No description provided for @distanceM.
  ///
  /// In en, this message translates to:
  /// **'\${value} m'**
  String distanceM(Object value);

  /// No description provided for @remainingDistance.
  ///
  /// In en, this message translates to:
  /// **'\$distText remaining'**
  String get remainingDistance;

  /// No description provided for @voiceOn.
  ///
  /// In en, this message translates to:
  /// **'Enable voice'**
  String get voiceOn;

  /// No description provided for @voiceOff.
  ///
  /// In en, this message translates to:
  /// **'Disable voice'**
  String get voiceOff;

  /// No description provided for @mapSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search places...'**
  String get mapSearchHint;

  /// No description provided for @filterLabel.
  ///
  /// In en, this message translates to:
  /// **'Filter (\$count)'**
  String get filterLabel;

  /// No description provided for @filterLabelNoCount.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterLabelNoCount;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @savedCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved (\$count)'**
  String get savedCountLabel;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @restaurant.
  ///
  /// In en, this message translates to:
  /// **'Restaurant'**
  String get restaurant;

  /// No description provided for @place.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get place;

  /// No description provided for @tomb.
  ///
  /// In en, this message translates to:
  /// **'Tomb'**
  String get tomb;

  /// No description provided for @temple.
  ///
  /// In en, this message translates to:
  /// **'Temple'**
  String get temple;

  /// No description provided for @mapStyleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change map style'**
  String get mapStyleTooltip;

  /// No description provided for @recenterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Re-center location'**
  String get recenterTooltip;

  /// No description provided for @myLocationTooltip.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get myLocationTooltip;

  /// No description provided for @iconStyleTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize Icon Style'**
  String get iconStyleTitle;

  /// No description provided for @iconStyleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a modern & youthful icon style'**
  String get iconStyleSubtitle;

  /// No description provided for @styleGlowTitle.
  ///
  /// In en, this message translates to:
  /// **'Gradient Vibrant Glow'**
  String get styleGlowTitle;

  /// No description provided for @styleGlowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vibrant shadowing colors, energetic & eye-catching'**
  String get styleGlowSubtitle;

  /// No description provided for @styleDuotoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Glassmorphic Duotone'**
  String get styleDuotoneTitle;

  /// No description provided for @styleDuotoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Refined 2-tone translucent, luxurious'**
  String get styleDuotoneSubtitle;

  /// No description provided for @style3dTitle.
  ///
  /// In en, this message translates to:
  /// **'3D Playful Pop'**
  String get style3dTitle;

  /// No description provided for @style3dSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Rounded 3D blocks full of youthful energy'**
  String get style3dSubtitle;

  /// No description provided for @savedCategory.
  ///
  /// In en, this message translates to:
  /// **'Saved Places'**
  String get savedCategory;

  /// No description provided for @attractionCategory.
  ///
  /// In en, this message translates to:
  /// **'Places & Sites'**
  String get attractionCategory;

  /// No description provided for @restaurantCategory.
  ///
  /// In en, this message translates to:
  /// **'Restaurants & Food'**
  String get restaurantCategory;

  /// No description provided for @templeCategory.
  ///
  /// In en, this message translates to:
  /// **'Temples & Spiritual'**
  String get templeCategory;

  /// No description provided for @tombCategory.
  ///
  /// In en, this message translates to:
  /// **'Nguyen Tombs'**
  String get tombCategory;

  /// No description provided for @cafeCategory.
  ///
  /// In en, this message translates to:
  /// **'Hue Coffee & Tea'**
  String get cafeCategory;

  /// No description provided for @shoppingCategory.
  ///
  /// In en, this message translates to:
  /// **'Markets & Shopping'**
  String get shoppingCategory;

  /// No description provided for @cultureCategory.
  ///
  /// In en, this message translates to:
  /// **'Art & Culture'**
  String get cultureCategory;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Category Filter'**
  String get filterTitle;

  /// No description provided for @filterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select one or more categories to filter markers on the map:'**
  String get filterSubtitle;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @fallbackPlaceName2.
  ///
  /// In en, this message translates to:
  /// **'Hue Tourist Place'**
  String get fallbackPlaceName2;

  /// No description provided for @fallbackAddress2.
  ///
  /// In en, this message translates to:
  /// **'Hue City, Thua Thien Hue'**
  String get fallbackAddress2;

  /// No description provided for @fallbackHours.
  ///
  /// In en, this message translates to:
  /// **'07:30 - 17:30 (Mon - Sun)'**
  String get fallbackHours;

  /// No description provided for @fallbackTicket.
  ///
  /// In en, this message translates to:
  /// **'Free / Or heritage site ticket'**
  String get fallbackTicket;

  /// No description provided for @fallbackDescription.
  ///
  /// In en, this message translates to:
  /// **'A top heritage complex and destination in the Imperial City of Hue. It preserves the distinctive cultural beauty and historic architecture of the Nguyen dynasty along with the poetic space beside the Perfume River.'**
  String get fallbackDescription;

  /// No description provided for @fallbackTag1.
  ///
  /// In en, this message translates to:
  /// **'🏰 Hue Heritage'**
  String get fallbackTag1;

  /// No description provided for @fallbackTag2.
  ///
  /// In en, this message translates to:
  /// **'📸 Great check-in'**
  String get fallbackTag2;

  /// No description provided for @fallbackTag3.
  ///
  /// In en, this message translates to:
  /// **'🏛️ Ancient Capital Architecture'**
  String get fallbackTag3;

  /// No description provided for @fallbackTag4.
  ///
  /// In en, this message translates to:
  /// **'🌿 Poetic scenery'**
  String get fallbackTag4;

  /// No description provided for @mockPlaceName.
  ///
  /// In en, this message translates to:
  /// **'Imperial City of Hue (Hue Citadel)'**
  String get mockPlaceName;

  /// No description provided for @mockAddress.
  ///
  /// In en, this message translates to:
  /// **'23/8 Street, Thuan Hoa Ward, Hue City'**
  String get mockAddress;

  /// No description provided for @mockHours.
  ///
  /// In en, this message translates to:
  /// **'07:00 - 17:30 (Mon - Sun)'**
  String get mockHours;

  /// No description provided for @mockTicket.
  ///
  /// In en, this message translates to:
  /// **'200,000 VND / Adult • 40,000 VND / Child'**
  String get mockTicket;

  /// No description provided for @mockDescription.
  ///
  /// In en, this message translates to:
  /// **'The Imperial City of Hue is the largest architectural monument complex in Vietnam, recognized by UNESCO as a World Cultural Heritage Site in 1993. It served as the political, cultural and religious center of the Nguyen dynasty for 143 years. Visitors can admire the Ngo Mon Gate, Thai Hoa Palace, the Forbidden City and many other unique imperial structures.'**
  String get mockDescription;

  /// No description provided for @mockTag1.
  ///
  /// In en, this message translates to:
  /// **'🏰 UNESCO Heritage'**
  String get mockTag1;

  /// No description provided for @mockTag2.
  ///
  /// In en, this message translates to:
  /// **'👑 Imperial City'**
  String get mockTag2;

  /// No description provided for @mockTag3.
  ///
  /// In en, this message translates to:
  /// **'📸 Check-in Hue'**
  String get mockTag3;

  /// No description provided for @mockTag4.
  ///
  /// In en, this message translates to:
  /// **'🏛️ Nguyen Dynasty'**
  String get mockTag4;

  /// No description provided for @cantOpenMap.
  ///
  /// In en, this message translates to:
  /// **'Could not open the navigation map.'**
  String get cantOpenMap;

  /// No description provided for @reviewCountFromTravelers.
  ///
  /// In en, this message translates to:
  /// **'(\$count Traveler Reviews)'**
  String get reviewCountFromTravelers;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @saveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLabel;

  /// No description provided for @savedLabel.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedLabel;

  /// No description provided for @savedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Place saved to your favorites!'**
  String get savedToFavorites;

  /// No description provided for @removedFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Removed from your saved list.'**
  String get removedFromSaved;

  /// No description provided for @addToItinerary.
  ///
  /// In en, this message translates to:
  /// **'+ Itinerary'**
  String get addToItinerary;

  /// No description provided for @cantModifyCompletedItinerary.
  ///
  /// In en, this message translates to:
  /// **'Cannot modify a completed itinerary.'**
  String get cantModifyCompletedItinerary;

  /// No description provided for @itinerarySavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Itinerary saved to your list!'**
  String get itinerarySavedSnackbar;

  /// No description provided for @itineraryUnsavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Itinerary removed from your list.'**
  String get itineraryUnsavedSnackbar;

  /// No description provided for @aiSuggestionDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter details so AI can suggest the best itinerary for you'**
  String get aiSuggestionDialogSubtitle;

  /// No description provided for @selectPlaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Hue Destination 🗺️'**
  String get selectPlaceTitle;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'+ Add'**
  String get addButton;

  /// No description provided for @openingHours.
  ///
  /// In en, this message translates to:
  /// **'Opening Hours'**
  String get openingHours;

  /// No description provided for @openNow.
  ///
  /// In en, this message translates to:
  /// **'OPEN NOW'**
  String get openNow;

  /// No description provided for @ticketPrice.
  ///
  /// In en, this message translates to:
  /// **'Ticket Price / Cost'**
  String get ticketPrice;

  /// No description provided for @introHistory.
  ///
  /// In en, this message translates to:
  /// **'INTRODUCTION & HISTORY'**
  String get introHistory;

  /// No description provided for @locationOnMap.
  ///
  /// In en, this message translates to:
  /// **'LOCATION ON THE HUE MAP'**
  String get locationOnMap;

  /// No description provided for @openDirections.
  ///
  /// In en, this message translates to:
  /// **'Open Directions'**
  String get openDirections;

  /// No description provided for @travelerReviews.
  ///
  /// In en, this message translates to:
  /// **'TRAVELER REVIEWS'**
  String get travelerReviews;

  /// No description provided for @noReviewsForPlace.
  ///
  /// In en, this message translates to:
  /// **'No reviews for this place yet.'**
  String get noReviewsForPlace;

  /// No description provided for @beFirstReviewer.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share your thoughts!'**
  String get beFirstReviewer;

  /// No description provided for @writeReviewNow.
  ///
  /// In en, this message translates to:
  /// **'Write a Review Now'**
  String get writeReviewNow;

  /// No description provided for @savedPlaceTopbar.
  ///
  /// In en, this message translates to:
  /// **'Place saved!'**
  String get savedPlaceTopbar;

  /// No description provided for @unsavedPlaceTopbar.
  ///
  /// In en, this message translates to:
  /// **'Place removed from saved.'**
  String get unsavedPlaceTopbar;

  /// No description provided for @sharePlace.
  ///
  /// In en, this message translates to:
  /// **'Discover \$name with the Hue travel app CodoKy!'**
  String get sharePlace;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Place link copied!'**
  String get linkCopied;

  /// No description provided for @navigateHereNow.
  ///
  /// In en, this message translates to:
  /// **'Navigate Here Now'**
  String get navigateHereNow;

  /// No description provided for @categoryHeritageBadge.
  ///
  /// In en, this message translates to:
  /// **'🏰 Sites & Historical Heritage'**
  String get categoryHeritageBadge;

  /// No description provided for @categoryFoodBadge.
  ///
  /// In en, this message translates to:
  /// **'🍜 Ancient Capital Hue Cuisine'**
  String get categoryFoodBadge;

  /// No description provided for @categorySpiritualBadge.
  ///
  /// In en, this message translates to:
  /// **'⛩️ Spiritual & Hue Temples'**
  String get categorySpiritualBadge;

  /// No description provided for @categoryCafeBadge.
  ///
  /// In en, this message translates to:
  /// **'☕ Hue Coffee & Lifestyle'**
  String get categoryCafeBadge;

  /// No description provided for @categoryDefaultBadge.
  ///
  /// In en, this message translates to:
  /// **'📍 Hue Tourist Place'**
  String get categoryDefaultBadge;

  /// No description provided for @ttAddressFallback.
  ///
  /// In en, this message translates to:
  /// **'Thua Thien Hue'**
  String get ttAddressFallback;

  /// No description provided for @fallbackHoursDaily.
  ///
  /// In en, this message translates to:
  /// **'07:30 - 17:30 (Daily)'**
  String get fallbackHoursDaily;

  /// No description provided for @fallbackTicket2.
  ///
  /// In en, this message translates to:
  /// **'Free / Heritage site ticket'**
  String get fallbackTicket2;

  /// No description provided for @navigatingTo.
  ///
  /// In en, this message translates to:
  /// **'Navigating to this spot • \$address'**
  String get navigatingTo;

  /// No description provided for @openNowCompact.
  ///
  /// In en, this message translates to:
  /// **'Open now'**
  String get openNowCompact;

  /// No description provided for @calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get calculating;

  /// No description provided for @startMoving.
  ///
  /// In en, this message translates to:
  /// **'Start Moving'**
  String get startMoving;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @ratingReviews.
  ///
  /// In en, this message translates to:
  /// **'\$rating (\$count reviews)'**
  String get ratingReviews;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @externalMap.
  ///
  /// In en, this message translates to:
  /// **'External Map'**
  String get externalMap;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Place link for \"\$name\" copied'**
  String get shareLinkCopied;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @ticketFee.
  ///
  /// In en, this message translates to:
  /// **'Ticket Price / Admission'**
  String get ticketFee;

  /// No description provided for @hotline.
  ///
  /// In en, this message translates to:
  /// **'Hotline Contact'**
  String get hotline;

  /// No description provided for @introHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Introduction & History'**
  String get introHistoryTitle;

  /// No description provided for @tagHeritage.
  ///
  /// In en, this message translates to:
  /// **'🏰 Imperial Capital Heritage'**
  String get tagHeritage;

  /// No description provided for @tagCheckin.
  ///
  /// In en, this message translates to:
  /// **'📸 Great check-in'**
  String get tagCheckin;

  /// No description provided for @tagArchitecture.
  ///
  /// In en, this message translates to:
  /// **'🏛️ Nguyen Dynasty Architecture'**
  String get tagArchitecture;

  /// No description provided for @tagScenery.
  ///
  /// In en, this message translates to:
  /// **'🌿 Poetic space'**
  String get tagScenery;

  /// No description provided for @reviewsExperiences.
  ///
  /// In en, this message translates to:
  /// **'Reviews & Experiences'**
  String get reviewsExperiences;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet. Be the first to share your thoughts!'**
  String get noReviewsYet;

  /// No description provided for @routeFastest.
  ///
  /// In en, this message translates to:
  /// **'⚡ Fastest'**
  String get routeFastest;

  /// No description provided for @routeShortest.
  ///
  /// In en, this message translates to:
  /// **'📍 Shortest'**
  String get routeShortest;

  /// No description provided for @routeAlternative.
  ///
  /// In en, this message translates to:
  /// **'🔄 Alternative route'**
  String get routeAlternative;

  /// No description provided for @chooseRoute.
  ///
  /// In en, this message translates to:
  /// **'Choose a route'**
  String get chooseRoute;

  /// No description provided for @extraMinutes.
  ///
  /// In en, this message translates to:
  /// **'+\$minutes min'**
  String get extraMinutes;

  /// No description provided for @catRestaurant.
  ///
  /// In en, this message translates to:
  /// **'Hue Restaurant'**
  String get catRestaurant;

  /// No description provided for @catHeritagePlace.
  ///
  /// In en, this message translates to:
  /// **'Heritage site'**
  String get catHeritagePlace;

  /// No description provided for @catTemple.
  ///
  /// In en, this message translates to:
  /// **'Temple'**
  String get catTemple;

  /// No description provided for @catTomb.
  ///
  /// In en, this message translates to:
  /// **'Tomb'**
  String get catTomb;

  /// No description provided for @catSightseeing.
  ///
  /// In en, this message translates to:
  /// **'Sightseeing'**
  String get catSightseeing;

  /// No description provided for @reviewsWritten.
  ///
  /// In en, this message translates to:
  /// **'Reviews Written'**
  String get reviewsWritten;

  /// No description provided for @likesReceived.
  ///
  /// In en, this message translates to:
  /// **'Likes Received'**
  String get likesReceived;

  /// No description provided for @noReviewsContributed.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t contributed any reviews yet.'**
  String get noReviewsContributed;

  /// No description provided for @shareExperiencePrompt.
  ///
  /// In en, this message translates to:
  /// **'Share your experience at a Hue place you\'ve visited!'**
  String get shareExperiencePrompt;

  /// No description provided for @reviewListTitle.
  ///
  /// In en, this message translates to:
  /// **'Traveler Reviews'**
  String get reviewListTitle;

  /// No description provided for @ratingBar.
  ///
  /// In en, this message translates to:
  /// **'\$stars ⭐'**
  String get ratingBar;

  /// No description provided for @beFirstShare.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share your thoughts!'**
  String get beFirstShare;

  /// No description provided for @aspectScenery.
  ///
  /// In en, this message translates to:
  /// **'🏰 Beautiful scenery'**
  String get aspectScenery;

  /// No description provided for @aspectFood.
  ///
  /// In en, this message translates to:
  /// **'🍜 Great food'**
  String get aspectFood;

  /// No description provided for @aspectPrice.
  ///
  /// In en, this message translates to:
  /// **'💰 Fair price'**
  String get aspectPrice;

  /// No description provided for @aspectService.
  ///
  /// In en, this message translates to:
  /// **'🤝 Attentive service'**
  String get aspectService;

  /// No description provided for @aspectPhoto.
  ///
  /// In en, this message translates to:
  /// **'📸 Check-in spot'**
  String get aspectPhoto;

  /// No description provided for @aspectPeace.
  ///
  /// In en, this message translates to:
  /// **'🌿 Peaceful & relaxing'**
  String get aspectPeace;

  /// No description provided for @rating1.
  ///
  /// In en, this message translates to:
  /// **'Very disappointed 😡'**
  String get rating1;

  /// No description provided for @rating2.
  ///
  /// In en, this message translates to:
  /// **'Not satisfied 🙁'**
  String get rating2;

  /// No description provided for @rating3.
  ///
  /// In en, this message translates to:
  /// **'Okay 😐'**
  String get rating3;

  /// No description provided for @rating4.
  ///
  /// In en, this message translates to:
  /// **'Satisfied 😊'**
  String get rating4;

  /// No description provided for @rating5.
  ///
  /// In en, this message translates to:
  /// **'Excellent! 😍'**
  String get rating5;

  /// No description provided for @reviewRequired.
  ///
  /// In en, this message translates to:
  /// **'Please write a few lines sharing your review.'**
  String get reviewRequired;

  /// No description provided for @reviewSuccess.
  ///
  /// In en, this message translates to:
  /// **'Thank you! Review submitted successfully (+20 VIP points).'**
  String get reviewSuccess;

  /// No description provided for @writeReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a Place Review'**
  String get writeReviewTitle;

  /// No description provided for @satisfactionLevel.
  ///
  /// In en, this message translates to:
  /// **'SATISFACTION LEVEL'**
  String get satisfactionLevel;

  /// No description provided for @recommendedCriteria.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED HIGHLIGHT CRITERIA'**
  String get recommendedCriteria;

  /// No description provided for @detailedContent.
  ///
  /// In en, this message translates to:
  /// **'DETAILED REVIEW CONTENT'**
  String get detailedContent;

  /// No description provided for @reviewHint.
  ///
  /// In en, this message translates to:
  /// **'Share your honest review about the experience, space, location or notes when visiting...'**
  String get reviewHint;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review (+20 points)'**
  String get submitReview;

  /// No description provided for @commentsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Detailed comment feature is under development.'**
  String get commentsComingSoon;

  /// No description provided for @shareTemplate.
  ///
  /// In en, this message translates to:
  /// **'\$place: \"\$content\" - Review by \$user on CodoKy'**
  String get shareTemplate;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Review content copied to clipboard!'**
  String get copiedToClipboard;

  /// No description provided for @chooseReviewPlace.
  ///
  /// In en, this message translates to:
  /// **'Choose Place to Review'**
  String get chooseReviewPlace;

  /// No description provided for @choosePlaceHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a place'**
  String get choosePlaceHint;

  /// No description provided for @yourReview.
  ///
  /// In en, this message translates to:
  /// **'Your Review'**
  String get yourReview;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Write a review title...'**
  String get titleHint;

  /// No description provided for @contentLabel.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get contentLabel;

  /// No description provided for @contentHint.
  ///
  /// In en, this message translates to:
  /// **'Share your experience at this place...'**
  String get contentHint;

  /// No description provided for @postReview.
  ///
  /// In en, this message translates to:
  /// **'Post Review'**
  String get postReview;

  /// No description provided for @chooseRatingFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a star rating'**
  String get chooseRatingFirst;

  /// No description provided for @travelerName.
  ///
  /// In en, this message translates to:
  /// **'Hue Traveler'**
  String get travelerName;

  /// No description provided for @reviewPosted.
  ///
  /// In en, this message translates to:
  /// **'Review posted successfully!'**
  String get reviewPosted;

  /// No description provided for @userHue.
  ///
  /// In en, this message translates to:
  /// **'Hue User'**
  String get userHue;

  /// No description provided for @cannotSubmitReview.
  ///
  /// In en, this message translates to:
  /// **'Could not submit review: \$error'**
  String get cannotSubmitReview;

  /// No description provided for @noPermissionEdit.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to edit this review.'**
  String get noPermissionEdit;

  /// No description provided for @cannotUpdateReview.
  ///
  /// In en, this message translates to:
  /// **'Could not update review: \$error'**
  String get cannotUpdateReview;

  /// No description provided for @cannotDeleteReview.
  ///
  /// In en, this message translates to:
  /// **'Could not delete review: \$error'**
  String get cannotDeleteReview;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get validEmailRequired;

  /// No description provided for @validEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Email format is invalid'**
  String get validEmailInvalid;

  /// No description provided for @validPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get validPasswordRequired;

  /// No description provided for @validPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least \$minLength characters'**
  String get validPasswordMinLength;

  /// No description provided for @validConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please re-confirm your password'**
  String get validConfirmPasswordRequired;

  /// No description provided for @validConfirmPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation does not match'**
  String get validConfirmPasswordMismatch;

  /// No description provided for @validFieldDefaultName.
  ///
  /// In en, this message translates to:
  /// **'This field'**
  String get validFieldDefaultName;

  /// No description provided for @validFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'\$fieldName cannot be empty'**
  String get validFieldRequired;

  /// No description provided for @validPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get validPhoneRequired;

  /// No description provided for @validPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number (e.g. 0912345678)'**
  String get validPhoneInvalid;

  /// No description provided for @validFieldMinLength.
  ///
  /// In en, this message translates to:
  /// **'\$fieldName must be at least \$minLength characters'**
  String get validFieldMinLength;

  /// No description provided for @validFieldMaxLength.
  ///
  /// In en, this message translates to:
  /// **'\$fieldName cannot exceed \$maxLength characters'**
  String get validFieldMaxLength;

  /// No description provided for @validRatingRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a star rating'**
  String get validRatingRequired;

  /// No description provided for @validRatingRange.
  ///
  /// In en, this message translates to:
  /// **'Rating must be between 1 and 5 stars'**
  String get validRatingRange;

  /// No description provided for @authErrorAccountFetch.
  ///
  /// In en, this message translates to:
  /// **'Could not retrieve account information'**
  String get authErrorAccountFetch;

  /// No description provided for @authErrorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your email and password.'**
  String get authErrorLoginFailed;

  /// No description provided for @authErrorRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create account'**
  String get authErrorRegisterFailed;

  /// No description provided for @authErrorRegisterGeneric.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again later.'**
  String get authErrorRegisterGeneric;

  /// No description provided for @authErrorResetEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not send password reset email.'**
  String get authErrorResetEmail;

  /// No description provided for @authErrorGoogleUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Google login is not supported on this platform. Please log in with Email/Password.'**
  String get authErrorGoogleUnsupported;

  /// No description provided for @authErrorGoogleGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not complete Google authentication. Please try again later.'**
  String get authErrorGoogleGeneric;

  /// No description provided for @authErrorGoogleDetail.
  ///
  /// In en, this message translates to:
  /// **'Google login failed. Error: \$rawError'**
  String get authErrorGoogleDetail;

  /// No description provided for @authErrorApple.
  ///
  /// In en, this message translates to:
  /// **'Apple login failed.'**
  String get authErrorApple;

  /// No description provided for @authErrorSavePreferences.
  ///
  /// In en, this message translates to:
  /// **'Could not save preferences.'**
  String get authErrorSavePreferences;

  /// No description provided for @authErrorUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile update failed.'**
  String get authErrorUpdateProfile;

  /// No description provided for @authErrorRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For security reasons, please log out and log back in before deleting your account.'**
  String get authErrorRecentLogin;

  /// No description provided for @cannotDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Could not delete account: \$error'**
  String get cannotDeleteAccount;

  /// No description provided for @authErrorDeleteGeneric.
  ///
  /// In en, this message translates to:
  /// **'Account deletion failed. Please try again later.'**
  String get authErrorDeleteGeneric;

  /// No description provided for @authErrorApiKeyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Firebase error: FIREBASE_API_KEY is invalid (API_KEY_INVALID). Please paste a real API Key from the Firebase Console into the .env.dev file.'**
  String get authErrorApiKeyInvalid;

  /// No description provided for @authErrorOperationNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Firebase error: Google login is not enabled (Enable) in Firebase Console > Authentication > Sign-in method.'**
  String get authErrorOperationNotAllowed;

  /// No description provided for @authErrorUnauthorizedDomain.
  ///
  /// In en, this message translates to:
  /// **'Firebase error: The current domain has not been added to Authorized Domains (Firebase Console > Authentication > Settings).'**
  String get authErrorUnauthorizedDomain;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'This email account is not registered.'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Password or login credentials are incorrect.'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email address is already registered to another account.'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address format is invalid.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak (minimum 8 characters).'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been temporarily disabled.'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Please try again in a few minutes.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your Internet connection.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorFirebaseConfig.
  ///
  /// In en, this message translates to:
  /// **'Firebase authentication error [\$code]. Please check your Firebase configuration.'**
  String get authErrorFirebaseConfig;

  /// No description provided for @authErrorFirebaseRaw.
  ///
  /// In en, this message translates to:
  /// **'[\$code] \$msg'**
  String get authErrorFirebaseRaw;

  /// No description provided for @weatherPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Hue Weather'**
  String get weatherPanelTitle;

  /// No description provided for @weatherFeelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels like {temp}°C'**
  String weatherFeelsLike(int temp);

  /// No description provided for @weatherHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get weatherHumidity;

  /// No description provided for @weatherWind.
  ///
  /// In en, this message translates to:
  /// **'Wind Speed'**
  String get weatherWind;

  /// No description provided for @weatherWindUnit.
  ///
  /// In en, this message translates to:
  /// **'{speed} km/h'**
  String weatherWindUnit(double speed);

  /// No description provided for @weatherUvIndex.
  ///
  /// In en, this message translates to:
  /// **'UV Index'**
  String get weatherUvIndex;

  /// No description provided for @weatherAirQuality.
  ///
  /// In en, this message translates to:
  /// **'Air Quality'**
  String get weatherAirQuality;

  /// No description provided for @weatherAqiLabel.
  ///
  /// In en, this message translates to:
  /// **'AQI {value}'**
  String weatherAqiLabel(int value);

  /// No description provided for @weatherAqiGood.
  ///
  /// In en, this message translates to:
  /// **'Good ✅'**
  String get weatherAqiGood;

  /// No description provided for @weatherAqiModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get weatherAqiModerate;

  /// No description provided for @weatherAqiUnhealthy.
  ///
  /// In en, this message translates to:
  /// **'Unhealthy'**
  String get weatherAqiUnhealthy;

  /// No description provided for @weatherHourlyForecast.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Forecast'**
  String get weatherHourlyForecast;

  /// No description provided for @weatherDailyForecast.
  ///
  /// In en, this message translates to:
  /// **'Next 7 Days'**
  String get weatherDailyForecast;

  /// No description provided for @weatherClose.
  ///
  /// In en, this message translates to:
  /// **'Close weather panel'**
  String get weatherClose;

  /// No description provided for @weatherToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get weatherToday;

  /// No description provided for @weatherTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get weatherTomorrow;

  /// No description provided for @weatherUpdatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated at {time}'**
  String weatherUpdatedAt(String time);

  /// No description provided for @weatherRainProb.
  ///
  /// In en, this message translates to:
  /// **'{prob}% rain'**
  String weatherRainProb(int prob);

  /// No description provided for @weatherLocationHue.
  ///
  /// In en, this message translates to:
  /// **'Hue City'**
  String get weatherLocationHue;

  /// No description provided for @weatherUvLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get weatherUvLow;

  /// No description provided for @weatherUvModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get weatherUvModerate;

  /// No description provided for @weatherUvHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get weatherUvHigh;

  /// No description provided for @weatherUvVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very High'**
  String get weatherUvVeryHigh;

  /// No description provided for @weatherUvExtreme.
  ///
  /// In en, this message translates to:
  /// **'Extreme'**
  String get weatherUvExtreme;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
