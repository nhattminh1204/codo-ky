import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codoky/core/config/localization/app_localizations.dart';
import 'package:codoky/features/auth/data/models/user_model.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';
import 'package:codoky/features/profile/presentation/screens/profile_home_screen.dart';

Widget _wrap({required List<Override> overrides, required Widget home}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('vi'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Material(child: home),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileHomeScreen Widget & State Flow Tests', () {
    testWidgets('1. Renders Guest Welcome UI when unauthenticated', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));

      await tester.pumpWidget(
        _wrap(
          overrides: [
            authProvider.overrideWith((ref) => AuthNotifierMock(const AuthState(
              isAuthenticated: false,
              isLoading: false,
              user: null,
            ))),
          ],
          home: const ProfileHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Guest Welcome title and CTA buttons appear
      expect(find.text('Khách ghé thăm'), findsOneWidget);
      expect(find.text('Đăng nhập / Đăng ký'), findsOneWidget);

      // Verify zero fake user names or emails are shown
      expect(find.text('Nguyễn Văn Minh Nhật'), findsNothing);
      expect(find.text('nhattminh1204@gmail.com'), findsNothing);
    });

    testWidgets('2. Renders Authenticated User profile data when logged in', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));

      final user = UserModel(
        id: 'u_777',
        name: 'Đặng Quốc Việt',
        email: 'viet.dang@example.com',
        phone: '0905999888',
        rewardPoints: 350,
        membershipTier: 'gold',
        preferences: ['Di sản', 'Ẩm thực'],
        createdAt: DateTime(2026, 1, 1),
      );

      await tester.pumpWidget(
        _wrap(
          overrides: [
            authProvider.overrideWith((ref) => AuthNotifierMock(AuthState(
              isAuthenticated: true,
              isLoading: false,
              user: user,
            ))),
          ],
          home: const ProfileHomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify authentic user data is rendered on screen
      expect(find.text('Đặng Quốc Việt'), findsOneWidget);
      expect(find.text('viet.dang@example.com'), findsOneWidget);
      expect(find.text('Thành viên Vàng'), findsOneWidget);
    });
  });
}

class AuthNotifierMock extends AuthNotifier {
  AuthNotifierMock(AuthState initialState) {
    state = initialState;
  }
}
