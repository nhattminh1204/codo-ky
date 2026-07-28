import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/features/auth/data/models/user_model.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';

void main() {
  group('AuthNotifier & AuthState Unit Tests', () {
    test('1. AuthState initial values are correct', () {
      const state = AuthState();
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.isNewUser, isFalse);
      expect(state.user, isNull);
      expect(state.error, isNull);
    });

    test('2. AuthState copyWith correctly updates user and isAuthenticated flag', () {
      final user = UserModel(
        id: 'u100',
        name: 'Trần Văn Huế',
        email: 'hue.tran@example.com',
        phone: '0905123456',
        createdAt: DateTime.now(),
      );

      var state = const AuthState();
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        user: user,
      );

      expect(state.isAuthenticated, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.user, equals(user));
      expect(state.user!.name, equals('Trần Văn Huế'));
    });

    test('3. AuthState copyWith correctly resets error on clearError', () {
      var state = const AuthState(isLoading: true, error: 'Lỗi đăng nhập mẫu');
      expect(state.error, isNotNull);

      state = state.copyWith(isLoading: false, clearError: true);

      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.isAuthenticated, isFalse);
    });

    test('4. UserModel JSON serialization & isGold member calculation', () {
      final json = {
        'id': 'u200',
        'name': 'Nguyễn Thị Hoa',
        'email': 'hoa.nguyen@example.com',
        'phone': '0912345678',
        'reward_points': 450,
        'membership_tier': 'gold',
        'preferences': ['Ẩm thực', 'Di sản'],
      };

      final user = UserModel.fromJson(json);

      expect(user.id, equals('u200'));
      expect(user.name, equals('Nguyễn Thị Hoa'));
      expect(user.isGold, isTrue);
      expect(user.preferences.length, equals(2));
    });
  });
}
