import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';

// Shared Global Screens
import 'package:codoky/shared/screens/splash_screen.dart';
import 'package:codoky/shared/screens/onboarding_screen.dart';
import 'package:codoky/shared/screens/home_screen.dart';
import 'package:codoky/shared/screens/settings_screen.dart';
import 'package:codoky/shared/screens/offline_screen.dart';
import 'package:codoky/shared/screens/search_screen.dart';

// Auth Feature
import 'package:codoky/features/auth/presentation/screens/login_screen.dart';
import 'package:codoky/features/auth/presentation/screens/register_screen.dart';
import 'package:codoky/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:codoky/features/auth/presentation/screens/onboarding_profile_screen.dart';

// Map Feature
import 'package:codoky/features/map/presentation/screens/map_home_screen.dart';
import 'package:codoky/features/map/presentation/screens/place_detail_screen.dart';

// Explore Feature
import 'package:codoky/features/explore/presentation/screens/explore_home_screen.dart';
import 'package:codoky/features/explore/presentation/screens/category_list_screen.dart';

// Itinerary Feature
import 'package:codoky/features/itinerary/presentation/screens/itinerary_setup_screen.dart';
import 'package:codoky/features/itinerary/presentation/screens/itinerary_result_screen.dart';
import 'package:codoky/features/itinerary/presentation/screens/itinerary_stop_detail_screen.dart';
import 'package:codoky/features/itinerary/presentation/screens/saved_itineraries_screen.dart';

// Review Feature
import 'package:codoky/features/review/presentation/screens/review_list_screen.dart';
import 'package:codoky/features/review/presentation/screens/write_review_screen.dart';
import 'package:codoky/features/review/presentation/screens/my_reviews_screen.dart';

// Profile Feature
import 'package:codoky/features/profile/presentation/screens/profile_home_screen.dart';
import 'package:codoky/features/profile/presentation/screens/edit_profile_screen.dart';

// Shared Shell Layout
import 'package:codoky/shared/widgets/main_shell_layout.dart';

CustomTransitionPage<T> buildPageWithTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.horizontal,
        child: child,
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/map',
    routes: [
      // 0. Global Screens
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/offline',
        builder: (context, state) => const OfflineScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),

      // 1. Auth Feature Screens
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/onboarding-profile',
        builder: (context, state) => const OnboardingProfileScreen(),
      ),

      // Place Details & Specific Param Routes
      GoRoute(
        path: '/place/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PlaceDetailScreen(id: id);
        },
      ),

      // 2. Main Shell Tabs
      ShellRoute(
        builder: (context, state, child) => MainShellLayout(child: child),
        routes: [
          // Map
          GoRoute(
            path: '/map',
            builder: (context, state) => const MapHomeScreen(),
          ),
          // Explore
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreHomeScreen(),
            routes: [
              GoRoute(
                path: 'category/:categoryId',
                builder: (context, state) {
                  final categoryId = state.pathParameters['categoryId'] ?? '';
                  return CategoryListScreen(categoryId: categoryId);
                },
              ),
            ],
          ),
          // Itinerary
          GoRoute(
            path: '/itinerary',
            builder: (context, state) => const ItinerarySetupScreen(),
          ),
          GoRoute(
            path: '/itinerary/setup',
            builder: (context, state) => const ItinerarySetupScreen(),
          ),
          GoRoute(
            path: '/itinerary/result',
            builder: (context, state) => const ItineraryResultScreen(),
          ),
          GoRoute(
            path: '/itinerary/stop/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return ItineraryStopDetailScreen(id: id);
            },
          ),
          GoRoute(
            path: '/itinerary/saved',
            builder: (context, state) => const SavedItinerariesScreen(),
          ),
          // Reviews
          GoRoute(
            path: '/reviews',
            builder: (context, state) => const ReviewListScreen(),
          ),
          GoRoute(
            path: '/reviews/write',
            builder: (context, state) => const WriteReviewScreen(),
          ),
          GoRoute(
            path: '/reviews/my',
            builder: (context, state) => const MyReviewsScreen(),
          ),
          GoRoute(
            path: '/reviews/:placeId',
            builder: (context, state) {
              final placeId = state.pathParameters['placeId'];
              return ReviewListScreen(placeId: placeId);
            },
          ),
          // Profile
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileHomeScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Không tìm thấy trang: ${state.uri}'),
      ),
    ),
  );
});