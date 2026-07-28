import 'package:flutter_test/flutter_test.dart';
import 'package:codoky/features/auth/data/models/user_model.dart';
import 'package:codoky/features/auth/presentation/providers/auth_provider.dart';

void main() {
  group('Auth & Profile State Tests', () {
    test('Default AuthState has no user and is unauthenticated', () {
      const state = AuthState();
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.user, isNull);
    });

    test('AuthState with user returns valid UserModel properties', () {
      final now = DateTime.now();
      final user = UserModel(
        id: 'u123',
        name: 'Trần Thị Mai',
        email: 'mai.tran@example.com',
        phone: '0901234567',
        preferences: ['Ẩm thực', 'Nhiếp ảnh'],
        createdAt: now,
      );

      final state = AuthState(
        isAuthenticated: true,
        user: user,
      );

      expect(state.isAuthenticated, isTrue);
      expect(state.user!.name, equals('Trần Thị Mai'));
      expect(state.user!.email, equals('mai.tran@example.com'));
      expect(state.user!.preferences.length, equals(2));
    });

    test('User with 350 points is identified as Gold Member', () {
      final user = UserModel(
        id: 'u999',
        name: 'Lê Hoàng',
        email: 'hoang.le@example.com',
        phone: '0987654321',
        rewardPoints: 350,
        createdAt: DateTime.now(),
      );

      expect(user.isGold, isTrue);
    });
  });
}
