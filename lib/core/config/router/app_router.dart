import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:codoky/features/auth/presentation/pages/login_page.dart';
import 'package:codoky/features/auth/presentation/pages/register_page.dart';
import 'package:codoky/features/map/presentation/pages/map_page.dart';
import 'package:codoky/features/itinerary/presentation/pages/itinerary_page.dart';
import 'package:codoky/features/explore/presentation/pages/explore_page.dart';
import 'package:codoky/features/review/presentation/pages/review_page.dart';
import 'package:codoky/shared/widgets/main_shell_layout.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/map',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShellLayout(child: child),
        routes: [
          GoRoute(
            path: '/map',
            builder: (context, state) => const MapPage(),
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExplorePage(),
          ),
          GoRoute(
            path: '/itinerary',
            builder: (context, state) => const ItineraryPage(),
          ),
          GoRoute(
            path: '/review',
            builder: (context, state) => const ReviewPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});