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
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';
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

// Camera Feature
import 'package:codoky/features/camera/presentation/screens/locket_camera_screen.dart';

// Shared Shell Layout
import 'package:codoky/shared/widgets/main_shell_layout.dart';

CustomTransitionPage<T> buildPageWithTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  SharedAxisTransitionType type = SharedAxisTransitionType.horizontal,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: type,
        child: child,
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' ||
          loc == '/register' ||
          loc == '/forgot-password' ||
          loc == '/splash' ||
          loc == '/onboarding';

      if (loc == '/' || (!isAuth && !isAuthRoute)) {
        return '/login';
      }

      if (isAuth && (loc == '/login' || loc == '/register')) {
        return '/map';
      }
      return null;
    },
    routes: [
      // 0. Global Screens
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
          type: SharedAxisTransitionType.scaled,
        ),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/offline',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const OfflineScreen(),
        ),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const SearchScreen(),
        ),
      ),

      // 1. Auth Feature Screens
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
          type: SharedAxisTransitionType.scaled,
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/onboarding-profile',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const OnboardingProfileScreen(),
        ),
      ),

      // Place Details & Review Push Routes
      GoRoute(
        path: '/place/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return buildPageWithTransition(
            context: context,
            state: state,
            child: PlaceDetailScreen(id: id),
          );
        },
      ),
      GoRoute(
        path: '/reviews',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const ReviewListScreen(),
        ),
      ),
      GoRoute(
        path: '/reviews/write',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const WriteReviewScreen(),
        ),
      ),
      GoRoute(
        path: '/reviews/my',
        pageBuilder: (context, state) => buildPageWithTransition(
          context: context,
          state: state,
          child: const MyReviewsScreen(),
        ),
      ),
      GoRoute(
        path: '/reviews/:placeId',
        pageBuilder: (context, state) {
          final placeId = state.pathParameters['placeId'];
          return buildPageWithTransition(
            context: context,
            state: state,
            child: ReviewListScreen(placeId: placeId),
          );
        },
      ),

      // 2. Main Shell Tabs with StatefulShellRoute.indexedStack
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShellLayout(navigationShell: navigationShell),
        branches: [
          // Branch 0: Map
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MapHomeScreen(),
              ),
            ],
          ),
          // Branch 1: Explore
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'category/:categoryId',
                    pageBuilder: (context, state) {
                      final categoryId = state.pathParameters['categoryId'] ?? '';
                      return buildPageWithTransition(
                        context: context,
                        state: state,
                        child: CategoryListScreen(categoryId: categoryId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // Branch 2: Center Action (AI Camera Scanner)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/camera',
                builder: (context, state) => const LocketCameraScreen(),
              ),
            ],
          ),
          // Branch 3: Itinerary
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/itinerary',
                builder: (context, state) => const ItinerarySetupScreen(),
                routes: [
                  GoRoute(
                    path: 'result',
                    pageBuilder: (context, state) => buildPageWithTransition(
                      context: context,
                      state: state,
                      child: const ItineraryResultScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'stop/:id',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return buildPageWithTransition(
                        context: context,
                        state: state,
                        child: ItineraryStopDetailScreen(id: id),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'saved',
                    pageBuilder: (context, state) => buildPageWithTransition(
                      context: context,
                      state: state,
                      child: const SavedItinerariesScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    pageBuilder: (context, state) => buildPageWithTransition(
                      context: context,
                      state: state,
                      child: const EditProfileScreen(),
                    ),
                  ),
                ],
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